class Command < Thor
  desc "start", "start demon"
  method_option :demon, type: :boolean, default: false
  def start
    ShardBroker.start
  end
  
  desc "stop", "stop demon"
  def stop
    #Peon.stop
  end  
end

