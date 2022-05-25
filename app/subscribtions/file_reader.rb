require 'csv'
require_relative '../toolkits/default_log.rb'

module Subscribtions
  class FileReader
    attr_reader :original_records, :normalized_data
    SUBSCRIBTION_PATH = 'data/subscribtion.csv'

    def read!
      @data ||= CSV.parse(File.read(SUBSCRIBTION_PATH), headers: true)
    end
  end
end