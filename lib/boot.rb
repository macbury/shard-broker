require "rubygems"
require "bundler/setup"
require 'yaml'

require "logger"
require "colored"
require "eventmachine"
require "thor"

require 'rexml/document'
require 'rexml/parsers/sax2parser'
require "rexml/formatters/transitive"

require "em-synchrony"
require "em-synchrony/mysql2"
require "em-synchrony/activerecord"

require_relative "commands"
require_relative "shard_broker"
require_relative "shard_broker/status"
require_relative "shard_broker/node"
require_relative "shard_broker/response"
require_relative "shard_broker/ping"
require_relative "shard_broker/action"
require_relative "shard_broker/state"
require_relative "shard_broker/parser"
require_relative "shard_broker/protocol_tags"
require_relative "shard_broker/connection"
require_relative "shard_broker/logger"
require_relative "shard_broker/server"

require_relative "shard_broker/models/user"
require_relative "shard_broker/models/peer"
require_relative "shard_broker/models/relationship"