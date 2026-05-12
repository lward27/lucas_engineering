#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("../../../../", __dir__)
REGISTRY = File.join(ROOT, "agent-skills/agents/registry/agents.yaml")
TOOL_GRANTS = File.join(ROOT, "agent-skills/agents/registry/tool-grants.yaml")
SKILLS_DIR = File.join(ROOT, "agent-skills/skills")

def fail_with(message)
  warn "registry validation failed: #{message}"
  exit 1
end

def load_yaml(path)
  YAML.safe_load(File.read(path), aliases: false)
end

registry = load_yaml(REGISTRY)
tool_grants = load_yaml(TOOL_GRANTS)

agents = registry.fetch("agents") { fail_with("missing agents array") }
fail_with("agents must be a non-empty array") unless agents.is_a?(Array) && agents.any?

grant_names = Set.new(tool_grants.fetch("grants", {}).keys)
ids = Set.new
missing_skills = Set.new

agents.each do |agent|
  id = agent["id"] || fail_with("agent missing id")
  fail_with("duplicate agent id #{id}") unless ids.add?(id)

  runtime = agent["runtime"]
  fail_with("#{id}: runtime must be hermes in phase 1") unless runtime == "hermes"
  status = agent["status"]
  fail_with("#{id}: invalid status #{status}") unless %w[active planned disabled].include?(status)

  tool_grant = agent["toolGrant"]
  fail_with("#{id}: unknown toolGrant #{tool_grant}") unless grant_names.include?(tool_grant)

  secret_policy = agent["secretPolicy"] || {}
  fail_with("#{id}: rawSecretAccess must be false") unless secret_policy["rawSecretAccess"] == false

  concurrency = agent["concurrency"] || {}
  fail_with("#{id}: maxTasks must be >= 1") unless concurrency["maxTasks"].to_i >= 1
  fail_with("#{id}: maxChildren must be >= 0") unless concurrency.key?("maxChildren") && concurrency["maxChildren"].to_i >= 0

  Array(agent["allowedSkills"]).each do |skill|
    skill_path = File.join(SKILLS_DIR, skill, "SKILL.md")
    missing_skills.add(skill) unless File.exist?(skill_path)
  end
end

if missing_skills.any?
  warn "registry validation warning: skill files not created yet: #{missing_skills.to_a.sort.join(', ')}"
end

puts "registry validation ok: #{agents.length} agents, #{grant_names.length} tool grants"
