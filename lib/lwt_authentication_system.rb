# = MTI
#TODO: Model logs logins
#TODO: allow configuration of group/priv models
#
# = LoginController
#LATER: Alow configuration of invalid login flash
#LATER: Alow configuration of please login flash
#
# = View
#LATER: restrict_to
#
# = Model
#LATER: validate user.group_id
#LATER: Allow custom passwords do not match message
#LATER: Allow custom username validation messages
#LATER: allow configuration of username and password_hash
#LATER: allow configuration of User
#LATER: Implement salt
#LATER: allow configuration of hash method
#
#LATER: implement preferences
#LATER: enforece only one acts_as_authenticated?
#
#LATER: Allow custom validation msg for group and priv validations
#
#
#
#
# = System
# WAYLATER: Do I like how this all works?
#
# = Controller
# WAYLATER: Auto configure on_not_logged_in to the controller with acts_as_login_controller?

# This authentication system allows for an easy, plug and play solution to all you authentication
# privilege needs.
#
# Dependencies:
# - ActiveRecordExtensions
#
# Here is the basic usage:
#
# 1. Install the plugin.
# 2. Put acts_as_login_controller in the controller which you want to add the login/logout actions to.
# 3. puts acts_as_authenticated in the model you want to be the authenticatable model (currently this HAS TO BE User)
#    a. This model needs the field group_id
# 4. Add the following to the database:
#    a. group: name
#    b. privilege: name
module LWT
  module AuthenticationSystem
    module Controller
      def self.included base
        base.extend ClassMethods
        base.send :include, InstanceMethods

        # Before filter needs to issued to setup the current user
        base.before_filter :set_current_user

        # The current user method should be made available in the views
        base.send :helper_method, :current_user

        # Define this so that each decendant of ActionController::Base will automatically
        # receive its parents callbacks, but can update its own without changing its
        # parents or siblings.
        base.class_inheritable_accessor :permission_granted, :permission_denied, :not_logged_in

        base.cattr_accessor :redirect_after_login, :redirect_after_logout

        base.on_not_logged_in do |c|
          c.send :redirect_to, :controller => 'users', :action => 'login'
          false
        end

        base.set_redirect_after_logout { |c| { :action => 'login' } }
      end

      module ClassMethods
        # This will include the LoginController module in the controller that calls it.
        # This can only be called from one controller in the application
        def acts_as_login_controller
          self.send :include, LWT::AuthenticationSystem::LoginController
        end

        # This is used to restrict access to action based on privileges of the current user.
        # This method takes a list of privileges which should be allowes, as well as the options
        # hash which will be passed to before_filter.
        def restrict_to *args
          options = args.last.is_a?( Hash ) ? args.pop : {}

          before_filter( options ) do |c|
            if !c.current_user.is_a? User
              c.session[:pre_login_url] = c.params
              c.class.not_logged_in ? c.class.not_logged_in.call( c ) : false
            elsif c.current_user.has_privilege?( *args )
              c.class.permission_granted ? c.class.permission_granted.call( c, c.current_user ) : true
            else
              c.class.permission_denied ? c.class.permission_denied.call( c, c.current_user ) : false
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

        def set_redirect_after_login &blk
          self.redirect_after_login = blk
        end

        def set_redirect_after_logout &blk
          self.redirect_after_logout = blk
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

        def do_redirect_after_login
          if session[:pre_login_url]
            redirect_to session[:pre_login_url]
            session[:pre_login_url] = nil
          else
            redirect_to self.class.redirect_after_login.call( self, current_user )
          end
        end
      end
    end

    module LoginController
      def self.included base
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def login
          if request.post?
            @user = User.login params[:user]
            if @user
              self.set_current_user @user
              do_redirect_after_login
              return
            else
              flash.now[:error] = 'Invalid login credentials'
            end
          elsif self.current_user
            do_redirect_after_login
            return
          else
            @user = User.new
            flash.now[:notice] = 'Please login'
          end
        end

        def logout
          reset_session
          self.set_current_user
          redirect_to self.class.redirect_after_logout.call( self )
        end
      end
    end


    # All the necessary methods for the Model
    #
    # Configuration options:
    # * :password_validation_message
    # * :username_validation_message
    # * :hash_password
    module Model
      module SingletonMethods
        def acts_as_authenticated options = {}
          self.send :include, LWT::AuthenticationSystem::Model
          self.lwt_authentication_system_options[:password_validation_message] =
            options[:password_validation_message] if options[:password_validation_message]
          self.lwt_authentication_system_options[:username_validation_message] =
            options[:username_validation_message] if options[:username_validation_message]
        end
      end

      def self.included base
        base.extend ClassMethods
        base.send :include, InstanceMethods

        base.lwt_authentication_system_options = {}
        base.lwt_authentication_system_options[:password_validation_message] = "Passwords must match."
        base.lwt_authentication_system_options[:username_validation_message] = "Username cannot be blank."
        base.lwt_authentication_system_options[:username_unique_validation_message] = "Username has already been taken."

        base.send :belongs_to, :group
        base.send :validates_presence_of, :username,
          :message => base.lwt_authentication_system_options[:username_validation_message]
        base.send :validates_uniqueness_of, :username,
          :message => base.lwt_authentication_system_options[:username_unique_validation_message]
        base.send :validate, :validate_password
      end

      module ClassMethods
        attr_accessor :current_user, :lwt_authentication_system_options

        # attempts to find a user by the passed in attributes. The param :password will
        # be removed and the param :password_hash set to the hash of the :password param.
        def login params
          params[:password_hash] = hash_password( params.delete( :password ) )
          User.find :first, :conditions => params, :include => { :group => :privileges }
        end

        # This is the method used to hash the users password. To implement your own hasing
        # scheme, just override this method in your model.
        def hash_password pwd
          require 'md5'
          MD5.hexdigest( pwd )
        end
      end

      module InstanceMethods
        attr_reader :password, :password_confirmation

        # Stores the password for validation, as well as sets the password_hash method for database.
        def password=( pwd )
          return if pwd.empty?
          @password_validation ||= {}
          @password_validation[:password] = pwd
          self.password_hash = self.class.hash_password( pwd )
        end

        # Stores the confirmation password for validation.
        def password_confirmation=( pwd )
          return if pwd.empty?
          @password_validation ||= {}
          @password_validation[:password_confirmation] = pwd
        end

        # This method will validate that the the password and it's confirmation match, if the password was changed.
        def validate_password
          if @password_validation and @password_validation[:password] != @password_validation[:password_confirmation]
            errors.add :password, self.class.lwt_authentication_system_options[:password_validation_message]
            false
          end
          true
        end

        # This method determines if this user has any of the passed in privileges.
        # The the arguments are expected to be symbols.
        def has_privilege? *privs
          return false unless group
          group.privileges.each do |priv|
            return true if privs.include? priv.name.to_sym
          end
          false
        end
      end
    end
  end
end
