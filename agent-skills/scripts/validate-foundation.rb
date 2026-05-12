#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "json"

ROOT = File.expand_path("../../", __dir__)

def run(command)
  puts "$ #{command}"
  system(command, chdir: ROOT) || exit($?&.exitstatus || 1)
end

run("ruby agent-skills/agents/registry/scripts/validate-agent-registry.rb")
run("ruby agent-skills/scripts/validate-skills.rb")

yaml_files = Dir.glob(File.join(ROOT, "{agent-skills,cluster}/**/*.{yaml,yml}"))
yaml_files.each do |path|
  YAML.safe_load(File.read(path), aliases: false)
end
puts "yaml validation ok: #{yaml_files.length} files"

json_files = Dir.glob(File.join(ROOT, "{agent-skills,cluster}/**/*.json"))
json_files.each do |path|
  JSON.parse(File.read(path))
end
puts "json validation ok: #{json_files.length} files"

forbidden = []
retired_runtime = "open" + "claw"
Dir.glob(File.join(ROOT, "{agent-skills,cluster,docs,diagrams}/**/*")).each do |path|
  next unless File.file?(path)

  text = File.read(path)
  forbidden << path if text.downcase.include?(retired_runtime)
end

if forbidden.any?
  warn "forbidden runtime reference found:"
  forbidden.each { |path| warn "  #{path.sub("#{ROOT}/", "")}" }
  exit 1
end

puts "foundation validation ok"
