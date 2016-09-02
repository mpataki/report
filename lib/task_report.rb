require 'yaml'
require 'task_report/user'
require 'task_report/gist'
require 'task_report/task'
require 'task_report/report'
require 'task_report/duration'

module TaskReport
  class << self
    def read_config
      config_path = File.expand_path('~/.task_report_config')
      config = YAML.load(File.read(config_path))
      TaskReport::User.name = config.fetch('user')
      TaskReport::User.api_token = config.fetch('personal_access_token')
    rescue Errno::ENOENT
      puts 'Config file not found. It should be located at ~/.task_report_config.'
      puts 'See https://github.com/mpataki/task_report for help.'
      puts 'Exiting'
      exit 1
    rescue Psych::SyntaxError
      puts 'The config file must be valid yaml syntax.'
      puts 'Exiting'
      exit 1
    rescue KeyError
      puts 'Config key not found.'
      puts 'Required configuration keys are `user` and `personal_access_token`'
      puts 'See an example at https://github.com/mpataki/task_report'
      puts 'Exiting'
      exit 1
    end

    def start(new_task_description)
      if report_gist.nil?
        @report ||= Report.create(new_task_description: new_task_description)
      else
        @report ||= Report.create_from_gist(report_gist)
        @report.stop_all_tasks
      end

      @report.start_task(new_task_description)
      @report.save_to_gist!
    rescue Report::TaskAlreadyTracked
      puts "Task '#{new_task_description}' is already being tracked. Continuing the task."
      continue(new_task_description)
    end

    def stop
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)
      @report.stop_all_tasks
      @report.save_to_gist!
      puts "All tasks stopped"
    end

    def continue(task_id)
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)
      @report.continue(task_id)
      @report.save_to_gist!
    rescue Report::TaskAlreadyOngoing, Task::TaskOngoing => e
      puts "Task already underway - #{e.message}"
    end

    def list
      return if no_gist?
      (@report || Report.create_from_gist(report_gist)).print_tasks
    end

    def delete(identifier)
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)

      case identifier
      when 'today'
        @report.delete_all
      when 'gist'
        puts "Deleting today's report gist"
        Gist.delete(@report.gist_id)
        return
      else
        @report.delete(identifier)
      end

      @report.save_to_gist!
    rescue Report::TaskDNE
      puts "Task '#{identifier}' does not exist - nothing to do."
    end

    def current
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)
      @report.print_current_task
    rescue Report::MultipleOngoingTasks
      puts 'Something went wrong. There are multiple ongoing tasks.'
    end

    def summary(gist, from, to)
      if from
        return range_summary(gist, from, to || Time.now.strftime('%Y-%m-%d'))
      end

      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)

      if gist
        @report.gist_summary
      else
        @report.print_summary
      end
    end

    def print_range_summary_to_gist(reports, from, to)
      content = reports.map { |r| r.gist_summary_content }.compact.join("\n\n")
      file_name = "task_report_#{from}_-_#{to}.md"

      gist =
        Gist.create_or_update(
          {
            public: false,
            description: "Task Report: #{from} - #{to}",
            files: {
              file_name => {
                content: content
              }
            }
          },
          Time.parse(from)
        )

      puts gist['html_url']
    end

    def note(task_id, note)
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)
      @report.add_note(task_id, note)

      @report.save_to_gist!
    rescue Report::TaskDNE
      puts "Task '#{identifier}' does not exist - nothing to do."
    end

    def total
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)
      @report.total
    end

    private
      def report_gist
        @report_gist ||=
          Gist.find_gist_from_today_by_description(
            Report.gist_description
          )
      end

      def no_gist?
        if report_gist.nil?
          puts 'No report exists for today - nothing to do.'
          puts 'See `task help` for usage info.'
          return true
        end

        false
      end

      def find_reports(from, to)
        from_time = Time.parse(from)
        from_epoch = from_time.to_i

        to_epoch =
          if to
            Time.parse(to).to_i
          else
            now = Time.now
            Time.new(now.year, now.month, now.day).to_i
          end

        seconds_in_a_day = 86400
        descriptions = []

        (from_epoch..to_epoch).step(seconds_in_a_day) do |epoch|
          descriptions << Report.gist_description(Time.at(epoch))
        end

        gists = Gist.find_gists_by_descriptions(descriptions, from_time)
        gists.map { |gist| Report.create_from_gist(gist) }
      end

      def range_summary(gist, from, to)
        reports = find_reports(from, to).reverse

        if gist
          print_range_summary_to_gist(reports, from, to)
        else
          reports.map(&:print_summary)
        end
      end
  end
end
