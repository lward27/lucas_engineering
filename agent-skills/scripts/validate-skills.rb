#!/usr/bin/env ruby
# frozen_string_literal: true

require "set"
require "yaml"

ROOT = File.expand_path("../../", __dir__)
CATALOG = File.join(ROOT, "agent-skills/skills/catalog.yaml")
SKILLS_DIR = File.join(ROOT, "agent-skills/skills")
REGISTRY = File.join(ROOT, "agent-skills/agents/registry/agents.yaml")

def fail_with(message)
  warn "skill validation failed: #{message}"
  exit 1
end

def load_yaml(path)
  YAML.safe_load(File.read(path), aliases: false)
end

catalog = load_yaml(CATALOG)
registry = load_yaml(REGISTRY)

catalog_entries = catalog.fetch("skills") { fail_with("missing skills list") }
catalog_names = Set.new
catalog_entries.each do |entry|
  name = entry["name"] || fail_with("catalog entry missing name")
  fail_with("duplicate catalog skill #{name}") unless catalog_names.add?(name)
  fail_with("#{name}: invalid status") unless %w[implemented stub planned disabled].include?(entry["status"])
  skill_file = File.join(SKILLS_DIR, name, "SKILL.md")
  fail_with("#{name}: missing #{skill_file}") unless File.exist?(skill_file)
  text = File.read(skill_file)
  fail_with("#{name}: SKILL.md must start with '# #{name}'") unless text.start_with?("# #{name}\n")
  fail_with("#{name}: SKILL.md is too small to be useful") if text.lines.count < 10
end

referenced = registry.fetch("agents").flat_map { |agent| Array(agent["allowedSkills"]) }.to_set
missing_from_catalog = referenced - catalog_names
fail_with("registry references skills missing from catalog: #{missing_from_catalog.to_a.sort.join(', ')}") unless missing_from_catalog.empty?

orphaned_dirs = Dir.children(SKILLS_DIR)
                 .select { |entry| File.directory?(File.join(SKILLS_DIR, entry)) }
                 .to_set - catalog_names
fail_with("skill directories missing from catalog: #{orphaned_dirs.to_a.sort.join(', ')}") unless orphaned_dirs.empty?

puts "skill validation ok: #{catalog_names.length} cataloged skills, #{referenced.length} registry-referenced skills"
