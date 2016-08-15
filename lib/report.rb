module Report
  class << self
    def report_gist_description(user, time = Time.now)
      "#{user}_report_#{time.strftime('%Y-%m-%d')}"
    end

    # return nil if none exist
    def find_report_gist_from_today(user, gists)
      description = report_gist_description(user)
      gists.find { |gist| gist['description'] == description }
    end

    def json_content(task_description, existing_content = nil)
      JSON.dump([
        Task.new(task_description).to_hash
      ])
    end

    def create_report_gist(user, api_token, content, time = Time.now)
      puts 'Creating a new report'
      description = report_gist_description(user, time)
      file_name = "#{description}.json"

      params = {
        public: false,
        description: description,
        files: {
          file_name => {
            content: content
          }
        }
      }

      Gist.create(user, api_token, params)
    end

    def start(task)
      user = 'mpataki' # TODO: pull this from a config
      api_token = File.read('gist_token').strip

      gists = Gist.get_recent_gists_for_user(user, api_token)
      report_gist = find_report_gist_from_today(user, gists)

      if report_gist.nil?
        report_gist = create_report_gist(user, api_token, json_content(task))
      else
        # TODO: add to the existing gist
      end
    end
  end
end
