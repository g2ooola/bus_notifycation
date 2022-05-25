require 'time'
require_relative '../toolkits/default_log.rb'
require_relative './test_email_notifycation.rb'
require_relative './email_notification.rb'

module Notifiers
  # TODO: 視情況加入手機或其他方式通知
  # TODO: 視情況改成 batch notify
  # TODO: 視情況改用 multi threads 通知

  class Handler < Base
    MINUTES_TO_NOTIFY = 7
    SECONDS_TO_NOTIFY = MINUTES_TO_NOTIFY * 60
    def initialize(local_test: false)
      @local_test = local_test
    end

    def notify_if_need(bus_arrive_sec:, subscribe_record:)
      subscribers = subscribe_record[:subscribers]
      return output('time_too_long') if time_too_long?(bus_arrive_sec)
      return output('notify_too_close') if notify_too_close?(subscribers)

      # in special state
      if in_special_state?(bus_arrive_sec)
        notify_cancel_to_all(subscribe_record)
      else
        notify_arrived_to_all(bus_arrive_sec: bus_arrive_sec, subscribe_record: subscribe_record)
      end
    end

    private

    def in_special_state?(bus_arrive_sec)
      bus_arrive_sec == -1
    end

    def time_too_long?(bus_arrive_sec)
      bus_arrive_sec > SECONDS_TO_NOTIFY
    end

    def notify_too_close?(subscribers)
      return false if subscribers[:notified_at].nil?
      
      notified_at = Time.parse(subscribers[:notified_at])
      notified_at - Time.now < SECONDS_TO_NOTIFY
    end

    def notify_cancel_to_all(subscribe_record)
      subscribers = subscribe_record[:subscribers]
      email_notifier = get_email_notifier

      subscribers[:all_contact_way].each do |contact_way|
        email_notifier.notify_special_state(
          email: contact_way[:email],
          bus: subscribe_record[:target][:bus_no],
          station_name: subscribe_record[:target][:station_name]
        )
      end
    end

    def notify_arrived_to_all(bus_arrive_sec:, subscribe_record:)
      subscribers = subscribe_record[:subscribers]
      email_notifier = get_email_notifier

      subscribers[:all_contact_way].each do |contact_way|
        email_notifier.notify_bus_will_be_arrived(
          email: contact_way[:email],
          bus: subscribe_record[:target][:bus_no],
          station_name: subscribe_record[:target][:station_name],
          arrive_minutes: MINUTES_TO_NOTIFY
        )
      end
    end

    def get_email_notifier
      @local_test ? TestEmailNotifycation.new : EmailNotifycation.new
    end
  end
end