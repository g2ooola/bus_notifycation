require 'logger'

module Toolkits
  class DefaultLog
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end