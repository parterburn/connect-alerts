class User < ApplicationRecord
  ENCRYPTED_ATTRIBUTES = %i[
    ecobee_pin
    code
    access_token
    refresh_token
    thermostat_id
    thermostat_name
  ].freeze

  ENCRYPTED_ATTRIBUTES.each do |attribute|
    attr_encrypted attribute, key: Rails.application.credentials.data_encryption_key
  end

  def generate_new_tokens
    resp = HTTParty.post("https://api.ecobee.com/token?grant_type=refresh_token&refresh_token=#{refresh_token}&client_id=#{Rails.application.credentials.ecobee_app_key}")
    if resp.parsed_response["access_token"]
      access_token = resp.parsed_response["access_token"]
      refresh_token = resp.parsed_response["refresh_token"]
      self.update_attributes(access_token: access_token, refresh_token: refresh_token)
    else
      p "Error during token refresh: #{resp.parsed_response}"
    end
  end

  def get_latest_status
    generate_new_tokens
    resp = HTTParty.get('https://api.ecobee.com/1/thermostat?json={"selection":{"includeAlerts":"true","selectionType":"registered","selectionMatch":"","includeRuntime":"true"}}', headers: {"Authorization" => "Bearer #{access_token}"})
    thermostat = resp.parsed_response["thermostatList"]&.first
    if thermostat.present?
      {
        thermostat_name:   thermostat["name"],
        thermostat_id:     thermostat["identifier"],
        connected:         thermostat["runtime"]["connected"],
        last_disconnected: DateTime.parse(thermostat["runtime"]["disconnectDateTime"]),
        last_connected:    DateTime.parse(thermostat["runtime"]["connectDateTime"])
      }
    end
  end
end