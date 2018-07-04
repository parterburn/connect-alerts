class CreateUserTable < ActiveRecord::Migration[5.2]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :users, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :encrypted_phone
      t.string :encrypted_phone_iv
      t.string :encrypted_ecobee_pin
      t.string :encrypted_ecobee_pin_iv
      t.string :encrypted_code
      t.string :encrypted_code_iv
      t.string :encrypted_access_token
      t.string :encrypted_access_token_iv
      t.string :encrypted_refresh_token
      t.string :encrypted_refresh_token_iv
      t.string :encrypted_thermostat_id
      t.string :encrypted_thermostat_id_iv
      t.string :encrypted_thermostat_name
      t.string :encrypted_thermostat_name_iv
      t.boolean :connected
      t.datetime :last_connected
      t.datetime :last_disconnected
      t.timestamps
    end
  end
end
