class Command < Thor
  desc "start", "start demon"
  method_option :demon, type: :boolean, default: false
  def start
    ShardBroker.start
  end
  
  desc "console", "enter console"
  def console
    ShardBroker.console
  end  

  desc "stop", "stop demon"
  def stop
    #Peon.stop
  end  
end

