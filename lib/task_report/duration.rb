module TaskReport
  class Duration
    attr_accessor :seconds

    def initialize(seconds)
      @seconds = seconds.floor
    end

    def to_s
      min, sec = @seconds.divmod(60)
      min %= 60
      hour, _ = @seconds.divmod(3600)

      result = []
      result << "#{hour} hours"  if hour > 0
      result << "#{min} mins"    if min > 0
      result << "#{sec} seconds" if sec > 0

      result.join(', ')
    end
  end
end
