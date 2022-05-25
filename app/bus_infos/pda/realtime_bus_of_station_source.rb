require 'net/http'
require 'json'

require_relative '../../base.rb'

module BusInfos
  module Pda
    class RealtimeBusOfStationSource < Base

      def get_from_api(station_id)
        response_data = bus_info_on_station_from_api(station_id.to_s)
        parse_bus_info_on_station(response_data)
      rescue StandardError => e
        error_report(e)
        nil
      end

      private

      def bus_info_on_station_from_api(station_id)
        # Sample URL:
        #   https://pda.5284.gov.taipei/MQS/StopDyna?stopid=38878&nocache=1653149998438
        raise 'station_id is blank' if station_id == ''

        uri = URI('https://pda.5284.gov.taipei/MQS/StopDyna')
        params = { :nocache => Time.now.to_i * 1000, :stopid => station_id }
        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)

        unless res.is_a?(Net::HTTPSuccess)
          raise 'API get_station_info fail!'
        end

        response_data = JSON.parse(res.body)
      end

      STOP_ID = 1
      ARRIVE_STATE = 7

      def parse_bus_info_on_station(response_data)
        # Sample of response_data :
        # {
        #   "UpdateTime": "2022-05-22 16:15:10",
        #   "id": 38878,
        #   "n1": "N1,38878,10785,222237940,38867,38902,0,1143,10,0,2,220522161311,08580762,220522161311,47928085"
        # }
        #
        # State of arrive state :
        #   > 0 : 再過 x 秒進站,
        #   '0':  '進站中',
        #   '':   '未發車',
        #   '-1': '未發車',
        #   '-2': '交管不停',
        #   '-3': '末班已過',
        #   '-4': '今日未營運'

        details = response_data['n1'].split(',')
        arrive_state = details[ARRIVE_STATE]
        return -1 if ['', '-1', '-2', '-3', '-4'].include? arrive_state

        accive_sec = details[ARRIVE_STATE].to_i
      end
    end
  end
end