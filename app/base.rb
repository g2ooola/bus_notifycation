require_relative './toolkits/default_log.rb'

class Base
  def output(text)
    Toolkits::DefaultLog.logger.info(text)
    nil
  end

  def error_report
    # todo
  end
end