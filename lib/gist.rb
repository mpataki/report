require 'uri'
require 'net/http'
require 'json'

module Gist
  class << self
    def get_recent_gists_for_user(user, api_token)
      puts "Querying for today's report"
      now = Time.now

      # kind of like Time.now.midnight in UTC
      time_string = Time.new(now.year, now.month, now.day).getgm.strftime('%Y-%m-%dT%H:%M:%SZ')

      params = {
        access_token: api_token,
        since: time_string
      }

      uri = URI "https://api.github.com/users/#{user}/gists"
      uri.query = URI.encode_www_form params
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      JSON.parse(response.body)
    end

    def create(user, api_token, params)
      uri = URI "https://api.github.com/gists"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "token #{api_token}"
      request.body = JSON.dump(params)
      response = http.request(request)
      JSON.parse(response.body)
    end

    def edit(gist_id, params)
      uri = URI "https://api.github.com/gists/#{gist_id}"
      request = Net::HTTP::Patch.new(uri.request_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "token #{api_token}"
      request.body = JSON.dump(params)
      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end
