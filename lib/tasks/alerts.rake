namespace :alerts do
  desc "Send alerts of downtime"
  task :send_if_down => :environment do
    User.all.each do |user|
      status = user.get_latest_status
      if status[:response_code] == 200
        changed = (user.last_disconnected != status[:last_disconnected]) || (user.last_connected != status[:last_connected]) || (user.connected != status[:connected])
        user.update_attributes(status.delete(:full_response))

        if changed && user.connected?
          # show reconnected message
          downtime_seconds = (user.last_connected.to_i - user.last_disconnected.to_i)
          human_downtime_parts = ActiveSupport::Duration.build(downtime_seconds).parts
          human_downtime = human_downtime_parts.map{|k,v| "#{v.round(0)} #{k}"}.to_sentence
          message = "#{user.thermostat_name} was disconnected for #{human_downtime} from #{user.last_disconnected.strftime("%a %-m/%-d %l:%M %p")} — #{user.last_connected.strftime("%a %-m/%-d %l:%M %p")}"
        elsif changed && !user.connected?
          message = "#{user.thermostat_name} was disconnected at #{user.last_disconnected.strftime("%a %-m/%-d %l:%M %p")} and is still offline as of #{user.last_status.strftime("%a %-m/%-d %l:%M %p")}"
        end

        if changed
          send_sms(user, message + "\n\nView the latest status at https://ecobee-down.herokuapp.com/?phone=#{user.phone}")
          message_ecobee(user, message)
        end
      elsif status[:response_code] != user.response_code
        send_sms(user, "#{status[:response_code]} Error with Ecobee: #{status[:full_response]}")
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
