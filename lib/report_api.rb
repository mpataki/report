module ReportAPI
  class << self
    def start(new_task_description)
      report_gist =
        Gist.find_gist_from_today_by_description(Report.gist_description)

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
  end
end
