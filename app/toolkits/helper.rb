require 'logger'

module Toolkits
  class Helper
    def self.time_to_string(time)
      time.getlocal('+08:00').to_s
    end

    def self.string_to_time(time_string)
      Time.parse(time_string)
    end
  end
end