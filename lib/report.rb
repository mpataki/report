module Report
  class << self
    def report_gist_description(time = Time.now)
      "#{User.name}_report_#{time.strftime('%Y-%m-%d')}"
    end

    def report_file_name(description)
      "#{description}.json"
    end

    # return nil if none exist
    def find_report_gist_from_today(gists)
      description = report_gist_description
      gists.find { |gist| gist['description'] == description }
    end

    def existing_task?(existing_tasks, new_task_description)
      existing_tasks.any? do |task|
        task[:description] == new_task_description
      end
    end

    def json_content(task_description, existing_tasks = nil)
      JSON.pretty_generate(
        if existing_tasks.nil?
          [Task.new(description: task_description).to_hash]
        else
          existing_tasks.map! do |hash|
            task = Task.from_existing_tasks(hash)
            task.stop
            task.to_hash
          end

          raise TaskAlreadyTracked if existing_task?(existing_tasks, task_description)
          existing_tasks + [Task.new(description: task_description).to_hash]
        end
      )
    end

    def create_report_gist(content, time = Time.now)
      puts 'Creating a new report' # TODO: add a verbose mode for this
      description = report_gist_description(time)
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

      Gist.create(params)
    end

    def edit_report_gist(report_gist, content)
      puts 'Editing the existing report' # TODO: add a verbose mode for this
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

      Gist.edit(report_gist['id'], params)
    end

    def start(task)
      gists = Gist.get_recent_gists_for_user
      report_gist = find_report_gist_from_today(gists)

      if report_gist.nil?
        report_gist = create_report_gist(json_content(task))
      else
        description = report_gist_description
        file_name = report_file_name(description)
        raw_url = report_gist['files'][file_name]['raw_url']
        existing_tasks = Gist.file_content(raw_url)
        json_file_content = json_content(task, existing_tasks)
        edit_report_gist(report_gist, json_file_content)
      end
    end
  end
end
