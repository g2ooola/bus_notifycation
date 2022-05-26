require 'net/smtp'
require 'securerandom'

module Notifiers
  class EmailNotifycation < Base
    LOCAL_TIME_ZONE = '+08:00'
    def notify_special_state(email:, bus:, station_name:)
      output ' ===!! notify_special_state'
      output "       email: #{email}"
      output "       bus:   #{bus}"
      output ''
    end

    def notify_bus_will_be_arrived(email:, bus:, station_name:, arrive_minutes:)
      now = Time.now.getlocal(LOCAL_TIME_ZONE)
      arrived_at = now + arrive_minutes * 60

      smtp_info = Toolkits::Secret.info['smtp']
      from_email = Toolkits::Secret.info['from_email']

      sender_domain = 'gsxtw.com'
      to_email = email

      msgstr = <<-EOF
        From: Your Name <#{from_email}>
        To: Destination Address <#{to_email}>
        Subject: Bus(#{bus}) Will Arrive
        Date: #{now}
        Message-Id: <#{SecureRandom.hex}@mervin.com>

        Hi,
        Your bus (#{bus}) will arrive in #{arrive_minutes} minutes (#{arrived_at}).
      EOF

      result = Net::SMTP.start(
        smtp_info['server'],
        smtp_info['port'],
        smtp_info['sender_domain'],
        smtp_info['account'],
        smtp_info['password'],
        smtp_info['auth']) do |smtp|

        smtp.send_message(msgstr, from_email, to_email)
      end

      error_report('send email fail') unless result.success?
    end
  end
end