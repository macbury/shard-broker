module ShardBroker
  
  def self.env
    :development 
  end

  def self.logger
    @logger ||= ShardBroker::Logger.new
    @logger.getLogger
  end

  def self.server
    @server ||= ShardBroker::Server.new
  end

  def self.connectToDB
    dbconfig = YAML::load(File.open(File.expand_path('../../database.yml',  __FILE__)))
    ActiveRecord::Base.logger = self.logger
    ActiveRecord::Base.establish_connection(dbconfig)
    dbconfig
  end

  def self.start
    EventMachine.run do
      connectToDB
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }
      ShardBroker.logger.info "Starting server on port 50000"
      EventMachine.start_server("0.0.0.0", 50000, ShardBroker::Connection)
    end
  end
  
end