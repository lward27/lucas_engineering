#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "optparse"
require "time"
require "uri"

options = {
  mode: "instant",
  step: "30s",
  output: "json"
}

OptionParser.new do |parser|
  parser.banner = "Usage: prometheus-query.rb --base-url URL --query PROMQL [--mode instant|range]"
  parser.on("--base-url URL", "Prometheus or Mimir base URL") { |value| options[:base_url] = value }
  parser.on("--query PROMQL", "PromQL query") { |value| options[:query] = value }
  parser.on("--mode MODE", "instant or range") { |value| options[:mode] = value }
  parser.on("--time TIME", "Instant query time") { |value| options[:time] = value }
  parser.on("--start TIME", "Range start") { |value| options[:start] = value }
  parser.on("--end TIME", "Range end") { |value| options[:end] = value }
  parser.on("--step STEP", "Range step, default 30s") { |value| options[:step] = value }
  parser.on("--bearer-token TOKEN", "Optional bearer token") { |value| options[:bearer_token] = value }
  parser.on("--output FORMAT", "json or text") { |value| options[:output] = value }
end.parse!

def fail_json(message)
  puts JSON.pretty_generate({
    "status" => "error",
    "health_signal" => "unknown",
    "error" => message,
    "generated_at" => Time.now.iso8601
  })
  exit 1
end

fail_json("--base-url is required") unless options[:base_url]
fail_json("--query is required") unless options[:query]
fail_json("refusing unbounded selector query") if options[:query].match?(/\{\s*\}/)

base = options[:base_url].sub(%r{/*$}, "")
endpoint = options[:mode] == "range" ? "/api/v1/query_range" : "/api/v1/query"
uri = URI("#{base}#{endpoint}")
params = { "query" => options[:query] }

if options[:mode] == "range"
  fail_json("--start and --end are required for range mode") unless options[:start] && options[:end]
  params["start"] = options[:start]
  params["end"] = options[:end]
  params["step"] = options[:step]
else
  params["time"] = options[:time] if options[:time]
end

uri.query = URI.encode_www_form(params)
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer #{options[:bearer_token]}" if options[:bearer_token]

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", read_timeout: 30) do |http|
  http.request(request)
end

body = JSON.parse(response.body)
result = body.dig("data", "result") || []
result_type = body.dig("data", "resultType") || "unknown"

health_signal =
  if response.code.to_i >= 400 || body["status"] != "success"
    "unknown"
  elsif result.empty?
    "unknown"
  else
    "pass"
  end

summary =
  if response.code.to_i >= 400
    "Query failed with HTTP #{response.code}."
  elsif body["status"] != "success"
    "Query failed with Prometheus status #{body['status']}."
  elsif result.empty?
    "Query succeeded but returned no series."
  else
    "Query succeeded with #{result.length} result series."
  end

report = {
  "status" => body["status"],
  "http_status" => response.code.to_i,
  "query" => options[:query],
  "mode" => options[:mode],
  "result_type" => result_type,
  "result_count" => result.length,
  "summary" => summary,
  "health_signal" => health_signal,
  "data" => body["data"],
  "generated_at" => Time.now.iso8601
}

if options[:output] == "text"
  puts summary
  puts "result_type=#{result_type} result_count=#{result.length} health_signal=#{health_signal}"
else
  puts JSON.pretty_generate(report)
end
