class LwtAuthenticationSystemGenerator < Rails::Generator::Base

  #TODO: Add migration, views, application controller, customization
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "User", "UsersController"

      # Model, view, controller, and migration directories
      m.directory File.join( 'app/models' )
      m.directory File.join( 'app/controllers' )
      m.directory File.join( 'app/views/users' )
      m.directory File.join( 'db/migrate' )

      # Model class
      m.template 'model.rb', File.join( 'app/models', "user.rb" )

      # Login controller
      m.template 'login_controller.rb', File.join( 'app/controllers', "users_controller.rb")

      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "add_lwt_authentication_system"
    end
  end

end
