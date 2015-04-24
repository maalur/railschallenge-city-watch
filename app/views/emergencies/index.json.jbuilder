json.emergencies @emergencies do |emergency|
  json.code emergency.code
  json.fire_severity emergency.fire_severity
  json.police_severity emergency.police_severity
  json.medical_severity emergency.medical_severity
  json.resolved_at emergency.resolved_at
  json.responders emergency.responders_names
  json.full_response emergency.full_response
end

json.full_responses @full_responses