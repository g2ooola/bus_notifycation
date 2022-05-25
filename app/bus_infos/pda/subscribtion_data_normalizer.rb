require 'net/http'
require 'json'
require 'nokogiri'
require 'open-uri'

require_relative '../../base.rb'

# Sample of subscribtion_records:
# [
#   { 'email' => 'e1@email.com', 'bus_no' => '672', 'direction' => '去程', 'station_name' => '秀朗國小' },
#   { 'email' => 'e2@email.com', 'bus_no' => '棕1', 'direction' => '回程', 'station_name' => '公教住宅' },
#   { 'email' => 'e3@email.com', 'bus_no' => '672', 'direction' => '去程', 'station_name' => '秀朗國小' }
# ]
#
# Note: In fact, subscribtion_records is a CSV::Table, not a hash.

module BusInfos
  module Pda
    class SubscribtionDataNormalizer < Base
      def initialize
        @station_id_map = {}
      end

      def exec(subscribtion_records)
        subscribtion_datas = {}
        subscribtion_records.each do |record|
          bus_no = record['bus_no']
          bus_id = bus_id_map[bus_no]

          direction = record['direction']
          station_name = record['station_name']
          station_id = station_id_map(bus_id)&.fetch(direction, nil)&.fetch(station_name, nil)

          subscribtion_datas[station_id] ||= {
            target: {
              bus_no: bus_no,
              direction: direction,
              station_name: station_name,
              station_id: station_id
            },
            subscribers: []
          }
          subscribtion_datas[station_id][:subscribers].push({
            email: record['email']
          })
        end

        subscribtion_datas
      end

      private

      FILE_PATH = 'data/pad_bus_no.json'
      def bus_id_map
        @bus_id_map ||= begin
          JSON.parse(File.read(FILE_PATH))
        end
      end

      def station_id_map(rid)
        @station_id_map[rid.to_i] ||= load_station_id_map(rid)
      end

      def load_station_id_map(rid)
        url_string = "https://pda.5284.gov.taipei/MQS/route.jsp?rid=#{rid}"
        doc = Nokogiri::HTML(URI.open(url_string))
        station_map = {}

        go_doms = doc.css('.ttego1,.ttego2')
        station_map['去程'] = build_station_map(go_doms)

        back_doms = doc.css('.tteback1,.tteback2')
        station_map['回程'] = build_station_map(back_doms)
 
        station_map
      end

      def parse_station_dom(dom)
        target_ele = dom.children[0].child
        sid = target_ele.attr('href').split(/sid=(\d+)/)[1]
        station_name = target_ele.text
        [sid, station_name]
      end

      def build_station_map(doms)
        station_map = {}
        doms.each do |dom|
          sid, station_name = parse_station_dom(dom)
          station_map[station_name] = sid
        end

        station_map
      end
    end
  end
end