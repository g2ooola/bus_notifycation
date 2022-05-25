require 'time'
require_relative '../toolkits/default_log.rb'
require_relative '../toolkits/helper.rb'
require_relative './test_email_notifycation.rb'
require_relative './email_notification.rb'

module Notifiers
  # TODO: 視情況加入手機或其他方式通知
  # TODO: 視情況改成 batch 發送通知

  class Handler < Base
    MINUTES_TO_NOTIFY = self.new.local_test? ? 0.2 : 7
    SECONDS_TO_NOTIFY = MINUTES_TO_NOTIFY * 60

    def notify_if_need(bus_arrive_sec:, subscribtion_data:)
      return output("time_too_long #{bus_arrive_sec}") if time_too_long?(bus_arrive_sec)
      return output('notify_too_close') if notify_too_close?(subscribtion_data)

      result = if in_special_state?(bus_arrive_sec)
        notify_cancel_to_all(subscribtion_data)
      else
        notify_arrived_to_all(bus_arrive_sec: bus_arrive_sec, subscribtion_data: subscribtion_data)
      end

      mark_notifyed(subscribtion_data)
      result
    end

    private

    def in_special_state?(bus_arrive_sec)
      bus_arrive_sec == -1
    end

    def time_too_long?(bus_arrive_sec)
      bus_arrive_sec > 0 && bus_arrive_sec > SECONDS_TO_NOTIFY
    end

    def notify_too_close?(subscribtion_data)
      return false if subscribtion_data[:notified_at].nil?
      
      notified_at = Toolkits::Helper.string_to_time(subscribtion_data[:notified_at])
      Time.now - notified_at < SECONDS_TO_NOTIFY
    end

    def notify_cancel_to_all(subscribtion_data)
      subscribers = subscribtion_data[:subscribers]

      subscribers.map do |contact_way|
        email_notifier.notify_special_state(
          email: contact_way[:email],
          bus: subscribtion_data[:target][:bus_no],
          station_name: subscribtion_data[:target][:station_name]
        )
      end
    end

    def notify_arrived_to_all(bus_arrive_sec:, subscribtion_data:)
      subscribers = subscribtion_data[:subscribers]

      subscribers.map do |contact_way|
        email_notifier.notify_bus_will_be_arrived(
          email: contact_way[:email],
          bus: subscribtion_data[:target][:bus_no],
          station_name: subscribtion_data[:target][:station_name],
          arrive_minutes: MINUTES_TO_NOTIFY
        )
      end
    end

    def mark_notifyed(subscribtion_data)
      subscribtion_data[:notified_at] = Toolkits::Helper.time_to_string(Time.now)
    end

    def email_notifier
      @email_notifier ||= begin
        local_test? ? TestEmailNotifycation.new : EmailNotifycation.new
      end
    end
  end
end