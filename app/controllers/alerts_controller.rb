class AlertsController < ApplicationController
  def index
    if params[:code].present?
      get_access_token(params[:code])
    elsif params[:user] == "new"
      get_pin
    elsif params[:phone].present?
      connection_status
    end
  end

  private

  def get_pin
    resp = HTTParty.get("https://api.ecobee.com/authorize?response_type=ecobeePin&client_id=#{Rails.application.credentials.ecobee_app_key}&scope=smartWrite")
    ecobee_pin = resp.parsed_response["ecobeePin"]
    @code = resp.parsed_response["code"]
    @pin_message = "Login to the Ecobee web portal and add an app with this key in the next 10 minutes: #{ecobee_pin}"
    user = User.find_or_create_by(phone: params[:phone])
    user.update_attributes(ecobee_pin: ecobee_pin, code: @code)
  end

  def get_access_token(code)
    user = User.find_by(code: code)
    if user
      resp = HTTParty.post("https://api.ecobee.com/token?grant_type=ecobeePin&code=#{code}&client_id=#{Rails.application.credentials.ecobee_app_key}&scope=smartWrite")
      if resp.parsed_response["access_token"]
        access_token = resp.parsed_response["access_token"]
        refresh_token = resp.parsed_response["refresh_token"]
        user.update_attributes(access_token: access_token, refresh_token: refresh_token)
      else
        @error = "Error: #{resp.parsed_response}"
      end
    else
      @error = "Code does not match existing user."
    end
  end

  def connection_status
    user = User.find_by(phone: params[:phone])
    if user.present?
      status = user.get_latest_status
      downtime_seconds = (status[:last_connected].to_i - status[:last_disconnected].to_i)
      human_downtime_parts = ActiveSupport::Duration.build(downtime_seconds).parts
      human_downtime = human_downtime_parts.map{|k,v| "#{v.round(0)} #{k}"}.to_sentence

      if status[:connected]
        connected = status[:connected] ? "connected" : "disconnected"
        if status[:last_disconnected].present?
          add_msg = " It was last disconnected for #{human_downtime} from #{status[:last_disconnected].in_time_zone(Rails.application.credentials.timezone).strftime("%a %-m/%-d/%Y %l:%M %p")} until #{status[:last_connected].in_time_zone(Rails.application.credentials.timezone).strftime("%a %-m/%-d/%Y %l:%M %p")}"
        end
        @message = "#{status[:thermostat_name]} is #{connected}.#{add_msg}"
      end      
    end 
  end
end
