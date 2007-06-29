  map.with_options :controller => "users" do |users_map|
    users_map.login "login", :action => "login"
    users_map.logout "logout", :action => "logout"
    users_map.reminder "reminder", :action => "reminder"
    users_map.reminder_login "reminder_login", :action => "reminder_login"
    # users_map.signup "signup", :action => "signup"
  end