json.array!(@sms_msgs) do |sms_msg|
  json.extract! sms_msg, :to, :body, :sms_message_id, :date_created, :msg_type, :branch_id
  json.url sms_msg_url(sms_msg, format: :json)
end
