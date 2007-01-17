class LwtAuthenticationSystemGenerator < Rails::Generator::Base

  #TODO: Add migration, views, application controller, customization (login controller, redirect after login, model)
  #TODO: update classes of they exists?
  def manifest
    record do |m|
      m.class_collisions "User", "UsersController"

      m.directory File.join( 'app/models' )
      m.directory File.join( 'app/controllers' )
      m.directory File.join( 'app/views/users' )
      m.directory File.join( 'db/migrate' )

      m.template 'model.rb', File.join( 'app/models', "user.rb" )
      m.template 'login_controller.rb', File.join( 'app/controllers', "users_controller.rb")
      m.template 'login.rhtml', File.join( 'app/views/users', "login.rhtml")
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "add_lwt_authentication_system"
    end
  end

end
