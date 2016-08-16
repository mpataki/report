require 'time' # Time.parse)
require 'securerandom'

class Task
  TaskOngoing = Class.new StandardError

  attr_reader :id, :description

  def self.from_existing_tasks(hash)
    time =
      hash['time'].map do |t|
        {
          start: Time.parse(t['start']),
          end: t['end'].nil? ? nil : Time.parse(t['end'])
        }
      end

    self.new(
      id: hash['id'],
      description: hash['description'],
      time: time
    )
  end

  def initialize(description:, time: nil, id: nil)
    @description = description
    @time = time || [{ start: Time.now, end: nil }]
    @id = id || SecureRandom.hex(4)
  end

  def to_hash
    {
      id: @id,
      description: @description,
      time: @time
    }
  end

  def to_s
    "Task #{@id}, '#{@description}'"
  end

  def stop
    return unless @time.last[:end].nil?
    puts "Stopping #{self.to_s}"
    @time.last[:end] = Time.now
  end

  def continue
    raise TaskOngoing if @time.last[:end].nil?
    puts "Continueing #{self.to_s}"
    @time << { start: Time.now, end: nil }
  end

  def last_start_time
    @time.last[:start]
  end

  def ongoing?
    @time.last[:end].nil?
  end
end
