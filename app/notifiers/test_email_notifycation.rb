
module Notifiers
  class TestEmailNotifycation < Base
    LOCAL_TIME_ZONE = '+08:00'
    def notify_special_state(email:, bus:, station_name:)
      output ' ===!! notify_special_state'
      output "       email: #{email}"
      output "       bus:   #{bus}"
      output ''

      'notify_special_state'
    end

    def notify_bus_will_be_arrived(email:, bus:, station_name:, arrive_minutes:)
      arrived_at = Time.now.getlocal(LOCAL_TIME_ZONE) + arrive_minutes * 60
      output ' ===   notify_bus_will_be_arrived'
      output "       email:          #{email}"
      output "       bus:            #{bus}"
      output "       arrive_minutes: #{arrive_minutes}"
      output "       arrived_at:     #{arrived_at}"
      output ''

      'notify_bus_will_be_arrived'
    end
  end
end