module TaskReport
  class Report
    TaskAlreadyTracked = Class.new StandardError
    TaskAlreadyOngoing = Class.new StandardError
    TaskDNE = Class.new StandardError
    MultipleOngoingTasks = Class.new StandardError

    attr_reader :gist_id

    class << self
      def gist_description
        "#{User.name}_report_#{Time.now.strftime('%Y-%m-%d')}"
      end

      def json_file_name
        "#{gist_description}.json"
      end

      def create(new_task_description:)
        Report.new(
          description: gist_description,
          json_file_name: json_file_name
        )
      end

      def create_from_gist(gist)
        raw_url = gist['files'][json_file_name]['raw_url']

        Report.new(
          description: gist_description,
          json_file_name: json_file_name,
          gist_id: gist['id'],
          gist_html_url: gist['html_url'],
          existing_json_content: Gist.file_content(raw_url)
        )
      end
    end

    def start_task(new_task_description)
      if @tasks.any? { |t| t.description == new_task_description }
        raise TaskAlreadyTracked
      end

      task = Task.new(description: new_task_description)
      puts "Starting #{task.to_s}."
      @tasks << task
    end

    def stop_all_tasks
      @tasks.each(&:stop)
    end

    def continue(task_id)
      ensure_no_tasks_ongoing!

      task =
        if task_id.nil?
          find_last_task_to_be_worked_on
        else
          find_task_by_id(task_id) || find_task_by_description(task_id)
        end

      task.continue
    end

    def delete(task_id)
      task = find_task_by_id(task_id) || find_task_by_description(task_id)
      raise TaskDNE if task.nil?

      puts "Deleting #{task.to_s}."
      @tasks.delete_if { |t| t.id == task.id }
    end

    def delete_all
      puts "Deleting all tasks for today."
      @tasks = []
    end

    def print_tasks
      if @tasks.empty?
        puts 'There are no tasks reported for today.'
        return
      end

      puts "Tasks:"

      @tasks.each do |task|
        puts "- #{task.to_s}"
      end
    end

    def print_current_task
      ensure_only_one_ongoing_task!

      task = @tasks.find(&:ongoing?)

      if task.nil?
        puts "There is no task ongoing."
      else
        puts "Curent task: #{task.to_s}"
      end
    end

    def print_summary
      if @tasks.empty?
        puts 'There are no tasks reported for today.'
        return
      end

      puts "#{User.name} Task Report #{@date.strftime('%Y-%m-%d')}"

      @tasks.each do |task|
        puts "'#{task.description}'"
        puts "  - #{task.duration.to_s}"

        task.notes.each do |note|
          puts "  - #{note}"
        end

        puts "\nTotal time tracked: #{total_duration.to_s}"
      end
    end

    def gist_summary
      if @tasks.empty?
        puts 'There are no tasks reported for today.'
        return
      end

      puts 'Creating a gist summary.'

      Gist.edit(@gist_id,
        description: @description, # do we actually need this? Seems odd...
        files: {
          'summary.md' => {
            content: gist_summary_content
          }
        }
      )

      puts "#{@gist_html_url}#file-summary-md"
    end

    def save_to_gist!
      if @gist_id
        edit_existing_data_gist!
      else
        save_new_data_gist!
      end
    end

    def add_note(task_id, note)
      task = find_task_by_id(task_id)
      raise TaskDNE if task.nil?

      task.add_note(note)
      puts "Note added to #{task.to_s}"
    end

    def total
      puts total_duration.to_s
    end

    private
      def initialize(description:, json_file_name:, gist_id: nil, gist_html_url: nil, existing_json_content: {})
        @description = description
        @json_file_name = json_file_name
        @gist_id = gist_id
        @gist_html_url = gist_html_url

        @date = Time.parse(
          existing_json_content.fetch('date', Time.now.strftime('%Y-%m-%d %z'))
        )

        @tasks =
          existing_json_content.fetch('tasks', []).map do |hash|
            Task.from_existing_tasks(hash)
          end
      end

      def to_h
        {
          date: @date.strftime('%Y-%m-%d %z'),
          tasks: @tasks.map(&:to_h)
        }
      end

      def task_json
        JSON.pretty_generate(to_h)
      end

      def save_new_data_gist!
        puts "Starting a new report gist for the day."

        Gist.create(
          public: false,
          description: @description,
          files: {
            @json_file_name => {
              content: task_json
            }
          }
        )
      end

      def edit_existing_data_gist!
        puts "Saving to today's report gist."

        Gist.edit(@gist_id,
          description: @description, # do we actually need this? Seems odd...
          files: {
            @json_file_name => {
              content: task_json
            }
          }
        )
      end

      def find_task_by_id(task_id)
        @tasks.find { |t| t.id == task_id }
      end

      def find_task_by_description(task_description)
        @tasks.find { |t| t.description == task_description }
      end

      def find_last_task_to_be_worked_on
        @tasks.inject(@tasks.first) do |result, task|
          task.last_start_time > result.last_start_time ? task : result
        end
      end

      def ensure_no_tasks_ongoing!
        ongoing_task = @tasks.find(&:ongoing?)
        raise TaskAlreadyOngoing, ongoing_task if ongoing_task
      end

      def ensure_only_one_ongoing_task!
        raise MultipleOngoingTasks if @tasks.count(&:ongoing?) > 1
      end

      def gist_summary_content
        lines = ["## #{User.name} Task Report #{@date.strftime('%Y-%m-%d')}", '']

        @tasks.each do |task|
          lines << "- '#{task.description}'"
          lines << "  - #{task.duration.to_s}"

          task.notes.each do |note|
            lines << "  - #{note}"
          end
        end

        lines << ''
        lines << "#### Total time tracked: #{total_duration.to_s}"

        lines.join("\n")
      end

      def total_duration
        total_time_in_seconds =
          @tasks.inject(0) do |sum, task|
            sum + task.total_time_in_seconds
          end

        Duration.new(total_time_in_seconds)
      end
  end
end
