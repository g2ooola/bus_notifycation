# INIT
  # read subscript data

  # trans `input` to `subscript-data-object`
    # [{
    #   target: {
    #     station_name: 'xxx',
    #     bus_way: '去/回',
    #     bus_no: '672',
    #     started_at: '17:00',
    #     ended_at: '18:00',
    #   },
    #   subscriber: {
    #     email: '',
    #     phone: ''
    #   }
    # }]

  # trans `subscript-data-object` to `api-target-data-object`
    # [
    #   station_id_1, station_id_2
    # ]

    # [{
    #   target: {
    #     bus_no: 'name',
    #     station_name: 'xxx',
    #     station_id: 1,
    #     started_at_int_delta: 61200,
    #     ended_at_int_delta: 64800
    #   },
    #   subscribers: {
    #     notified_at: nil,
    #     all_contact_way: [{
    #       email: '',
    #       phone: ''
    #     }]
    #   }
    # }]

# API
  # get bus data

  # trans `api-return` to `realtime-data-object`

# NOTIFY
  # check notify hite by `subscript-data-object`, `realtime-data-object`

  # send notify

require_relative './bus_infos/pda/realtime_bus_of_station_source.rb'
require_relative './notifiers/handler.rb'

class MainFlow
  def test
    # bus_info_source = BusInfos::PdaSource.new
    # result = bus_info_source.get_from_api(38878)
    # puts result

    subscribed_record = {
      target: {
        bus_no: 'name',
        station_name: 'xxx',
        station_id: 1,
        started_at_int_delta: 61200,
        ended_at_int_delta: 64800
      },
      subscribers: {
        notified_at: nil,
        all_contact_way: [{
          email: '',
          phone: ''
        }]
      }
    }
    # '2022-05-22 17:15:10 +0800'

    notifier = Notifiers::Handler.new
    notifier.notify_if_need(
      bus_arrive_sec: 300,
      subscribe_record: subscribed_record
    )
  end

  def start
    subscribed_source = Subscribtions::FileReader.new
    bus_info_source = BusInfos::PdaSource::Handler.new
    notifier = Notifiers::Handler.new

    subscribed_records = subscribed_source.read!
    subscribtion_datas = bus_info_source.normalizer(subscribed_records)

    regularly_exec(
      subscribtion_datas: subscribtion_datas,
      bus_info_source: bus_info_source,
      notifier: notifier
    )
    
  end

  def regularly_exec(subscribtion_datas:, bus_info_source:, notifier:)
    loop do
      check_and_notify(
        subscribtion_datas: subscribtion_datas,
        bus_info_source: bus_info_source,
        notifier: notifier
      )

      sleep(60)
    end
  end

  # todo 通知過的不再通知
  def check_and_notify(subscribtion_datas:, bus_info_source:, notifier:)
    subscribtion_datas.each do |subscribed_record|
      bus_arrive_sec = bus_info_source.realtime_bus_info_of_station(subscribed_record[:station_id])
      notifier.notify_if_need(
        bus_arrive_sec: bus_arrive_sec,
        subscripers: subscribed_record[:subscribers]
      )
    end
  end
end

MainFlow.new.test