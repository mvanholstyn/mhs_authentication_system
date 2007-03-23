require File.join( File.dirname( __FILE__ ), 'boot' )

context "A non validating LWT::AuthenticationSystem model" do

  specify "should not validate presence of group_id" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn'
    user.should.be.valid
    user.errors.on( :group_id ).should.be.nil
    
    user.group_id = 1
    user.should.be.valid
    user.errors.on( :group_id ).should.be.nil
  end
  
  specify "should not validate presence of username" do
    user = NonValidatingLwtAuthenticationSystemUser.new :group_id => 1
    user.should.be.valid
    user.errors.on( :username ).should.be.nil
    
    user.username = 'mvanholstyn'
    user.should.be.valid
    user.errors.on( :username ).should.be.nil
  end
  
  specify "should not validate uniqueness of username" do
    mvanholstyn = NonValidatingLwtAuthenticationSystemUser.create! :username => 'mvanholstyn', :group_id => 1
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1

    user.should.be.valid
    user.errors.on( :username ).should.be.nil
    
    user.username = 'zdennis'
    user.should.be.valid
    user.errors.on( :username ).should.be.nil
    
    # TODO: Refactor this...
    NonValidatingLwtAuthenticationSystemUser.delete_all
  end

  specify "should not validate password and password confirmation match" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1

    user.should.be.valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should.be.valid
    user.errors.on( :password ).should.be.nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should.be.valid
    user.errors.on( :password ).should.be.nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should.be.valid
    user.errors.on( :password ).should.be.nil
  end
  
  specify "should clean password and password_confirmation after validations" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1

    user.should.be.valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should.be.valid
    user.password.should.be.nil
    user.password_confirmation.should.be.nil

    user.password = ''
    user.password_confirmation = 'password'
    user.should.be.valid
    user.password.should.be.nil
    user.password_confirmation.should.be.nil

    user.password = 'password'
    user.password_confirmation = 'password'
    user.should.be.valid
    user.password.should.be.nil
    user.password_confirmation.should.be.nil
  end

  specify "should set password_hash" do
    user = NonValidatingLwtAuthenticationSystemUser.new :username => 'mvanholstyn', :group_id => 1

    user.should.be.valid
    
    user.password = 'password'
    user.password_confirmation = ''
    user.should.be.valid
    user.password_hash.should.not.be.nil

    user.password_hash = nil
    user.password = ''
    user.password_confirmation = 'password'
    user.should.be.valid
    user.password_hash.should.be.nil

    user.password_hash = nil
    user.password = 'password'
    user.password_confirmation = 'password'
    user.should.be.valid
    user.password_hash.should.not.be.nil
  end
  
end
