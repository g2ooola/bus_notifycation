require 'csv'
require_relative '../toolkits/default_log.rb'

module Subscribtions
  class FileReader
    SUBSCRIBTION_PATH = 'data/subscribtion.csv'
    def read!
      @data ||= begin
        CSV.parse(File.read(SUBSCRIBTION_PATH), headers: true)
      end
    end

    private

    # def station_id_from(row_index:, bus_no:, way:, station_name:)
    #   bus_id = bus_id_map[bus_no]
    #   raise MissingBusId if bus_id.blank?


    # rescue MissingBusId
    #   Toolkits::DefaultLog.logger("Missing Bus ID, row_index: #{row_index}, bus_no: #{bus_no}")
    # end

    # def bus_id_map
    #   @bus_id_map ||= begin
    #   end
    # end

    # def station_id_map(way:, station:)
    # end
  end
end