require_relative './base.rb'

class IntevalChecker < Base
  def initialize(subscribed_source:, bus_info_source:, notifier:)
    @subscribed_source = subscribed_source
    @bus_info_source = bus_info_source
    @notifier = notifier
  end

  def exec
    subscribed_records = @subscribed_source.read!
    subscribtion_datas = @bus_info_source.normalize(subscribed_records)

    regularly_exec(
      subscribtion_datas: subscribtion_datas,
      bus_info_source: @bus_info_source,
      notifier: @notifier
    )
  end

  private

  # Sample of subscribtion_datas:
  # [{
  #   target: {
  #     bus_no: 'name',
  #     direction: '去程',
  #     station_name: 'xxx',
  #     station_id: 1,
  #   },
  #   notified_at: nil,
  #   subscribers: [{
  #     email: 'someone@email.com',
  #     phone: ''
  #   }]
  # }]

  def regularly_exec(subscribtion_datas:, bus_info_source:, notifier:)
    # TODO: 視情況改用 multi threads (or sidekiq) 通知
    loop do
      check_and_notify(
        subscribtion_datas: subscribtion_datas,
        bus_info_source: bus_info_source,
        notifier: notifier
      )

      sleep(inteval)
    end
  end

  def check_and_notify(subscribtion_datas:, bus_info_source:, notifier:)
    subscribtion_datas.each do |station_id, subscribtion_data|
      bus_arrive_sec = bus_info_source.realtime_bus_info_of_station(station_id)
      raise 'bus_arrive_sec is blank' if bus_arrive_sec.nil?

      notifier.notify_if_need(
        bus_arrive_sec: bus_arrive_sec,
        subscribtion_data: subscribtion_data
      )
    rescue StandardError => e
      error_report(e)
    end
  rescue StandardError => e
    error_report(e)
  end

  def inteval
    @inteval ||= local_test? ? 3 : 60
  end
end