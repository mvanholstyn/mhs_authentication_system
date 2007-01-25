module LWT
  module AuthenticationSystem
    module Model

      def self.included( base )
        base.extend ClassMethods
      end

      module ClassMethods
        # Setups this model as the one which is use for authentication
        #
        # Valid options:
        # - :password_validation_message - Error message used when the passwords do not match.
        #   Default: "Passwords must match"
        # - :username_validation_message - Error message used when the username is blank.
        #   Default: "Username cannot be blank"
        # - :username_unique_validation_message - Error message used when the username is
        #   already in use. Default: "Username has already been taken"
        # - :use_salt - If true, the hash_password method will be sent a salt along with a
        #   password. The salt will be stored in database column salt. Defaults: false
        def acts_as_login_model options = {}
          include LWT::AuthenticationSystem::Model::InstanceMethods
          extend LWT::AuthenticationSystem::Model::SingletonMethods

          self.lwt_authentication_system_options = {
            :password_validation_message => "Passwords must match",
            :username_validation_message => "Username cannot be blank",
            :username_unique_validation_message => "Username has already been taken",
            :use_salt => false
          }.merge( options )

          hash_password do |password, salt|
            require 'md5'
            MD5.hexdigest( password )
          end

          belongs_to :group
          validates_presence_of :username,
                    :message => lwt_authentication_system_options[:username_validation_message]
          validates_uniqueness_of :username,
                    :message => lwt_authentication_system_options[:username_unique_validation_message]
          validates_confirmation_of :password,
                    :message => lwt_authentication_system_options[:password_validation_message]
          
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
        attr_accessor :password, :password_confirmation

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
