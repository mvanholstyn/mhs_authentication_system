# = Controller
#FIXME: Update how restrict_to works so that it can be ignored in subcasses
#TODO: automatically set on_not_logged_in to redirect to the login_controller/login
#TODO: Allow model to be something other than User
#TODO: Before/after login callbacks?
#TODO: enforce only one acts_as_login_controller
#
# = View
#FIXME: restrict_to
#
# = Model
#TODO: validate user.group_id
#TODO: Allow custom validation msg for group and priv validations
#TODO: allow configuration of username, password_hash, and salt column names?
#TODO: enforce only one acts_as_authenticated
#TODO: Revisit mixin for group/priv/group_priv
#
# = Preferences
#TODO: implement preferences
#
# = Object privs
#TODO: Object privileges
#
# = Migration
#TODO: migration

# This authentication system allows for an easy, plug and play solution
# to all you authentication and privilege needs.
#
# Here is the basic usage:
#
# 1. acts_as_login_controller, redirect_after_login, restrict_to
# 2. acts_as_authenticated
# 3. database
module LWT
  module AuthenticationSystem
    module Controller

    private
      def self.included base
        base.extend ClassMethods
        base.send :include, InstanceMethods

        base.before_filter :set_current_user
        base.send :helper_method, :current_user
        base.class_inheritable_accessor :permission_granted, :permission_denied, :not_logged_in

        base.on_not_logged_in do |c|
          c.send :redirect_to, :controller => 'users', :action => 'login'
          false
        end

        base.on_permission_denied { |c,u| false }
        base.on_permission_granted { |c,u| true }
      end
      
    public
      module ClassMethods
        # This is used to restrict access to action based on privileges of the current user.
        # This method takes a list of privileges which should be allowes, as well as the options
        # hash which will be passed to before_filter.
        def restrict_to *args
          options = args.last.is_a?( Hash ) ? args.pop : {}

          before_filter( options ) do |c|
            if !c.current_user.is_a? User
              c.session[:pre_login_url] = c.params
              c.class.not_logged_in.call( c )
            elsif c.current_user.has_privilege?( *args )
              c.class.permission_granted.call( c, c.current_user )
            else
              c.class.permission_denied.call( c, c.current_user )
            end
          end
        end

        # Callback used when no user is logged in. The return value will
        # be the return value for the before_filter. This defaults to redirecting
        # to the 'users/login' action.
        def on_not_logged_in &blk
          self.not_logged_in = blk
        end

        # Callback used when a user is denied access to a page. The return value will
        # be the return value for the before_filter.
        def on_permission_denied &blk
          self.permission_denied = blk
        end

        # Callback used when a user is granted access to a page. The return value will
        # be the return value for the before_filter.
        def on_permission_granted &blk
          self.permission_granted = blk
        end

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
          self.send :include, LWT::AuthenticationSystem::LoginController
          self.lwt_authentication_system_options.merge options
        end
      end

      module InstanceMethods
        def current_user
          User.current_user
        end

        def set_current_user user = nil
          if user.is_a? User
            session[:current_user_id] = user.id
            User.current_user = user
          elsif session[:current_user_id]
            User.current_user = User.find session[:current_user_id], :include => { :group => :privileges }
          else
            User.current_user = nil
          end
        end
      end
    end

    module LoginController

    private
      def self.included base
        base.extend ClassMethods
        base.send :include, InstanceMethods
        base.cattr_accessor :lwt_authentication_system_options
        
        base.lwt_authentication_system_options = { 
          :login_flash => "Please login",
          :invalid_login_flash => "Invalid login credentials",
          :track_pre_login_url => true 
        }
        base.redirect_after_logout { |c| { :action => 'login' } }
      end

    public
      module ClassMethods
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

    module Model
      module SingletonMethods

        # Includes the login and logout actions into this controller.
        #
        # Valid options:
        # - :password_validation_message - Error message used when the passwords do not match.
        #   Default: "Passwords must match"
        # - :username_validation_message - Error message used when the username is blank.
        #   Default: "Username cannot be blank"
        # - :username_unique_validation_message - Error message used when the username is
        #   already in use. Default: "Username has already been taken"
        def acts_as_authenticated options = {}
          self.send :include, LWT::AuthenticationSystem::Model
          self.lwt_authentication_system_options.merge options
        end
      end

    private
      def self.included base
        base.extend ClassMethods
        base.send :include, InstanceMethods

        base.lwt_authentication_system_options = {
          :password_validation_message => "Passwords must match",
          :username_validation_message => "Username cannot be blank",
          :username_unique_validation_message => "Username has already been taken",
          :use_salt => false
        }
        base.hash_password do |pwd|
          require 'md5'
          MD5.hexdigest( pwd )
        end

        base.send :belongs_to, :group
        base.send :validates_presence_of, :username,
          :message => base.lwt_authentication_system_options[:username_validation_message]
        base.send :validates_uniqueness_of, :username,
          :message => base.lwt_authentication_system_options[:username_unique_validation_message]
        base.send :validate, :validate_password
      end
 
    public
      module ClassMethods
        attr_accessor :current_user, :lwt_authentication_system_options

        # Attempts to find a user by the passed in attributes. The param :password will
        # be removed and will be checked against the password of the user found (if any).
        def login params
          password = params.delete( :password )
          user = User.find :first, :conditions => params, :include => { :group => :privileges }
          return nil unless user

          if self.lwt_authentication_system_options[:use_salt]
            user.password_hash == self.lwt_authentication_system_options[:hash_password].call( password, user.salt )
          else
            user.password_hash == self.lwt_authentication_system_options[:hash_password].call( password )
          end ? user : nil
        end

        # Takes a block which is used to hash the users password. The block
        # takes the plaintext password and salt (if salt is enabled) as the
        # arguments.
        def hash_password &blk
          self.lwt_authentication_system_options[:hash_password] = blk
        end
      end

      module InstanceMethods
        attr_reader :password, :password_confirmation

        # This method determines if this user has any of the passed in privileges.
        # The the arguments are expected to be symbols.
        def has_privilege? *privs
          return false unless group
          group.privileges.each do |priv|
            return true if privs.include? priv.name.to_sym
          end
          false
        end
        
        # Stores the password for validation, as well as sets the password_hash method for database.
        def password=( pwd )
          return if pwd.empty?
          @password_validation ||= {}
          @password_validation[:password] = pwd
          self.password_hash = if self.class.lwt_authentication_system_options[:use_salt]
            self.class.lwt_authentication_system_options[:hash_password].call( pwd, user.salt )
          else
            self.class.lwt_authentication_system_options[:hash_password].call( pwd )
          end
        end

        # Stores the confirmation password for validation.
        def password_confirmation=( pwd )
          return if pwd.empty?
          @password_validation ||= {}
          @password_validation[:password_confirmation] = pwd
        end

      private
        def validate_password
          if @password_validation and @password_validation[:password] != @password_validation[:password_confirmation]
            errors.add :password, self.class.lwt_authentication_system_options[:password_validation_message]
            return false
          end
          true
        end
      end
    end
  end
end
