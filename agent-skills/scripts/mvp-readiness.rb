#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "time"
require "yaml"

ROOT = File.expand_path("../../", __dir__)

def capture(command)
  stdout, stderr, status = Open3.capture3(command, chdir: ROOT)
  {
    command: command,
    ok: status.success?,
    stdout: stdout.strip,
    stderr: stderr.strip,
    exitstatus: status.exitstatus
  }
end

def command_exists?(command)
  system("command -v #{command} >/dev/null 2>&1")
end

checks = []

%w[ruby helm kubectl curl jq].each do |command|
  checks << {
    name: "command:#{command}",
    ok: command_exists?(command),
    required: %w[ruby helm kubectl].include?(command)
  }
end

checks << {
  name: "command:argocd",
  ok: command_exists?("argocd"),
  required: false,
  note: "Optional. MVP uses Kubernetes reads of Argo CD Application CRs when argocd CLI is absent."
}

[
  "ruby agent-skills/scripts/validate-foundation.rb",
  "helm lint charts/agentic-platform",
  "helm lint charts/root-app",
  "helm template agentic-platform charts/agentic-platform --namespace agent-runtime >/tmp/agentic-platform-render.yaml"
].each do |command|
  result = capture(command)
  checks << {
    name: command,
    ok: result[:ok],
    required: true,
    stderr: result[:stderr],
    stdout: result[:stdout].lines.last.to_s
  }
end

root_values = YAML.safe_load(File.read(File.join(ROOT, "charts/root-app/values.yaml")), aliases: false)
agentic_enabled = root_values.dig("apps", "agentic-platform", "enabled")
checks << {
  name: "root-app agentic-platform enabled",
  ok: agentic_enabled == true,
  required: true,
  note: "The MVP chart should be enabled when executing the read-only cluster MVP."
}

hermes_values = YAML.safe_load(File.read(File.join(ROOT, "charts/hermes-agent/values.yaml")), aliases: false)
runtime_mode = hermes_values.dig("hermes", "runtime", "mode")
external_host = hermes_values.dig("hermes", "external", "host")
external_port = hermes_values.dig("hermes", "external", "port")
api_enabled = hermes_values.dig("hermes", "gateway", "apiServer", "enabled")
automount_token = hermes_values.dig("hermes", "serviceAccount", "automountToken")

checks << {
  name: "Hermes chart configured for external desktop runtime",
  ok: runtime_mode == "external" && !!external_host && !!external_port,
  required: true,
  note: "Kubernetes provides the ingress/service front door; Hermes runs on the desktop host."
}

checks << {
  name: "Hermes external dashboard/API port configured",
  ok: api_enabled == true && !!external_port,
  required: true,
  note: "Desktop Hermes serves dashboard and authenticated /api routes from the same external port."
}

checks << {
  name: "Hermes pod service account token automount disabled",
  ok: automount_token == false,
  required: false,
  note: "Expected for external-desktop mode. Use the generated desktop kubeconfig instead of pod token automount."
}

blocking = checks.select { |check| check[:required] && !check[:ok] }
ready_for_local_dry_run = blocking.empty?
ready_for_cluster_mvp = ready_for_local_dry_run && agentic_enabled == true

report = {
  generated_at: Time.now.utc.iso8601,
  ready_for_local_dry_run: ready_for_local_dry_run,
  ready_for_cluster_mvp_execution_after_approval: ready_for_cluster_mvp,
  blocking_checks: blocking.map { |check| check[:name] },
  checks: checks
}

puts JSON.pretty_generate(report)
exit(blocking.empty? ? 0 : 1)
