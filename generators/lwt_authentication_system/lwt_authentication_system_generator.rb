class LwtAuthenticationSystemGenerator < Rails::Generator::Base

  #TODO: update classes of they exists?
  #TODO: Add routes?
  #TODO: Add tests
  def manifest
    record do |m|
      #m.class_collisions *%w{ UsersController Privilege Group GroupPrivilege User ForgotPassword ForgotPasswordMailer }

      m.directory File.join( *%w{ app controllers } )
      m.directory File.join( *%w{ app models } )
      m.directory File.join( *%w{ app views forgot_password_mailer } )
      m.directory File.join( *%w{ app views users } )
      m.directory File.join( *%w{ test fixtures } )
      m.directory File.join( *%w{ db migrate } )

      m.template 'app/controllers/login_controller.rb', File.join( *%w{ app controllers users_controller.rb } )
      m.template 'app/models/model.rb', File.join( *%w{ app models user.rb } )
      m.template 'app/views/forgot_password_mailer/forgot_password.erb', File.join( *%W{ app views forgot_password_mailer forgot_password.erb } )
      m.template 'app/views/users/change_password.erb', File.join( *%W{ app views users change_password.erb } )
      m.template 'app/views/users/forgot_password.erb', File.join( *%W{ app views users forgot_password.erb } )
      m.template 'app/views/users/login.erb', File.join( *%W{ app views users login.erb } )
      m.template 'test/fixtures/groups.yml', File.join( *%w{ test fixtures groups.yml } )
      m.template 'test/fixtures/groups_privileges.yml', File.join( *%w{ test fixtures groups_privileges.yml } )
      m.template 'test/fixtures/privileges.yml', File.join( *%w{ test fixtures privileges.yml } )
      m.template 'test/fixtures/users.yml', File.join( *%w{ test fixtures users.yml } )
      m.migration_template 'migration.rb', File.join( *%w{ db migrate } ), :migration_file_name => "add_lwt_authentication_system"
    end
  end
end
