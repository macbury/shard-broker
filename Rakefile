require "rubygems"
require "bundler/setup"

require_relative "lib/boot"

namespace :db do

  desc "Migrate the db"
  task :migrate do
    EventMachine.synchrony do
      connection_details = ShardBroker.connectToDB
      ActiveRecord::Migrator.migrate("db/migrate/")
      EM.stop
    end
  end

  desc "Rollback the db"
  task :rollback do
    EventMachine.synchrony do
      connection_details = ShardBroker.connectToDB
      ActiveRecord::Migrator.rollback("db/migrate/")
      EM.stop
    end
  end

  desc "Create the db"
  task :create do
    EventMachine.synchrony do
      connection_details = ShardBroker.connectToDB
      ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
      EM.stop
    end
  end

  desc "drop the db"
  task :drop do
    EventMachine.synchrony do
      connection_details = ShardBroker.connectToDB
      ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
      EM.stop
    end
  end
end