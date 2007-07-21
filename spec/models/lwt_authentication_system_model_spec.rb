require File.join( File.dirname( __FILE__ ), '../spec_helper' )

describe LWTAuthenticationSystemModel, "responds to methods added by LWT::AuthenticationSystem::Model::ClassMethods" do
  it "responds to acts_as_login_model" do
    LWTAuthenticationSystemModel.should respond_to(:acts_as_login_model)
  end
end

describe LWTAuthenticationSystemModel, "responds to methods added by LWT::AuthenticationSystem::Model::SingletonMethods" do
  it "responds to current_user" do
    LWTAuthenticationSystemModel.should respond_to(:current_user)
  end
  
  it "responds to lwt_authentication_system_options" do
    LWTAuthenticationSystemModel.should respond_to(:lwt_authentication_system_options)
  end
  
  it "responds to login" do
    LWTAuthenticationSystemModel.should respond_to(:login)
  end
  
  it "responds to hash_password" do
    LWTAuthenticationSystemModel.should respond_to(:hash_password)
  end
end


describe LWTAuthenticationSystemModel, "instance responds to methods added by LWT::AuthenticationSystem::Model::InstanceMethods" do
  it "responds to group=" do
    LWTAuthenticationSystemModel.new.should respond_to(:group=)
  end

  it "responds to password" do
    LWTAuthenticationSystemModel.new.should respond_to(:password)
  end
  
  it "responds to password_confirmation" do
    LWTAuthenticationSystemModel.new.should respond_to(:password_confirmation)
  end

  it "responds to password=" do
    LWTAuthenticationSystemModel.new.should respond_to(:password=)
  end
  
  it "responds to password_confirmation=" do
    LWTAuthenticationSystemModel.new.should respond_to(:password_confirmation=)
  end
  
  it "responds to has_privilege?" do
    LWTAuthenticationSystemModel.new.should respond_to(:has_privilege?)
  end
end

describe LWTAuthenticationSystemModel, "responds to methods added by database schema" do
  
  it "responds to username" do
    LWTAuthenticationSystemModel.new.should respond_to(:username)
  end
  
  it "responds to password_hash" do
    LWTAuthenticationSystemModel.new.should respond_to(:password_hash)
  end
  
  it "responds to group_id" do
    LWTAuthenticationSystemModel.new.should respond_to(:group_id)
  end
  
  it "responds to email_address" do
    LWTAuthenticationSystemModel.new.should respond_to(:email_address)
  end
  
  it "responds to active" do
    LWTAuthenticationSystemModel.new.should respond_to(:active)
  end
end