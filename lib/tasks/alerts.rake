namespace :alerts do
  desc "Send alerts of downtime"
  task :send_if_down do
    User.each do |user|
      status = user.get_latest_status
      changed = user.last_disconnected != status[:last_disconnected]
      user.update_attributes(status)

      if changed && user.connected?
        # show reconnected message
        downtime_seconds = (user.last_connected.to_i - user.last_disconnected.to_i)
        human_downtime_parts = ActiveSupport::Duration.build(downtime_seconds).parts
        human_downtime = human_downtime_parts.map{|k,v| "#{v.round(0)} #{k}"}.to_sentence
        message = "#{user.thermostat_name} was disconnected for #{human_downtime} from #{user.last_disconnected.in_time_zone(Rails.application.credentials.timezone).strftime("%a %-m/%-d %l:%M %p")} until #{user.last_connected.in_time_zone(Rails.application.credentials.timezone).strftime("%a %-m/%-d %l:%M %p")}"
      elsif changed && !user.connected?
        message = "#{user.thermostat_name} was disconnected at #{user.last_disconnected.in_time_zone(Rails.application.credentials.timezone).strftime("%a %-m/%-d %l:%M %p")}"
      end

      if changed
        send_sms(user, message)
        message_ecobee(user, message)
      end
    end
  end

  private

  def send_sms(user, message)
    sns = Aws::SNS::Client.new(access_key_id: Rails.application.credentials.aws_access_id, secret_access_key: Rails.application.credentials.aws_access_key, region: Rails.application.credentials.aws_region)
    sns.publish(phone_number: "#{user.phone}", message: message)    
  end

  def message_ecobee(user, message)
    body = {
          "functions": [
              {
                  "type":"sendMessage",
                  "params":{
                      "text": message
                     }
              }
          ],
          "selection": {
              "selectionType":"registered",
              "selectionMatch":""
          }
      }

    resp = HTTParty.post("https://api.ecobee.com/1/thermostat?format=json", body: body.as_json.to_json, headers: { "Authorization" => "Bearer #{user.access_token}", "Content-Type": "application/json;charset=UTF-8" })
  end
end
