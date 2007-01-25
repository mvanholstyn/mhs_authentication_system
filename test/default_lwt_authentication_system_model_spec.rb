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
  
  specify "should validate presence of username" do
    user = LwtAuthenticationSystemUser.new
    user.should.not.be.valid
    user.errors.on( :username ).should.not.be.nil
    user.errors.on( :username ).should == "Username cannot be blank"
    
    user.username = 'mvanholstyn'
    user.should.be.valid
    user.errors.on( :username ).should.be.nil
  end
  
  specify "should validate uniqueness of username" do
    mvanholstyn = LwtAuthenticationSystemUser.create! :username => 'mvanholstyn'
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn'

    user.should.not.be.valid
    user.errors.on( :username ).should.not.be.nil
    user.errors.on( :username ).should == "Username has already been taken"
    
    user.username = 'zdennis'
    user.should.be.valid
    user.errors.on( :username ).should.be.nil
    
    # TODO: Refactor this...
    LwtAuthenticationSystemUser.delete_all
  end

  specify "should validate password and password confirmation match only if one of them is given" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn'

    user.should.be.valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should.not.be.valid
    user.errors.on( :password ).should.not.be.nil
    user.errors.on( :password ).should == "Passwords must match"

    user.password = ''
    user.password_confirmation = 'password'
    user.should.not.be.valid
    user.errors.on( :password ).should.not.be.nil
    user.errors.on( :password ).should == "Passwords must match"

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should.be.valid
    user.errors.on( :password ).should.be.nil
  end
  
  specify "should clean password and password_confirmation after validations" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn'

    user.should.be.valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should.not.be.valid
    user.password.should.be.nil
    user.password_confirmation.should.be.nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should.not.be.valid
    user.password.should.be.nil
    user.password_confirmation.should.be.nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should.be.valid
    user.password.should.be.nil
    user.password_confirmation.should.be.nil
  end

  specify "should set password_hash after validations, if they are successful" do
    user = LwtAuthenticationSystemUser.new :username => 'mvanholstyn'

    user.should.be.valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should.not.be.valid
    user.password_hash.should.be.nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should.not.be.valid
    user.password_hash.should.be.nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should.be.valid
    user.password_hash.should.not.be.nil
  end
  
end
