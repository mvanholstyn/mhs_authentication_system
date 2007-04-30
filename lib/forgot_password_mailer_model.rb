if( ForgotPasswordMailer rescue true )
  class ::ForgotPasswordMailer < ActionMailer::Base
  end
end

ForgotPasswordMailer.class_eval do
  def forgot_password(user, forgot_password, url)
    recipients user.email_address
#    from ""
    subject "Forgot Password"
    
    body :user => user, :forgot_password => forgot_password, :url => url
  end
end