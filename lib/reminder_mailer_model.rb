if( UserReminderMailer rescue true )
  class ::UserReminderMailer < ActionMailer::Base
  end
end

UserReminderMailer.class_eval do
  def forgot_password(user, reminder, url)
    recipients user.email_address
#    from ""
    subject "Reminder"
    
    body :user => user, :reminder => reminder, :url => url
  end
end