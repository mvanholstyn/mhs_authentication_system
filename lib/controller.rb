module LWT
  module AuthenticationSystem
    module Controller

      def self.included base
        base.extend ClassMethods
        base.send :include, InstanceMethods

        base.class_inheritable_accessor :permission_granted, :permission_denied, :not_logged_in, :login_model_name, :login_controller_name
        base.helper_method :current_user, :restrict_to

        base.before_filter :set_current_user

        base.set_login_model :user
        base.set_login_controller :users_controller

        base.on_not_logged_in do |c|
          c.send :redirect_to, :controller => c.class.login_controller_name.gsub( /_controller$/, '' ), :action => 'login'
          false
        end

        base.on_permission_denied { |c,u| false }
        base.on_permission_granted { |c,u| true }
      end

      module ClassMethods
        # This is used to restrict access to action based on privileges of the current user.
        # This method takes a list of privileges which should be allowes, as well as the options
        # hash which will be passed to before_filter.
        def restrict_to *privileges
          options = privileges.last.is_a?( Hash ) ? privileges.pop : {}

          before_filter( options ) do |c|
            if !c.current_user.is_a? self.login_model
              c.session[:pre_login_url] = c.params
              c.class.not_logged_in.call( c )
            elsif c.current_user.has_privilege?( *privileges )
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

        def set_login_model model_name
          self.login_model_name = model_name.to_s
        end

        def set_login_controller controller_name
          self.login_controller_name = controller_name.to_s
        end

        def login_model
          self.login_model_name.classify.constantize
        end
      end

      module InstanceMethods
        def current_user
          self.class.login_model.current_user
        end

        def restrict_to *privileges, &blk
          if current_user.is_a?( self.class.login_model ) and current_user.has_privilege?( *privileges )
            blk.call
          end
        end

        def set_current_user user = nil
          if user.is_a? self.class.login_model
            session[:current_user_id] = user.id
            self.class.login_model.current_user = user
          elsif session[:current_user_id]
            self.class.login_model.current_user = self.class.login_model.find session[:current_user_id], :include => { :group => :privileges }
          else
            self.class.login_model.current_user = nil
          end
        end
      end
    end
  end
end