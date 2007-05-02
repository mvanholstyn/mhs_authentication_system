require File.join( File.dirname( __FILE__ ), 'boot' )

context "A default LWT::AuthenticationSystem model" do

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
    LwtAuthenticationSystemUser.new.should.respond_to :password_confirmation=
  end

  specify "should respond to instance.group" do
    LwtAuthenticationSystemUser.new.should.respond_to :group
  end

  specify "should respond to instance.username" do
    LwtAuthenticationSystemUser.new.should.respond_to :username
  end

  specify "should respond to instance.password_hash" do
    LwtAuthenticationSystemUser.new.should.respond_to :password_hash
  end
  
  specify "should not respond to instance.email_address" do
    LwtAuthenticationSystemUser.new.should.respond_to :email_address
  end
  
  specify "should validate presence of group_id" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn', :email_address => "mvanholstyn@gmail.com"
    user.should_not be_valid
    user.errors.on( :group_id ).should_not be_nil
    user.errors.on( :group_id ).should == "cannot be blank"
    
    user.group_id = 1
    user.should be_valid
    user.errors.on( :group_id ).should be_nil
  end
  
  specify "should validate presence of username" do
    user = LwtAuthenticationSystemUser.new :group_id => 1, :email_address => "mvanholstyn@gmail.com"
    user.should_not be_valid
    user.errors.on( :username ).should_not be_nil
    user.errors.on( :username ).should == "cannot be blank"
    
    user.username = 'mvanholstyn'
    user.should be_valid
    user.errors.on( :username ).should be_nil
  end
  
  specify "should validate uniqueness of username" do
    mvanholstyn = LwtAuthenticationSystemUser.create! :username => 'mvanholstyn', :group_id => 1, :email_address => "mvanholstyn@gmail.com"
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => "zdennis@gmail.com"

    user.should_not be_valid
    user.errors.on( :username ).should_not be_nil
    user.errors.on( :username ).should == "has already been taken"
    
    user.username = 'zdennis'
    user.should be_valid
    user.errors.on( :username ).should be_nil
    
    # TODO: Refactor this...
    LwtAuthenticationSystemUser.delete_all
  end

  specify "should validate presence of email_address" do
    user = LwtAuthenticationSystemUser.new :group_id => 1, :username => "mvanholstyn"
    user.should_not be_valid
    user.errors.on( :email_address ).should_not be_nil
    user.errors.on( :email_address ).should == "cannot be blank"
    
    user.email_address = 'mvanholstyn@gmail.com'
    user.should be_valid
    user.errors.on( :email_address ).should be_nil
  end
  
  specify "should validate uniqueness of email_address" do
    mvanholstyn = LwtAuthenticationSystemUser.create! :username => 'mvanholstyn', :group_id => 1, :email_address => "mvanholstyn@gmail.com"
    user = LwtAuthenticationSystemUser.new :username => 'zdennis', :group_id => 1, :email_address => "mvanholstyn@gmail.com"

    user.should_not be_valid
    user.errors.on( :email_address ).should_not be_nil
    user.errors.on( :email_address ).should == "has already been taken"
    
    user.email_address = 'zdennis@gmail.com'
    user.should be_valid
    user.errors.on( :email_address ).should be_nil
    
    # TODO: Refactor this...
    LwtAuthenticationSystemUser.delete_all
  end

  specify "should validate password and password confirmation match only if one of them is given" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => "mvanholstyn@gmail.com"

    user.should be_valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should_not be_valid
    user.errors.on( :password ).should_not be_nil
    user.errors.on( :password ).should == "must match"

    user.password = ''
    user.password_confirmation = 'password'
    user.should_not be_valid
    user.errors.on( :password ).should_not be_nil
    user.errors.on( :password ).should == "must match"

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should be_valid
    user.errors.on( :password ).should be_nil
  end
  
  specify "should clean password and password_confirmation after validations" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => "mvanholstyn@gmail.com"

    user.should be_valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should_not be_valid
    user.password.should be_nil
    user.password_confirmation.should be_nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should_not be_valid
    user.password.should be_nil
    user.password_confirmation.should be_nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should be_valid
    user.password.should be_nil
    user.password_confirmation.should be_nil
  end

  specify "should set password_hash before save" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => "mvanholstyn@gmail.com"

    user.should be_valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should_not be_valid
    user.save.should == false
    user.password_hash.should be_nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should_not be_valid
    user.save.should == false
    user.password_hash.should be_nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should be_valid
    user.save.should == true
    user.password_hash.should_not be_nil
  end
  
end
