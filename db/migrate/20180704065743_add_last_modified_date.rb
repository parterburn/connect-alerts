class AddLastModifiedDate < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_status, :datetime
  end
end
