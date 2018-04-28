# frozen_string_literal: true

module Crm
  class SalesforcePushTopicListener

    def initialize(client)
      @client = Wrapper.new(client)
    end

    def listen
      @client.authenticate

      EM.run do
        # hit Control + C to stop
        Signal.trap("INT")  {
          puts "User requested stop. Stopping..."
          EventMachine.stop
          puts "Stopped."
          abort
        }

        # Graceful shutdown requested, probably through God
        Signal.trap("TERM") {
          puts "Stopping listener"
          EventMachine.stop
          puts "Stopped"
          abort
        }

        # The restforce client is disconnected roughly every 2 hours
        # There is no upstream fix for now so we just re-connect
        EM.add_periodic_timer(30.minutes.to_i) do
          @client.resubscribe
        end

        yield(@client) if block_given?
      end
    end

    private

    def log(message)
      Rails.logger.info(message)
    end

    class Wrapper
      attr_reader :client

      Subscription = Struct.new(:channels, :block)

      delegate :select, to: :client

      def initialize(client)
        @client = client
        @subscriptions = []
      end

      def subscribe(channels, &block)
        new_subscription = Subscription.new(channels, block)
        do_subscribe(new_subscription)
        @subscriptions << new_subscription
      end

      def resubscribe
        puts "re-subscribing"

        @subscriptions.each do |s|
          channels = Array(s.channels).map { |c| "/topic/#{c}" }
          log "Unsubscribing from #{channels}"
          client.faye.unsubscribe(channels)
        end

        # re-authenticate
        authenticate

        # re-subscribe
        @subscriptions.each do |s|
          do_subscribe(s)
        end

      end

      def authenticate
        client.authenticate!
      end

      private

      def do_subscribe(subscription)
        log "Subscribing to #{subscription.channels}"
        client.subscribe(subscription.channels, &subscription.block)
      end

      def log(message)
        Rails.logger.info(message)
      end
    end

  end
end
