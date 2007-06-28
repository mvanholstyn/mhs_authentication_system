module LWT
  module AuthenticationSystem
    module LoginController

      def self.included base #:nodoc:
        base.extend ClassMethods
      end

      # These methods are added to ActionController::Base      
      module ClassMethods
        # Sets up this controller as a login controller. The following thigs are done:
        # * Adds methods from LWT::AuthenticationSystem::LoginController::InstanceMethods
        # * Adds methods from LWT::AuthenticationSystem::LoginController::SingletonMethods        
        #
        # Valid options:
        # - :login_flash - This is the message stored in flash[:notice] when
        #   prompting the user to login. Default: "Please login"
        # - :invalid_login_flash - This is the message stored in flash[:error]
        #   when a user attempts to login with invalid login credentials.
        #   Default: "Invalid login credentials"
        # - :track_pre_login_url - If true and the user attempts to go to a specific
        #   page before logging in, after logging in they will be redirected to
        #   the page they initially requested rather then the page defined by the
        #   after_login_redirect. Defatut: true
        def acts_as_login_controller( options = {} )
          include LWT::AuthenticationSystem::LoginController::InstanceMethods
          extend LWT::AuthenticationSystem::LoginController::SingletonMethods

          self.lwt_authentication_system_options = {
            :login_flash => "Please login",
            :invalid_login_flash => "Invalid login credentials",
            :reminder_flash => "Please enter the email address of the account whose information you would like to retrieve",
            :reminder_error_flash => "The email address you entered was not found",
            :reminder_success_flash => "Please check your email to retrieve your account information",
            :reminder_email_from => "Support",
            :reminder_email_subject => "Support Reminder",
            :track_pre_login_url => true
          }.merge( options )

          redirect_after_logout do
            { :action => 'login' }
          end
        end
      end

      module SingletonMethods
        attr_accessor :lwt_authentication_system_options

        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs in. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_login &blk
          self.lwt_authentication_system_options[:redirect_after_login] = blk
        end

        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs in. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_reminder_login &blk
          self.lwt_authentication_system_options[:redirect_after_reminder_login] = blk
        end

        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs out. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_logout &blk
          self.lwt_authentication_system_options[:redirect_after_logout] = blk
        end
      end

      module InstanceMethods
        # The login action performs three different tasks, depending on
        # the context.
        #
        # - If resuest.post? the parameters in params[:user] will be used to
        #   try to login the user.
        # - If a user is already logged in, they will be redirected to the
        #   page defined in redirect_after_login
        # - Else, the login template will be rendered.
        def login
          if request.post?
            instance_variable_set( "@#{self.class.login_model_name}", model = self.class.login_model.login( params[self.class.login_model_name.to_sym] ) )
            if model
              set_current_user model
              do_redirect_after_login
              return
            else
              flash.now[:error] = self.class.lwt_authentication_system_options[:invalid_login_flash]
            end
          elsif self.current_user
            do_redirect_after_login
            return
          else
            instance_variable_set( "@#{self.class.login_model_name}", self.class.login_model.new )
            flash.now[:notice] ||= self.class.lwt_authentication_system_options[:login_flash]
          end
        end

        # The logout action resets the session and rediects the user to
        # the page defined in redirect_after_logout.
        def logout
          set_current_user nil
          redirect_to self.instance_eval( &self.class.lwt_authentication_system_options[:redirect_after_logout] )
        end

        def reminder
          if request.post?
            email_address = params[self.class.login_model_name.to_sym][:email_address]
            if email_address.blank? || ( user = self.class.login_model.find_by_email_address( email_address ) ).nil?
              flash.now[:error] = self.class.lwt_authentication_system_options[:reminder_error_flash]
            else
              reminder = UserReminder.create_for_user( user )
              url = url_for(:action => 'reminder_login', :id => user, :token => reminder.token)
              UserReminderMailer.deliver_reminder(user, reminder, url, 
                :from => self.class.lwt_authentication_system_options[:reminder_email_from], 
                :subject => self.class.lwt_authentication_system_options[:reminder_email_subject] )
              flash[:notice] = self.class.lwt_authentication_system_options[:reminder_success_flash]
              redirect_to :action => "login"
            end
          else
            instance_variable_set( "@#{self.class.login_model_name}", self.class.login_model.new )
            flash.now[:notice] = self.class.lwt_authentication_system_options[:reminder_flash]
          end
        end
        
        def reminder_login
          reminder = UserReminder.find :first, :conditions => [ "user_id = ? AND token = ? AND expires_at >= ? ", params[:id], params[:token], Time.now ]
          if reminder
            self.set_current_user self.class.login_model.find( reminder.user_id )
            reminder.destroy
            do_redirect_after_reminder_login
          else
            redirect_to :action => "login"
            return
          end
        end

      private
        def do_redirect_after_reminder_login
          if blk = self.class.lwt_authentication_system_options[:redirect_after_reminder_login]
            redirect_to self.instance_eval( &blk )
          else
            do_redirect_after_login
          end
        end
      
        def do_redirect_after_login
          if self.class.lwt_authentication_system_options[:track_pre_login_url] and session[:pre_login_url]
            redirect_to session[:pre_login_url]
            session[:pre_login_url] = nil
          else
            redirect_to self.instance_eval( &self.class.lwt_authentication_system_options[:redirect_after_login] )
          end
        end
      end
    end
  end
end
