class RenamePhoneOnUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :phone, :string
    remove_column :users, :encrypted_phone
    remove_column :users, :encrypted_phone_iv    
  end

  def down
    remove_column :users, :phone
    add_column :users, :encrypted_phone, :string
    add_column :users, :encrypted_phone_iv, :string
  end
end
