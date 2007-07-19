map.with_options :controller => "users" do |users_map|
  users_map.login "login", :action => "login"
  users_map.logout "logout", :action => "logout"
  users_map.reminder "reminder", :action => "reminder"
  users_map.profile "profile", :action => "profile"
  users_map.signup "signup", :action => "signup"
end