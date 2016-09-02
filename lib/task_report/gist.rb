require 'uri'
require 'net/http'
require 'json'

module TaskReport
  module Gist
    class << self
      def find_gist_from_today_by_description(description)
        get_gists_for_user.find do |gist|
          gist['description'] == description
        end
      end

      def find_gists_by_descriptions(descriptions, from)
        get_gists_for_user(from).select do |gist|
          descriptions.include? gist['description']
        end
      end

      def get_gists_for_user(from = Time.now)
        # kind of like Time.now.midnight in UTC
        time_string = Time.new(from.year, from.month, from.day).getgm.strftime('%Y-%m-%dT%H:%M:%SZ')

        params = {
          access_token: User.api_token,
          since: time_string
        }

        uri = URI "https://api.github.com/users/#{User.name}/gists"
        uri.query = URI.encode_www_form params
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        JSON.parse(response.body)
      end

      def create(params)
        uri = URI "https://api.github.com/gists"
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "token #{User.api_token}"
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
        request['Authorization'] = "token #{User.api_token}"
        request.body = JSON.dump(params)
        response = http.request(request)
        JSON.parse(response.body)
      end

      def delete(gist_id)
        uri = URI "https://api.github.com/gists/#{gist_id}"
        request = Net::HTTP::Delete.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request['Authorization'] = "token #{User.api_token}"
        http.request(request)
      end

      def file_content(raw_url)
        uri = URI raw_url
        request = Net::HTTP::Get.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request['Accept'] = 'application/json'
        request['Authorization'] = "token #{User.api_token}"
        response = http.request(request)
        JSON.parse(response.body)
      end
    end
  end
end
