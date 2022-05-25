require_relative './toolkits/default_log.rb'

class Base
  def output(text)
    Toolkits::DefaultLog.logger.info(text)
    text
  end

  def error_report(error)
    if error.is_a?(StandardError)
      Toolkits::DefaultLog.logger.error(error.full_message)
    else
      Toolkits::DefaultLog.logger.error(error)
    end
  end

  def local_test?
    @local_test ||= ENV['LOCAL_TEST'] == 'true'
  end
end