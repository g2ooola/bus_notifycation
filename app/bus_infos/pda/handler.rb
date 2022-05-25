require_relative '../../base.rb'
require_relative './realtime_bus_of_station_source.rb'
require_relative './subscribtion_data_normalizer.rb'

module BusInfos
  module Pda
    class Handler < Base
      def initialize
        @normalizer = SubscribtionDataNormalizer.new
        @realtime_bus_info_reader = RealtimeBusOfStationSource.new
      end

      def normalize(subscribtion_records)
        @normalizer.exec(subscribtion_records)
      end

      def realtime_bus_info_of_station(station_id)
        @realtime_bus_info_reader.get_from_api(station_id)
      end
    end
  end
end