#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "optparse"
require "yaml"

options = {
  namespace: "hermes-agent",
  service_account: "hermes-agent",
  duration: "24h",
  output: "hermes-desktop.kubeconfig"
}

OptionParser.new do |parser|
  parser.banner = "Usage: generate-desktop-hermes-kubeconfig.rb [--output PATH] [--duration 24h]"
  parser.on("--namespace NS", "ServiceAccount namespace") { |value| options[:namespace] = value }
  parser.on("--service-account NAME", "ServiceAccount name") { |value| options[:service_account] = value }
  parser.on("--duration DURATION", "Token duration, for example 24h") { |value| options[:duration] = value }
  parser.on("--output PATH", "Output kubeconfig path") { |value| options[:output] = value }
end.parse!

def capture_json(*args)
  stdout, stderr, status = Open3.capture3("kubectl", *args)
  unless status.success?
    warn stderr.strip.empty? ? stdout.strip : stderr.strip
    exit status.exitstatus
  end
  JSON.parse(stdout)
end

def capture_text(*args)
  stdout, stderr, status = Open3.capture3("kubectl", *args)
  unless status.success?
    warn stderr.strip.empty? ? stdout.strip : stderr.strip
    exit status.exitstatus
  end
  stdout.strip
end

config = capture_json("config", "view", "--raw", "--minify", "-o", "json")
cluster = config.fetch("clusters").first.fetch("cluster")
cluster_name = config.fetch("clusters").first.fetch("name")

token = capture_text(
  "create", "token", options[:service_account],
  "-n", options[:namespace],
  "--duration", options[:duration]
)

desktop_context = "#{options[:service_account]}@#{cluster_name}"
kubeconfig = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => cluster_name,
      "cluster" => cluster
    }
  ],
  "contexts" => [
    {
      "name" => desktop_context,
      "context" => {
        "cluster" => cluster_name,
        "user" => options[:service_account],
        "namespace" => options[:namespace]
      }
    }
  ],
  "current-context" => desktop_context,
  "users" => [
    {
      "name" => options[:service_account],
      "user" => {
        "token" => token
      }
    }
  ]
}

File.write(options[:output], YAML.dump(kubeconfig))
File.chmod(0o600, options[:output])

warn "wrote #{options[:output]}"
warn "copy this file to the desktop Hermes host and set KUBECONFIG to its path"
warn "do not commit this file; it contains a bearer token"
