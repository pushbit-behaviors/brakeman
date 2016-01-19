$stdout.sync = true
require "json"
require "faraday"

discoveries = []
changed_files = ENV.fetch("CHANGED_FILES").split(' ')
brakeman_results = JSON.parse(ARGF.read)["warnings"]

puts "CHANGED_FILES: #{changed_files.inspect}"
puts "RAW BRAKEMAN: #{brakeman_results.inspect}"

if changed_files.length > 0
  brakeman_results = brakeman_results.select do |result|
    changed_files.include? result['file']
  end
else
  brakeman_results = brakeman_results.select do |result|
    result["confidence"] != "Weak"
  end
end

puts "PROCESSED BRAKEMAN: #{brakeman_results.inspect}"

brakeman_results.each do |warning|
  discoveries.push({
    title: warning["file"],
    path: warning["file"],
    line: warning["line"],
    task_id: ENV.fetch("TASK_ID"),
    kind: :security,
    identifier: [warning["warning_type"], warning["file"], warning["line"]].join("-"),
    code_changed: false,
    priority: :unknown,
    message: warning["message"] 
  })
end

if discoveries.length == 0
  puts "No security issues here, good job!"
  exit 0
end

conn = Faraday.new(:url => ENV.fetch("APP_URL")) do |config|
  config.adapter Faraday.default_adapter
end

discoveries.each do |discovery|
  puts "POSTING DISCOVERY: #{discovery.inspect}"
  res = conn.post do |req|
    req.url '/discoveries'
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = "Basic #{ENV.fetch("ACCESS_TOKEN")}"
    req.body = discovery.to_json
  end
  puts res.inspect
end
