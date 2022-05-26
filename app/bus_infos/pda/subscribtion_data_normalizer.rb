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

      class BusIdRepeat < StandardError; end

      def initialize
        @station_id_map = {}
      end

      def exec(subscribtion_records)
        subscribtion_datas = {}
        subscribtion_records.each do |record|
          bus_no = record['bus_no']
          direction = record['direction']
          station_name = record['station_name']
          email = record['email']

          if bus_no.nil? || direction.nil? || station_name.nil? || email.nil?
            raise "Subscriber info error, bus_no: #{bus_no}, direction: #{direction}, station_name: #{station_name}, email: #{email}"
          end

          bus_id = bus_id_map[bus_no]
          station_id = station_id_map(bus_id)&.fetch(direction, nil)&.fetch(station_name, nil)

          if station_id.nil?
            raise "station_id is nil!, bus_no: #{bus_no}, direction: #{direction}, station_name: #{station_name}"
          end

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
            email: email
          })
        rescue StandardError => e
          error_report(e)
        end

        subscribtion_datas
      rescue StandardError => e
        error_report(e)
      end

      private

      # ====== bus id ===== #

      def bus_id_map
        @bus_id_map ||= load_bus_id_map
      end

      def load_bus_id_map
        url_string = 'https://pda.5284.gov.taipei/MQS/routelist.jsp'
        doc = Nokogiri::HTML(URI.open(url_string))
        bus_map = {}

        bus_doms = doc.css('option')
        bus_doms.each do |dom|
          bus_id, bus_no = parse_bus_dom(dom)
          next if bus_id == ''

          if bus_map[bus_no] && bus_map[bus_no] != bus_id
            # 有多線包含同一 station 的狀況, 如幹線公車同時也是低地板公車
            raise BusIdRepeat, "bus_no #{bus_no} repeat!"
          end
          bus_map[bus_no] = bus_id
        rescue BusIdRepeat => e
          error_report(e)
        end

        bus_map
      end

      def parse_bus_dom(dom)
        bus_id = dom.attr('value')
        bus_no = dom.text
        [bus_id, bus_no]
      end

      # ===== station id ====== #

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