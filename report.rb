require 'uri'
require 'net/http'
require 'json'
require 'byebug' # DELETE ME

def report_gist_description(user, time = Time.now)
	"#{user}_report_#{time.strftime('%Y-%m-%d')}"
end

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
	response_body = JSON.parse(response.body)
end

# return nil if none exist
def find_report_gist_from_today(user, gists)
	description = report_gist_description(user)
	gists.find { |gist| gist['description'] == description }
end

def create_report_gist(user, api_token, time = Time.now)
	puts 'Creating a new report'
	description = report_gist_description(user, time)
	file_name = "#{description}.md"	
        
	params = {
		public: false,
		description: description,
		files: {
			file_name => {
				content: "test" # this is where the messages would go ;)
			}
		}
        }

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

user = 'mpataki' # probably want to pull this from a config
api_token = File.read('gist_token').strip

gists = get_recent_gists_for_user(user, api_token)
report_gist = find_report_gist_from_today(user, gists)
report_gist = create_report_gist(user, api_token) if report_gist.nil?
puts report_gist
