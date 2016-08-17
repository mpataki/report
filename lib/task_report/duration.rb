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

      "#{hour} hours, #{min} minutes, #{sec} seconds"
    end
  end
end
