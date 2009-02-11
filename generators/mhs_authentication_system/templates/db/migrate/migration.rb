class AddMhsAuthenticationSystem < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.timestamps
    end

    create_table :privileges do |t|
      t.string :name
      t.timestamps
    end

    create_table :privileges_roles, :id => false do |t|
      t.integer :role_id
      t.integer :privilege_id
    end
    
    add_index :privileges_roles, :role_id
    add_index :privileges_roles, :privilege_id
    add_index :privileges_roles, [:role_id, :privilege_id], :uniq => true

    create_table :users do |t|
      t.string :password_hash
      t.string :salt
      t.string :email_address
      t.integer :role_id
      t.boolean :active
      t.string :remember_me_token
      t.datetime :remember_me_token_expires_at
      t.timestamps
    end
    add_index :users, :role_id
    add_index :users, :email_address
    add_index :users, [:remember_me_token, :remember_me_token_expires_at], :name => "index_users_on_remember_me_token"
    
    create_table :user_reminders do |t|
      t.integer :user_id
      t.string :token
      t.datetime :expires_at
      t.timestamps
    end
    add_index :user_reminders, :user_id
    add_index :user_reminders, [:user_id, :token, :expires_at]
  end

  def self.down
    drop_table :users
    drop_table :privileges_roles
    drop_table :privileges
    drop_table :roles
    drop_table :user_reminders
  end
end
