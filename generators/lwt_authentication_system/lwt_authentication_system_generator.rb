class LwtAuthenticationSystemGenerator < Rails::Generator::Base

  #TODO: update classes of they exists?
  #TODO: Add routes?
  #TODO: Add tests
  def manifest
    record do |m|
      m.class_collisions *%w{ Privilege Group GroupPrivilege User UsersController }

      m.directory File.join( *%w{ app models } )
      m.directory File.join( *%w{ app controllers } )
      m.directory File.join( *%w{ app views users } )
      m.directory File.join( *%w{ db migrate } )
      m.directory File.join( *%w{ test fixtures } )

      m.template 'model.rb', File.join( *%w{ app models user.rb } )
      m.template 'login_controller.rb', File.join( *%w{ app controllers users_controller.rb } )
      m.template 'login.erb', File.join( *%W{ app views users login.erb } )
      m.template 'privileges.yml', File.join( *%w{ test fixtures privileges.yml } )
      m.template 'groups.yml', File.join( *%w{ test fixtures groups.yml } )
      m.template 'groups_privileges.yml', File.join( *%w{ test fixtures groups_privileges.yml } )
      m.template 'users.yml', File.join( *%w{ test fixtures users.yml } )
      m.migration_template 'migration.rb', File.join( *%w{ db migrat } ), :migration_file_name => "add_lwt_authentication_system"
    end
  end
end
