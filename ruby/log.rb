class Logger

  def initialize level, file=nil
    @level = level
    @file  = file
  end

  def self.chang_roberts id, dir=nil
    dir  = dir || File.dirname(__FILE__)
    name = "chang_roberts_#{id}.log"
    file = File.join [dir, name]
    new :CHANG_ROBERTS, file
  end

  def log message
    message = format_message message

    if @file
      log_message_to_file message
    else
      log_message_to_screen message
    end
  end

  def format_message message
    "(#{Time.now}) [#{@level}] #{message}"
  end

  private

  def log_message_to_file message
    File.open(@file, "a+") { |file| file.puts message }
  end

  def log_message_to_screen message
    Thread.exclusive { puts message }
  end

end