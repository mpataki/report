module ReportAPI
  class << self
    def start(new_task_description)
      gists = Gist.get_recent_gists_for_user
      report_gist = find_report_gist_from_today(gists)

      report =
        if report_gist.nil?
          Report.create(new_task_description: new_task_description)
        else
          report = Report.create(report_gist: report_gist)
          report.stop_all_tasks
          report.start_task(new_task_description)
          report
        end

      report.save_to_gist!
    end

    private
      # returns nil if none exist
      def find_report_gist_from_today(gists)
        description = Report.gist_description
        gists.find { |gist| gist['description'] == description }
      end
  end
end
