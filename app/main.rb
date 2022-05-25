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

require_relative './bus_infos/pda/handler.rb'
require_relative './notifiers/handler.rb'
require_relative './subscribtions/file_reader.rb'
require_relative './inteval_checker.rb'
require_relative './base.rb'

class MainFlow < Base
  def initialize
    output " local_test? #{local_test?}"
  end

  def start
    subscribed_source = Subscribtions::FileReader.new
    bus_info_source = BusInfos::Pda::Handler.new
    notifier = Notifiers::Handler.new

    interval_checker = IntevalChecker.new(
      subscribed_source: subscribed_source,
      bus_info_source: bus_info_source,
      notifier: notifier
    )

    interval_checker.exec
  end
end

MainFlow.new.start