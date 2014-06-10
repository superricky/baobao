if @member.errors.any?
  json.errors @member.errors.full_messages
end