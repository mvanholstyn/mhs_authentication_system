ActiveRecord::Schema.define do

  create_table :groups do |t|
    t.column :name, :string
  end

  create_table :privileges do |t|
    t.column :name, :string
  end

  create_table :groups_privileges do |t|
    t.column :group_id, :integer
    t.column :privilege_id, :integer
  end

  create_table :users do |t|
    t.column :username, :string
    t.column :password_hash, :string
    t.column :group_id, :integer
    t.column :email_address, :string
    t.column :active, :boolean
  end
  
  create_table :user_reminders do |t|
    t.column :user_id, :integer
    t.column :token, :string
    t.column :expires_at, :datetime
  end

end
