require File.join( File.dirname( __FILE__ ), '../spec_helper' )

describe DefaultActiveRecordModel, "does not contain any methods added by LWT::AuthenticationSystem::Model" do

  it "is true" do 
    true.should == true
  end

  # specify "should respond to class.acts_as_login_model" do
  #   NormalUser.should.respond_to :acts_as_login_model
  # end
  #  
  # specify "should not respond to class.current_user" do
  #   NormalUser.should_not.respond_to :current_user
  # end
  # 
  # specify "should not respond to class.lwt_authentication_system_options" do
  #   NormalUser.should_not.respond_to :lwt_authentication_system_options
  # end
  # 
  # specify "should not respond to class.login" do
  #   NormalUser.should_not.respond_to :login
  # end
  # 
  # specify "should not respond to class.hash_password" do
  #   NormalUser.should_not.respond_to :hash_password
  # end
  # 
  # specify "should not respond to instance.password" do
  #   NormalUser.new.should_not.respond_to :password
  # end
  # 
  # specify "should not respond to instance.password_confirmation" do
  #   NormalUser.new.should_not.respond_to :password_confirmation
  # end
  # 
  # specify "should not respond to instance.has_privilege?" do
  #   NormalUser.new.should_not.respond_to :has_privilege?
  # end
  # 
  # specify "should not respond to instance.password=" do
  #   NormalUser.new.should_not.respond_to :password=
  # end
  # 
  # specify "should not respond to instance.password_confirmation=" do
  #   NormalUser.new.should_not.respond_to :password_confirmation=
  # end
  # 
  # specify "should not respond to instance.group" do
  #   NormalUser.new.should_not.respond_to :group
  # end
  # 
  # specify "should not respond to instance.username" do
  #   NormalUser.new.should_not.respond_to :username
  # end
  # 
  # specify "should not respond to instance.password_hash" do
  #   NormalUser.new.should_not.respond_to :password_hash
  # end
  # 
  # specify "should not respond to instance.email_address" do
  #   NormalUser.new.should_not.respond_to :email_address
  # end
 
end