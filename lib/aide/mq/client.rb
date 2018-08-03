# frozen_string_literal: true

module Aide
  module MQ
    #
    # Main interaction point with RabbitMQ
    #
    # Pass in a Connection instance or give the initializer a config block to
    # create a Connection instance
    #
    # @example
    #  client = Aide::MQ::Client.new(name: 'cool_connection_name') do |config|
    #    # e.g. See Aide::MQ::ConnectionConfiguration for all available settings
    #    config.connection.host = 'localhost'
    #    config.connection.port = 5672
    #    config.connection.user = 'guest'
    #    config.mock            = true
    #    config.logger          = CustomLogger.new
    #  end
    #  client.publish 'cool_queue_name', Aide::MQ::Payload(data: { hi: :ok })
    #
    #  # OR
    #
    #  conn = Aide::MQ::Connection.new(name: 'hi') do |c|
    #    c.connection.host = 'localhost'
    #    c.connection.port = 5672
    #    c.connection.user = 'guest'
    #    c.mock            = true
    #    c.logger          = CustomLogger.new
    #  end
    #  client = Aide::MQ::Client.new(name: 'cool_name', connection: conn)
    #  client.publish 'cool_queue_name', Aide::MQ::Payload(data: { hi: :ok })
    #
    class Client
      attr_reader :name,
                  :connection,
                  :logger,
                  :config

      # @param name       [Symbol, String]
      # @param connection [Aide::MQ::Connection]
      def initialize(name:, connection: nil, &block)
        @name       = name
        @connection = connection || Connection.new(name: name, &block)
        @logger     = @connection.logger
        @config     = @connection.config
      end

      # @param name [Symbol, String]
      def queue(name)
        channel do |ch|
          yield ch.queue(name,
                         exclusive:   false,
                         auto_delete: false,
                         durable:     true)
        end
      end

      # @param q_name  [Symbol, String] a name for a RabbitMQ queue
      # @param payload [Aide::MQ::Payload] or any object with #to_json
      def publish(q_name, payload)
        queue(q_name) do |q|
          q.publish(payload.to_json)
        end
      end

      # @param q_name [Symbol, String] a name for a RabbitMQ queue
      def subscribe(q_name)
        queue(q_name) do |q|
          q.subscribe do |delivery_info, properties, payload|
            yield delivery_info,
                  properties,
                  Payload.new(JSON.parse(payload))
          end
        end
      end

      def reset_connection!
        connection.reset_connection
      end

      def channel(&block)
        connection.channel &block
      end

      def inspect
        "#<#{self.class.name} name=#{name} connection=#{connection.inspect}>"
      end
    end
  end
end
