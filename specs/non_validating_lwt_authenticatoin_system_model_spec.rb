require File.join( File.dirname( __FILE__ ), 'boot' )

context "A non validating LWT::AuthenticationSystem model" do

  specify "should not validate presence of group_id" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :email_address => 'mvanholstyn@gmail.com'
    user.should be_valid
    user.errors.on( :group_id ).should be_nil
    
    user.group_id = 1
    user.should be_valid
    user.errors.on( :group_id ).should be_nil
  end
  
  specify "should not validate presence of username" do
    user = NonValidatingLwtAuthenticationSystemUser.new :group_id => 1, :email_address => 'mvanholstyn@gmail.com'
    user.should be_valid
    user.errors.on( :username ).should be_nil
    
    user.username = 'mvanholstyn'
    user.should be_valid
    user.errors.on( :username ).should be_nil
  end
  
  specify "should not validate uniqueness of username" do
    mvanholstyn = NonValidatingLwtAuthenticationSystemUser.create! :username => 'mvanholstyn', :group_id => 1, :email_address => 'mvanholstyn@gmail.com'
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => 'zdennis@gmail.com'

    user.should be_valid
    user.errors.on( :username ).should be_nil
    
    user.username = 'zdennis'
    user.should be_valid
    user.errors.on( :username ).should be_nil
    
    # TODO: Refactor this...
    NonValidatingLwtAuthenticationSystemUser.delete_all
  end

  specify "should not validate presence of email_address" do
    user = NonValidatingLwtAuthenticationSystemUser.new :group_id => 1, :username => "mvanholstyn"
    user.should be_valid
    user.errors.on( :email_address ).should be_nil
    
    user.email_address = 'mvanholstyn@gmail.com'
    user.should be_valid
    user.errors.on( :email_address ).should be_nil
  end
  
  specify "should not validate uniqueness of email_address" do
    mvanholstyn = NonValidatingLwtAuthenticationSystemUser.create! :username => 'mvanholstyn', :group_id => 1, :email_address => "mvanholstyn@gmail.com"
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'zdennis', :group_id => 1, :email_address => "mvanholstyn@gmail.com"

    user.should be_valid
    user.errors.on( :email_address ).should be_nil
    
    user.email_address = 'zdennis@gmail.com'
    user.should be_valid
    user.errors.on( :email_address ).should be_nil
    
    # TODO: Refactor this...
    NonValidatingLwtAuthenticationSystemUser.delete_all
  end

  specify "should not validate password and password confirmation match" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => 'mvanholstyn@gmail.com'

    user.should be_valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should be_valid
    user.errors.on( :password ).should be_nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should be_valid
    user.errors.on( :password ).should be_nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should be_valid
    user.errors.on( :password ).should be_nil
  end
  
  specify "should clean password and password_confirmation after validations" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => 'mvanholstyn@gmail.com'

    user.should be_valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should be_valid
    user.password.should be_nil
    user.password_confirmation.should be_nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should be_valid
    user.password.should be_nil
    user.password_confirmation.should be_nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should be_valid
    user.password.should be_nil
    user.password_confirmation.should be_nil
  end

  specify "should set password_hash" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1, :email_address => 'mvanholstyn@gmail.com'

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should be_valid
    user.save.should == true
    user.password_hash.should_not be_nil
  end
  
end
