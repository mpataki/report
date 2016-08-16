module Report
  class << self
    def report_gist_description(user, time = Time.now)
      "#{user}_report_#{time.strftime('%Y-%m-%d')}"
    end

    def report_file_name(description)
      "#{description}.json"
    end

    # return nil if none exist
    def find_report_gist_from_today(user, gists)
      description = report_gist_description(user)
      gists.find { |gist| gist['description'] == description }
    end

    def json_content(task_description, existing_content = nil)
      JSON.dump(
        if existing_content.nil?
          [
            Task.new(description: task_description).to_hash
          ]
        else
          existing_content.map! do |hash|
            task = Task.from_existing_content(hash)
            task.stop
            task.to_hash
          end

          # TODO: should check here if the task is already present
          existing_content + [Task.new(description: task_description).to_hash]
        end
      )
    end

    def create_report_gist(user, api_token, content, time = Time.now)
      puts 'Creating a new report'
      description = report_gist_description(user, time)
      file_name = report_file_name(description)

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

    def edit_report_gist(user, api_token, report_gist, content)
      puts 'Editing the existing report'
      json_file =
        report_gist['files'].values.find { |f| f['language'] == 'JSON' }

      params = {
        description: report_gist['description'], # do we actually need this? Seems odd...
        files: {
          json_file['filename'] => {
            content: content
          }
        }
      }

      Gist.edit(report_gist['id'], api_token, params)
    end

    def start(task)
      user = 'mpataki' # TODO: pull this from a config
      api_token = File.read('gist_token').strip

      gists = Gist.get_recent_gists_for_user(user, api_token)
      report_gist = find_report_gist_from_today(user, gists)

      if report_gist.nil?
        report_gist = create_report_gist(user, api_token, json_content(task))
      else
        description = report_gist_description(user)
        file_name = report_file_name(description)
        raw_url = report_gist['files'][file_name]['raw_url']
        existing_content = Gist.file_content(raw_url, api_token)
        edit_report_gist(user, api_token, report_gist, json_content(task, existing_content))
      end
    end
  end
end
