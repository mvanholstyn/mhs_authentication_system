module LWT
  module AuthenticationSystem
    module Model

      def self.included base #:nodoc:
        base.extend ClassMethods
      end

      # These methods are added to ActiveRecord::Base
      module ClassMethods
        # Sets up this model as a login model. The following thigs are done:
        # * belongs_to :group
        # * validates_presence_of :username
        # * validates_uniqueness_of :username
        # * sets up validation to check that password and password_confirmation
        #   match if either are set (to something that is not blank)
        # * sets up after_validation callbacks to clear password and password_confirmation.
        #   If there were no errors on password, they password_hash will be set to the hash
        #   value of password
        # * Adds methods from LWT::AuthenticationSystem::Model::InstanceMethods
        # * Adds methods from LWT::AuthenticationSystem::Model::SingletonMethods
        #
        # Valid options:
        # - :password_validation - Error message used when the passwords do not match.
        #   If this check is not desired, set this to false or nil.
        #   Default: "Passwords must match"
        # - :username_validation - Error message used when the username is blank.
        #   If this check is not desired, set this to false or nil.
        #   Default: "Username cannot be blank"
        # - :username_unique_validation - Error message used when the username is
        #   already in use. If this check is not desired, set to false or nil.
        #   Default: "Username has already been taken"
        # - :use_salt - If true, the hash_password method will be sent a salt along with a
        #   password. The salt will be stored in database column salt. Defaults: false
        def acts_as_login_model options = {}
          include LWT::AuthenticationSystem::Model::InstanceMethods
          extend LWT::AuthenticationSystem::Model::SingletonMethods

          self.lwt_authentication_system_options = {
            :group_validation => "Group cannot be blank",
            :password_validation => "Passwords must match",
            :username_validation => "Username cannot be blank",
            :username_unique_validation => "Username has already been taken",
            :use_salt => false
          }.merge( options )

          hash_password do |password, salt|
            require 'md5'
            MD5.hexdigest( password )
          end

          belongs_to :group

          if msg = lwt_authentication_system_options[:group_validation]
            validates_presence_of :group_id, :message => msg
          end

          if msg = lwt_authentication_system_options[:username_validation]
            validates_presence_of :username, :message => msg
          end

          if msg = lwt_authentication_system_options[:username_unique_validation]
            validates_uniqueness_of :username, :message => msg
          end

          if msg = self.lwt_authentication_system_options[:password_validation]
            validate do |user|
              if ( user.password or user.password_confirmation ) and user.password != user.password_confirmation
                user.errors.add( :password, msg )
                false
              else
                true
              end
            end
          end
          
          after_validation do |user|
            if user.password and user.errors.on( :password ).nil?
              args = [ user.password ]
              args << user.salt if self.lwt_authentication_system_options[:use_salt]
              user.password_hash = self.hash_password( *args )
            end
            user.password = user.password_confirmation = nil
            true
          end
        end
      end

      module SingletonMethods
        attr_accessor :current_user, :lwt_authentication_system_options

        # Attempts to find a user by the passed in attributes. The param :password will
        # be removed and will be checked against the password of the user found (if any).
        def login params
          password = params.delete( :password )
          user = self.find :first, :conditions => params, :include => { :group => :privileges }
          return nil unless user

          args = [ password ]
          args << user.salt if self.lwt_authentication_system_options[:use_salt]
          self.hash_password( *args ) == user.password_hash ? user : nil
        end

        # This method does two things:
        # - If given a block, that blocked is stored and used when hashing the users password.
        #   When the block is called, it will be given the password and the salt, if enabled.
        # - Else, the stored block is called, giving passing it all arguments
        def hash_password( *args, &blk )
          if blk
            self.lwt_authentication_system_options[:hash_password] = blk
          else
            self.lwt_authentication_system_options[:hash_password].call *args
          end
        end
      end

      module InstanceMethods
        attr_reader :password, :password_confirmation

        # Sets the users password. This will be itnored if the value is blank.
        # This value is cleared out in an after_validate callback. If there
        # were not errors on the password attribute, then password_hash will be
        # set to the hash of this password.
        def password=( password )
          @password = password.blank? ? nil : password
        end

        # Sets the users password_confirmation. This will be itnored if the value is blank
        # This value is cleared out in an after_validate callback.
        def password_confirmation=( password )
          @password_confirmation = password.blank? ? nil : password
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
