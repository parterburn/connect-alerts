class AddFullReponseToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :response_code, :integer
  end
end
