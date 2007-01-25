ActiveRecord::Schema.define do

  create_table :groups, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :privileges, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :groups_privileges, :force => true do |t|
    t.column :group_id, :integer
    t.column :privilege_id, :integer
  end

  create_table :normal_users, :force => true do |t|
  end

  create_table :lwt_authentication_system_users, :force => true do |t|
    t.column :username, :string
    t.column :password_hash, :string
    t.column :group_id, :integer
  end

end
