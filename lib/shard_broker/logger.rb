module ShardBroker
  class Logger

    def initialize
      @line_number  = 0
      @logger       = ::Logger.new(File.expand_path('../../../log/server.log',  __FILE__), 'weekly')
      @logger.formatter = proc do |severity, datetime, progname, msg|
        type = severity
        if type == "DEBUG"
          @line_number += 1
          out = sprintf("#{"%5d".bold.black_on_white} %s\n", @line_number, msg)
        elsif type == "WARN"
          out = ("WARN".bold.yellow + " #{msg.yellow}\n".yellow).yellow
        elsif type == "ERROR"
          out =("ERROR".bold.red + " #{msg.red}\n".red).red
        else
          type = type.bold
          out = "#{" #{type}".bold.black_on_white} #{datetime.strftime("%T %D")}: #{msg}\n"
        end
        puts out
        out
      end
    end

    def getLogger
      @logger
    end
  end
end