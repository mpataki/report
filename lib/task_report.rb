require 'task_report/user'
require 'task_report/gist'
require 'task_report/task'
require 'task_report/report'
require 'task_report/duration'

module TaskReport
  class << self
    def start(new_task_description)
      @report ||=
        if report_gist.nil?
          Report.create(new_task_description: new_task_description)
        else
          Report.create_from_gist(report_gist).tap(&:stop_all_tasks)
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

    def summary
      return if no_gist?

      @report ||= Report.create_from_gist(report_gist)
      @report.print_summary
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
  end
end
