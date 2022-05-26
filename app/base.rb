class Base
  def output(text)
    output_logger.info(text)
    text
  end

  def error_report(error)
    if error.is_a?(StandardError)
      error_logger.error(error.full_message)
    else
      error_logger.error(error)
    end
  end

  def local_test?
    @local_test ||= ENV['LOCAL_TEST'] == 'true'
  end

  def output_logger
    @output_logger ||= Logger.new(STDOUT)
  end

  def error_logger
    @output_logger ||= Logger.new('./log/error.log')
  end
end