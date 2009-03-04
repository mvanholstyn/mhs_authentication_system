module Mhs
  module AuthenticationSystem
    module LoginController

      def self.included base #:nodoc:
        base.extend ClassMethods
      end

      # These methods are added to ActionController::Base      
      module ClassMethods
        # Sets up this controller as a login controller. The following thigs are done:
        # * Adds methods from Mhs::AuthenticationSystem::LoginController::InstanceMethods
        # * Adds methods from Mhs::AuthenticationSystem::LoginController::SingletonMethods        
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
        def acts_as_login_controller(options = {})
          include Mhs::AuthenticationSystem::LoginController::InstanceMethods
          extend Mhs::AuthenticationSystem::LoginController::SingletonMethods

          self.mhs_authentication_system_options = {
            :login_flash => "Please login",
            :invalid_login_flash => "Invalid login credentials",
            :inactive_login_flash => "Your account has not been activated",
            :signup_flash => "Please signup",
            :successful_signup_flash => "You have successfully signed up",
            :allow_signup => false,
            :require_activation => false,
            :reminder_flash => "Please enter the email address of the account whose information you would like to retrieve",
            :reminder_error_flash => "The email address you entered was not found",
            :reminder_success_flash => "Please check your email to retrieve your account information",
            :email_from => "Support",
            :reminder_login_duration => 2.hours,
            :reminder_email_subject => "Support Reminder",
            :signup_email_subject => "Welcome",
            :track_pre_login_url => true,
            :reset_session_after_logout => true
          }.merge(options)
          
          if mhs_authentication_system_options[:allow_signup]
            include Mhs::AuthenticationSystem::LoginController::SignupInstanceMethods
          end
          
          redirect_after_logout do
            { :action => 'login' }
          end

          redirect_after_signup do
            { :action => 'login' }
          end
        end
      end

      module SingletonMethods
        attr_accessor :mhs_authentication_system_options
        
        # Update restrict_to to automatically ignore the login, logout, reminder, profile, and signup actions
        def restrict_to(*privileges, &blk)
          options = privileges.extract_options!

          if not options[:only]
            options[:except] = Array(options[:except]) + [:login, :logout, :reminder, :profile, :signup]
          end
          
          privileges << options
          
          super(*privileges, &blk)
        end
        
        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs in. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_login &blk
          mhs_authentication_system_options[:redirect_after_login] = blk
        end

        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs in. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_reminder_login &blk
          mhs_authentication_system_options[:redirect_after_reminder_login] = blk
        end

        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs out. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_logout &blk
          mhs_authentication_system_options[:redirect_after_logout] = blk
        end

        def after_successful_signup &blk
          mhs_authentication_system_options[:after_successful_signup] = blk
        end
        
        def after_failed_signup &blk
          mhs_authentication_system_options[:after_failed_signup] = blk
        end

        # Sets the arguments to be passed to redirect_to after a user
        # successfully signs up. The block will be evaluated in the scope
        # of the controller.
        def redirect_after_signup &blk
          mhs_authentication_system_options[:redirect_after_signup] = blk
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
            instance_variable_set("@#{self.class.login_model_name}", model = instance_eval(&self.class.login_model_scope).login(params[self.class.login_model_name]))
            if model
              if model.active?
                if not params[:remember_me].blank?
                  model.remember_me! 
                  cookies[:remember_me_token] = { :value => model.remember_me_token , :expires => model.remember_me_token_expires_at }
                end
                set_current_user model
                do_redirect_after_login
                return
              else
                flash.now[:error] = self.class.mhs_authentication_system_options[:inactive_login_flash]
              end
            else
              flash.now[:error] = self.class.mhs_authentication_system_options[:invalid_login_flash]
            end
          elsif params[:id] and params[:token] and reminder = UserReminder.first(:conditions => ["user_id = ? AND token = ? AND expires_at >= ? ", params[:id], params[:token], Time.now])
            model = instance_eval(&self.class.login_model_scope).find(reminder.user_id)
            model.update_attribute :active, true
            set_current_user model
            reminder.destroy
            do_redirect_after_reminder_login
          elsif current_user
            do_redirect_after_login
            return
          else
            instance_variable_set("@#{self.class.login_model_name}", instance_eval(&self.class.login_model_scope).new)
            flash.now[:notice] ||= self.class.mhs_authentication_system_options[:login_flash]
          end
        end

        # The logout action resets the session and rediects the user to
        # the page defined in redirect_after_logout.
        def logout
          if current_user
            current_user.forget_me!
            cookies.delete(:remember_me_token)
            set_current_user nil
            reset_session if self.class.mhs_authentication_system_options[:reset_session_after_logout]
          end
          redirect_to instance_eval(&self.class.mhs_authentication_system_options[:redirect_after_logout])
        end

        def reminder
          if request.post?
            login_attribute = self.class.login_model.mhs_authentication_system_options[:login_attribute]
            login_attribute_value = params[self.class.login_model_name][login_attribute]
            if login_model_name.blank? || (model = instance_eval(&self.class.login_model_scope).first(:conditions => { login_attribute => login_attribute_value })).nil?
              flash.now[:error] = self.class.mhs_authentication_system_options[:reminder_error_flash]
            else
              reminder = UserReminder.create_for_user(model, Time.now + self.class.mhs_authentication_system_options[:reminder_login_duration])
              url = url_for(:action => 'login', :id => model, :token => reminder.token)
              UserReminderMailer.deliver_reminder(model, reminder, url, 
                :from => self.class.mhs_authentication_system_options[:email_from], 
                :subject => self.class.mhs_authentication_system_options[:reminder_email_subject])
              flash[:notice] = self.class.mhs_authentication_system_options[:reminder_success_flash]
              redirect_to :action => "login"
            end
          else
            instance_variable_set("@#{self.class.login_model_name}", instance_eval(&self.class.login_model_scope).new)
            flash.now[:notice] = self.class.mhs_authentication_system_options[:reminder_flash]
          end
        end
        
        def profile
          if current_user
            instance_variable_set("@#{self.class.login_model_name}", current_user)
    
            if request.put?
              respond_to do |format|
                if current_user.update_attributes(params[self.class.login_model_name])
                  flash[:notice] = 'Your profile was successfully updated.'
                  format.html { do_redirect_after_login }
                  format.xml  { head :ok }
                else
                  format.html
                  format.xml  { render :xml => current_user.errors }
                end
              end
            end
          else
            redirect_to :action => "login"
          end
        end

      private
        def do_redirect_after_reminder_login
          if blk = self.class.mhs_authentication_system_options[:redirect_after_reminder_login]
            redirect_to instance_eval(&blk)
          else
            do_redirect_after_login
          end
        end
      
        def do_redirect_after_login
          if self.class.mhs_authentication_system_options[:track_pre_login_url] and session[:pre_login_url]
            redirect_to session[:pre_login_url]
            session[:pre_login_url] = nil
          else
            redirect_to instance_eval(&self.class.mhs_authentication_system_options[:redirect_after_login])
          end
        end
      end

      module SignupInstanceMethods
        def signup
          instance_variable_set("@#{self.class.login_model_name}", model = instance_eval(&self.class.login_model_scope).new(params[self.class.login_model_name]))
          if request.post?
            model.active = self.class.mhs_authentication_system_options[:require_activation] ? false : true
            if model.save
              reminder = UserReminder.create_for_user(model, Time.now + self.class.mhs_authentication_system_options[:reminder_login_duration])
              url = url_for(:action => 'login', :id => model, :token => reminder.token)
              UserReminderMailer.deliver_signup(model, reminder, url, 
                :from => self.class.mhs_authentication_system_options[:email_from], 
                :subject => self.class.mhs_authentication_system_options[:signup_email_subject]
              )
              flash[:notice] = self.class.mhs_authentication_system_options[:successful_signup_flash]
              instance_eval(&self.class.mhs_authentication_system_options[:after_successful_signup]) if self.class.mhs_authentication_system_options[:after_successful_signup]
              redirect_to instance_eval(&self.class.mhs_authentication_system_options[:redirect_after_signup])
            else
              instance_eval(&self.class.mhs_authentication_system_options[:after_failed_signup]) if self.class.mhs_authentication_system_options[:after_failed_signup]
            end
          else
            flash[:notice] = self.class.mhs_authentication_system_options[:signup_flash]
          end
        end
      end
    end
  end
end
