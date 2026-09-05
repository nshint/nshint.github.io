#!/usr/bin/env ruby
# frozen_string_literal: true

# Compare blog post URLs from urls.txt against a site.
#
# By default a local `jekyll serve` instance is checked. Pass --live to check
# the same paths against the published site, or --base to point anywhere else.
#
#     ./test_urls.rb                          # http://localhost:4000
#     ./test_urls.rb --live                   # http://nshint.io
#     ./test_urls.rb --base http://staging    # anything else

require 'net/http'
require 'optparse'
require 'uri'

LIVE_URL = 'http://nshint.io'
LOCAL_URL = 'http://localhost:4000'
URLS_FILE = 'scripts/urls.txt'
USER_AGENT = 'Mozilla/5.0'
TIMEOUT = 10
MAX_REDIRECTS = 10

# HTTP status of `url` after following redirects, or 0 if it could not be
# reached at all.
def status_code(url)
  MAX_REDIRECTS.times do
    response = get(url)
    return response.code.to_i unless response.is_a?(Net::HTTPRedirection)

    url = URI.join(url, response['location']).to_s
  end
  0
rescue StandardError
  0
end

def get(url)
  uri = URI(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                      open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
    http.request(Net::HTTP::Get.new(uri, 'User-Agent' => USER_AGENT))
  end
end

def parse_base
  base = LOCAL_URL
  flags = []
  OptionParser.new do |parser|
    parser.banner = "Usage: #{File.basename($PROGRAM_NAME)} [--live | --base URL]"
    parser.on('--live', "check #{LIVE_URL} instead of the local server") do
      flags << '--live'
      base = LIVE_URL
    end
    parser.on('--base URL', 'check this base URL instead of the local server') do |url|
      flags << '--base'
      base = url
    end
  end.parse!
  abort 'error: --live and --base are mutually exclusive' if flags.size > 1

  base
end

def main
  base = parse_base
  urls = File.readlines(URLS_FILE, chomp: true)
             .reject(&:empty?)
             .map { |line| URI.join(base, URI(line).path).to_s }

  puts "Testing #{urls.size} URLs from #{URLS_FILE} against #{base}\n\n"
  puts format('%-8s %-6s %s', 'Status', 'Code', 'URL')
  puts '-' * 80

  failed = []
  urls.each do |url|
    code = status_code(url)
    ok = (200...300).cover?(code)
    failed << [url, code] unless ok
    puts format('%-8s %-6s %s', ok ? 'OK' : 'FAIL', code, url)
  end

  puts '-' * 80
  puts "\nResults: #{urls.size - failed.size} OK, #{failed.size} failed"

  return if failed.empty?

  puts "\nFailed URLs:"
  failed.each { |url, code| puts "  - #{url} (HTTP #{code})" }
end

main if $PROGRAM_NAME == __FILE__
