#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "optparse"
require "time"

options = {
  argocd_namespace: "argocd",
  namespace: nil,
  expected_revision: nil,
  request_timeout: "10s",
  output: "json"
}

OptionParser.new do |parser|
  parser.banner = "Usage: argocd-health-check.rb --app APP [--namespace NAMESPACE] [--expected-revision REV]"
  parser.on("--app APP", "Argo CD application name") { |value| options[:app] = value }
  parser.on("--argocd-namespace NS", "Argo CD namespace, default argocd") { |value| options[:argocd_namespace] = value }
  parser.on("--namespace NS", "Kubernetes workload namespace") { |value| options[:namespace] = value }
  parser.on("--expected-revision REV", "Expected Git revision") { |value| options[:expected_revision] = value }
  parser.on("--request-timeout DURATION", "kubectl request timeout, default 10s") { |value| options[:request_timeout] = value }
  parser.on("--output FORMAT", "json or text") { |value| options[:output] = value }
end.parse!

def fail_json(message)
  puts JSON.pretty_generate({
    "status" => "error",
    "recommendation" => "investigate",
    "error" => message,
    "generated_at" => Time.now.iso8601
  })
  exit 1
end

def kubectl_json(*args)
  stdout, stderr, status = Open3.capture3("kubectl", *args)
  return [JSON.parse(stdout), nil] if status.success?

  [nil, stderr.strip.empty? ? stdout.strip : stderr.strip]
end

fail_json("--app is required") unless options[:app]

app, app_error = kubectl_json(
  "get", "application.argoproj.io", options[:app],
  "-n", options[:argocd_namespace],
  "--request-timeout", options[:request_timeout],
  "-o", "json"
)

if app_error
  puts JSON.pretty_generate({
    "app" => options[:app],
    "argocd_namespace" => options[:argocd_namespace],
    "sync_status" => "Unknown",
    "health_status" => "Unknown",
    "recommendation" => "investigate",
    "errors" => ["Unable to read Argo CD Application: #{app_error}"],
    "generated_at" => Time.now.iso8601
  })
  exit 2
end

status = app.fetch("status", {})
spec = app.fetch("spec", {})
destination = spec.fetch("destination", {})
workload_namespace = options[:namespace] || destination["namespace"]
sync_status = status.dig("sync", "status") || "Unknown"
health_status = status.dig("health", "status") || "Unknown"
revision = status.dig("sync", "revision")

warnings = []
warnings << "Expected revision #{options[:expected_revision]} but Argo reports #{revision}" if options[:expected_revision] && revision != options[:expected_revision]

resources = Array(status["resources"]).map do |resource|
  {
    "kind" => resource["kind"],
    "namespace" => resource["namespace"],
    "name" => resource["name"],
    "status" => resource["status"],
    "health" => resource.dig("health", "status")
  }
end

pod_summary = nil
if workload_namespace
  pods, pods_error = kubectl_json("get", "pods", "-n", workload_namespace, "--request-timeout", options[:request_timeout], "-o", "json")
  if pods_error
    warnings << "Unable to read pods in #{workload_namespace}: #{pods_error}"
  else
    items = Array(pods["items"])
    not_ready = []
    restarts = 0
    items.each do |pod|
      statuses = pod.dig("status", "containerStatuses") || []
      statuses.each do |container|
        restarts += container["restartCount"].to_i
        not_ready << "#{pod.dig('metadata', 'name')}/#{container['name']}" unless container["ready"]
      end
    end
    pod_summary = {
      "namespace" => workload_namespace,
      "pod_count" => items.length,
      "not_ready" => not_ready,
      "total_restarts" => restarts
    }
  end
end

recommendation =
  if sync_status == "Synced" && health_status == "Healthy" && warnings.empty? && (!pod_summary || pod_summary["not_ready"].empty?)
    "pass"
  elsif health_status == "Progressing"
    "wait"
  elsif health_status == "Degraded" || sync_status == "OutOfSync"
    "investigate"
  else
    "investigate"
  end

report = {
  "app" => options[:app],
  "argocd_namespace" => options[:argocd_namespace],
  "namespace" => workload_namespace,
  "sync_status" => sync_status,
  "health_status" => health_status,
  "revision" => revision,
  "resources" => resources,
  "kubernetes_summary" => pod_summary,
  "warnings" => warnings,
  "recommendation" => recommendation,
  "generated_at" => Time.now.iso8601
}

if options[:output] == "text"
  puts "#{report['app']}: sync=#{sync_status} health=#{health_status} recommendation=#{recommendation}"
  puts "revision=#{revision}" if revision
  warnings.each { |warning| puts "warning: #{warning}" }
else
  puts JSON.pretty_generate(report)
end
