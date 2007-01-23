module LWT
  module AuthenticationSystem
    module LoginController

      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        # Includes the login and logout actions into this controller.
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
            :track_pre_login_url => true
          }.merge( options )
          
          redirect_after_logout do |controller| 
            { :action => 'login' }
          end          
        end
      end
      
      module SingletonMethods
        attr_accessor :lwt_authentication_system_options
        
        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs in. The block will be passed the controller
        # and the logged in user.
        def redirect_after_login &blk
          self.lwt_authentication_system_options[:redirect_after_login] = blk
        end

        # Sets the arguments to be passed to redirect_to after a user
        # successfully logs out. The block will be passed the controller.
        # This defaults to the login action.
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
            #TODO: Remove references to user model
            @user = User.login params[:user]
            if @user
              self.set_current_user @user
              do_redirect_after_login
              return
            else
              flash.now[:error] = self.class.lwt_authentication_system_options[:invalid_login_flash]
            end
          elsif self.current_user
            do_redirect_after_login
            return
          else
            #TODO: Remove references to user model
            @user = User.new
            flash.now[:notice] = self.class.lwt_authentication_system_options[:login_flash]
          end
        end

        # The logout action resets the session and rediects the user to
        # the page defined in redirect_after_logout.
        def logout
          reset_session
          self.set_current_user
          redirect_to self.class.lwt_authentication_system_options[:redirect_after_logout].call( self )
        end

      private
        def do_redirect_after_login
          if self.class.lwt_authentication_system_options[:track_pre_login_url] and session[:pre_login_url]
            redirect_to session[:pre_login_url]
            session[:pre_login_url] = nil
          else
            redirect_to self.class.lwt_authentication_system_options[:redirect_after_login].call( self, current_user )
          end
        end
      end
    end
  end
end
