class Task
  def initialize(task_description)
    @description = task_description
    @time = { start: Time.now }
  end

  def to_hash
    {
      description: @description,
      time: @time
    }
  end
end
