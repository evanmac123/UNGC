# frozen_string_literal: true

require_relative "../crm"

module Crm
  class Listener
    attr_accessor :log_file, :pid_file, :log_level, :logger

    def initialize(log_file: nil, log_level: "info",
                   pid_file: nil, listener: nil, daemonize: true)
      @log_file = log_file || "log/crm-listener.log"
      @pid_file = pid_file || "pids/crm-listener.pid"
      @log_level = log_level
      @listener = listener || SalesforcePushTopicListener.new(::Crm.create_client)
      @logger = create_logger
      @daemonize = daemonize
    end

    def listen
      daemonize if @daemonize
      write_pid_file

      log "Starting CRM listener..."
      @listener.listen do |client|
        client.subscribe "OpportunityUpdates" do |message|
          log "Opportunity/Contribution message received: #{unpack(message)}"
        end
      end
      log "Listening for CRM events."
    end

    private

    def write_pid_file
      File.open(pid_file, "w") do |f|
        pid = Process.pid
        log "writing pid #{pid} to pidfile #{pid_file}"
        puts "running as process #{pid}"
        f << pid
      end
    end

    def daemonize
      log "daemonizing"
      puts "daemonizing"
      Process.daemon(true, true)
    end

    def create_logger
      Logger.new(log_file).tap do |l|
        l.level = Logger.const_get(log_level.upcase)
      end
    end

    def log(message)
      logger.info(message)
    end

    def unpack(message)
      event = message.fetch("event", {}).fetch("type")
      attributes = message.fetch("sobject")
      id = attributes.fetch("Id")
      [event, id, attributes]
    end
  end
end
