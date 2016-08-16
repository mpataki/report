require 'time' # Time.parse)

class Task
  attr_reader :description

  def self.from_existing_tasks(hash)
    time =
      hash['time'].map do |t|
        {
          start: Time.parse(t['start']),
          end: t['end'].nil? ? nil : Time.parse(t['end'])
        }
      end

    self.new(
      description: hash['description'],
      time: time
    )
  end

  def initialize(description:, time: nil)
    @description = description
    @time = time || [{ start: Time.now, end: nil }]
  end

  def to_hash
    {
      description: @description,
      time: @time
    }
  end

  def stop
    @time.last[:end] = Time.now
  end
end
