class ConvertCodeToLookup < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :code, :string
    remove_column :users, :encrypted_code
    remove_column :users, :encrypted_code_iv    
  end

  def down
    remove_column :users, :code
    add_column :users, :encrypted_code, :string
    add_column :users, :encrypted_code_iv, :string
  end
end
