require File.join( File.dirname( __FILE__ ), 'boot' )

context "A normal ActiveRecord model" do

  specify "should respond to class.acts_as_login_model" do 
    NormalUser.should.respond_to :acts_as_login_model
  end
  
  specify "should not respond to class.current_user" do
    NormalUser.should.not.respond_to :current_user
  end

  specify "should not respond to class.lwt_authentication_system_options" do
    NormalUser.should.not.respond_to :lwt_authentication_system_options
  end

  specify "should not respond to class.login" do
    NormalUser.should.not.respond_to :login
  end

  specify "should not respond to class.hash_password" do
    NormalUser.should.not.respond_to :hash_password
  end

  specify "should not respond to class.validate_password" do
    NormalUser.should.not.respond_to :validate_password
  end

  specify "should not respond to instance.password" do
    NormalUser.new.should.not.respond_to :password
  end

  specify "should not respond to instance.password_confirmation" do
    NormalUser.new.should.not.respond_to :password_confirmation
  end

  specify "should not respond to instance.has_privilege?" do
    NormalUser.new.should.not.respond_to :has_privilege?
  end

  specify "should not respond to instance.password=" do
    NormalUser.new.should.not.respond_to :password=
  end

  specify "should not respond to instance.password_confirmation=" do
    NormalUser.new.should.not.respond_to :password=
  end

  specify "should not respond to instance.password_confirmation=" do
    NormalUser.new.should.not.respond_to :password_confirmation=
  end

  specify "should not respond to instance.validate_password" do
    NormalUser.new.should.not.respond_to :validate_password
  end
  
end

context "An Lwt Authentication System ActiveRecord model" do

  specify "should respond to class.acts_as_login_model" do 
    LwtAuthenticationSystemUser.should.respond_to :acts_as_login_model
  end
  
  specify "should respond to class.current_user" do
    LwtAuthenticationSystemUser.should.respond_to :current_user
  end

  specify "should respond to class.lwt_authentication_system_options " do
    LwtAuthenticationSystemUser.should.respond_to :lwt_authentication_system_options
  end

  specify "should respond to class.login " do
    LwtAuthenticationSystemUser.should.respond_to :login
  end

  specify "should respond to class.hash_password " do
    LwtAuthenticationSystemUser.should.respond_to :hash_password
  end

  specify "should respond to class.validate_password " do
    LwtAuthenticationSystemUser.should.respond_to :validate_password
  end
  
  specify "should respond to instance.password" do
    LwtAuthenticationSystemUser.new.should.respond_to :password
  end

  specify "should respond to instance.password_confirmation" do
    LwtAuthenticationSystemUser.new.should.respond_to :password_confirmation
  end

  specify "should respond to instance.has_privilege?" do
    LwtAuthenticationSystemUser.new.should.respond_to :has_privilege?
  end

  specify "should respond to instance.password=" do
    LwtAuthenticationSystemUser.new.should.respond_to :password=
  end

  specify "should respond to instance.password_confirmation=" do
    LwtAuthenticationSystemUser.new.should.respond_to :password=
  end

  specify "should respond to instance.password_confirmation=" do
    LwtAuthenticationSystemUser.new.should.respond_to :password_confirmation=
  end

  specify "should respond to instance.validate_password" do
    LwtAuthenticationSystemUser.new.should.respond_to :validate_password
  end
  
end
