require File.join(File.dirname(__FILE__), '../spec_helper')

describe MhsAuthenticationSystemModel, "responds to methods added by Mhs::AuthenticationSystem::Model::ClassMethods" do
  it "responds to acts_as_login_model" do
    MhsAuthenticationSystemModel.should respond_to(:acts_as_login_model)
  end
end

describe MhsAuthenticationSystemModel, "responds to methods added by Mhs::AuthenticationSystem::Model::SingletonMethods" do
  it "responds to current_user" do
    MhsAuthenticationSystemModel.should respond_to(:current_user)
  end
  
  it "responds to mhs_authentication_system_options" do
    MhsAuthenticationSystemModel.should respond_to(:mhs_authentication_system_options)
  end
  
  it "responds to login" do
    MhsAuthenticationSystemModel.should respond_to(:login)
  end
  
  it "responds to hash_password" do
    MhsAuthenticationSystemModel.should respond_to(:hash_password)
  end
end


describe MhsAuthenticationSystemModel, "instance responds to methods added by Mhs::AuthenticationSystem::Model::InstanceMethods" do
  it "responds to role=" do
    MhsAuthenticationSystemModel.new.should respond_to(:role=)
  end

  it "responds to password" do
    MhsAuthenticationSystemModel.new.should respond_to(:password)
  end
  
  it "responds to password_confirmation" do
    MhsAuthenticationSystemModel.new.should respond_to(:password_confirmation)
  end

  it "responds to password=" do
    MhsAuthenticationSystemModel.new.should respond_to(:password=)
  end
  
  it "responds to password_confirmation=" do
    MhsAuthenticationSystemModel.new.should respond_to(:password_confirmation=)
  end
  
  it "responds to has_privilege?" do
    MhsAuthenticationSystemModel.new.should respond_to(:has_privilege?)
  end
  
  it "responds to remember_me!" do
    MhsAuthenticationSystemModel.new.should respond_to(:remember_me!)
  end
  
  it "responds to forget_me!" do
    MhsAuthenticationSystemModel.new.should respond_to(:forget_me!)
  end
end

describe MhsAuthenticationSystemModel, "responds to methods added by database schema" do
  
  it "responds to password_hash" do
    MhsAuthenticationSystemModel.new.should respond_to(:password_hash)
  end
  
  it "responds to role_id" do
    MhsAuthenticationSystemModel.new.should respond_to(:role_id)
  end
  
  it "responds to email_address" do
    MhsAuthenticationSystemModel.new.should respond_to(:email_address)
  end
  
  it "responds to active" do
    MhsAuthenticationSystemModel.new.should respond_to(:active)
  end
  
  it "responds to salt" do
    MhsAuthenticationSystemModel.new.should respond_to(:salt)
  end
  
  it "responds to remember_me_token" do
    MhsAuthenticationSystemModel.new.should respond_to(:remember_me_token)
  end
  
  it "responds to remember_me_token_expires_at" do
    MhsAuthenticationSystemModel.new.should respond_to(:remember_me_token_expires_at)
  end
end

describe MhsAuthenticationSystemModel, "acts_as_login_model" do
  it "acts_as_login_model"
end

describe MhsAuthenticationSystemModel, "validations" do
  it "validates the presences of a role id" do
    model = MhsAuthenticationSystemModel.new
    model.should_not be_valid
    model.errors.on(:role_id).should == "can't be blank"
  end
  
  it "validates the presences of a email address" do
    model = MhsAuthenticationSystemModel.new
    model.should_not be_valid
    model.errors.on(:email_address).should == "can't be blank"
  end
  
  it "validates the uniqueness of a email address" do
    saved_model = MhsAuthenticationSystemModel.create! :email_address => "user@example.com", :role_id => 1, :password => "password", :password_confirmation => "password"
    model = MhsAuthenticationSystemModel.new :email_address => "user@example.com"
    model.should_not be_valid
    model.errors.on(:email_address).should == "has already been taken"
    saved_model.destroy
  end
  
  it "validates the confirmation of the password" do
    model = MhsAuthenticationSystemModel.new :password => "password", :password_confirmation => "pass"
    model.should_not be_valid
    model.errors.on(:password).should == "must match"
  end
end

describe MhsAuthenticationSystemModel, "hash_password" do
  it "hash_password returns SHA1 hash of password and salt" do
    MhsAuthenticationSystemModel.hash_password("password", "salt").should == "81c35bdfd7b6bc8878248ae59671c396aa519764"
  end
  
  it "hash_password sets hash_password method when passed a block" do
    original_hash_password_method = MhsAuthenticationSystemModel.mhs_authentication_system_options[:hash_password]
    MhsAuthenticationSystemModel.hash_password { |p| p }
    MhsAuthenticationSystemModel.mhs_authentication_system_options[:hash_password].should_not == original_hash_password_method
    MhsAuthenticationSystemModel.hash_password("password").should == "password"
    
    # Reset original hash_password method
    MhsAuthenticationSystemModel.hash_password &original_hash_password_method
  end
end

describe MhsAuthenticationSystemModel, "login" do
  before(:all) do
    @model = MhsAuthenticationSystemModel.new :email_address => "user@example.com", :password => "password", :password_confirmation => "password"
    @model.save_without_validation
  end
  
  it "with invalid email_address returns nil" do
    model = MhsAuthenticationSystemModel.login :email_address => "wrong_user@example.com", :password => "password"
    model.should be_nil
  end
  
  it "with invalid password returns nil" do
    model = MhsAuthenticationSystemModel.login :email_address => "user@example.com", :password => "wrong password"
    model.should be_nil
  end

  it "with valid email_address and password returns the model" do
    model = MhsAuthenticationSystemModel.login :email_address => "user@example.com", :password => "password"
    model.should == @model
  end
  
  it "with nil returns nil" do
    model = MhsAuthenticationSystemModel.login nil
    model.should be_nil
  end
  
  it "with empty hash returns nil" do
    model = MhsAuthenticationSystemModel.login({})
    model.should be_nil
  end
end

describe MhsAuthenticationSystemModel, "password/password_confirmation readers/writers" do
  before(:each) do
    @model = MhsAuthenticationSystemModel.new
  end
  
  it "password returns nil when @password is nil" do
    @model.instance_variable_set("@password", nil)
    @model.password.should be_nil
  end
  
  it "password returns nil when @password is not nil" do
    @model.instance_variable_set("@password", "some password")
    @model.password.should be_nil
  end
  
  it "password_confirmation returns nil when @password_confirmation is nil" do
    @model.instance_variable_set("@password_confirmation", nil)
    @model.password_confirmation.should be_nil
  end
  
  it "password_confirmation returns nil when @password_confirmation is not nil" do
    @model.instance_variable_set("@password_confirmation", "some password")
    @model.password_confirmation.should be_nil
  end
  
  it "password= sets @password to nil when value is blank" do
    [ nil, "" ].each do |value|
      @model.password = value
      @model.instance_variable_get("@password").should be_nil
    end
  end
  
  it "password= sets @password to value when value is not blank" do
    @model.password = "some password"
    @model.instance_variable_get("@password").should_not be_nil
  end
  
  it "password_confirmation= sets @password_confirmation to nil when value is blank" do
    [ nil, "" ].each do |value|
      @model.password_confirmation = value
      @model.instance_variable_get("@password_confirmation").should be_nil
    end
  end
  
  it "password_confirmation= sets @password_confirmation to value when value is not blank" do
    @model.password_confirmation = "some password"
    @model.instance_variable_get("@password_confirmation").should_not be_nil
  end
end

describe MhsAuthenticationSystemModel, "has_privilege?" do
  before(:each) do
    role = Role.create! :name => "admin"
    admin_privilege = Privilege.create! :name => "admin"
    super_admin_privilege = Privilege.create! :name => "super_admin"
    role.privileges << admin_privilege << super_admin_privilege 
    @model = MhsAuthenticationSystemModel.new :role => role
  end

  it "returns false if user does not have a role" do
    MhsAuthenticationSystemModel.new.has_privilege?(:admin).should be_false
  end

  it "returns false if user does not have the specified privilege" do
    @model.has_privilege?(:blogger).should be_false
  end

  it "returns false if user does not have any the specified privileges" do
    @model.has_privilege?(:blogger, :commenter).should be_false
  end

  it "returns true if user has the specified privilege" do
    @model.has_privilege?(:admin).should be_true
  end

  it "returns true if user has any of the specified privileges" do
    @model.has_privilege?(:admin, :blogger).should be_true
  end

  it "returns false if user does not have all of the specified privileges when match_all is true" do
    @model.has_privilege?(:admin, :blogger, :match_all => true).should be_false
  end

  it "returns true if user has all of the specified privileges when match_all is true" do
    @model.has_privilege?(:admin, :super_admin, :match_all => true).should be_true
  end
end