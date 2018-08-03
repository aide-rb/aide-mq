# frozen_string_literal: true

require 'connection_pool'

module Aide
  module MQ
    #
    # A threadsafe RabbitMQ connection
    #
    # Be warned that every instance sets its own global variable
    class Connection
      attr_reader :name, :config, :bunny_client

      # @param config [ConnectionConfiguration]
      def initialize(name:,
                     config:       nil,
                     bunny_client: nil,
                     &block)
        @name         = name
        @config       = config || ConnectionConfiguration.build(name, &block)
        @bunny_client = bunny_client.nil? ? init_bunny_client : bunny_client

        # Purposefully creating / destroying global variables in order to share
        # connection between threads (as connection is thread safe)
        #
        @global_variable_string = "$rabbit_mq_connection_#{object_id}"

        reset_connection
        define_finalizer
      end

      def logger
        config.logger
      end

      def channel(&block)
        channel_pool.with &block
      end

      def reset_connection
        self.global_connection = init_connection
        reset_channel_pool
        self
      end

      def close_connection
        global_connection.close
        self
      end

      def inspect
        "#<#{self.class.name}:#{object_id} name=#{name}>"
      end

      private

      attr_accessor :global_connection, :channel_pool
      attr_reader :global_variable_string

      def init_connection
        client = bunny_client.new(config.connection_settings)
        client.start
        binding.eval("#{global_variable_string} = client",
                     __FILE__,
                     __LINE__ - 2)
        client
      end

      # needed as channels are NOT thread-safe
      def reset_channel_pool
        self.channel_pool = ConnectionPool.new do
          global_connection.create_channel
        end
      end

      def init_bunny_client
        if config.mock
          require 'bunny-mock' unless Object.const_defined?(:BunnyMock)
          BunnyMock
        else
          Bunny
        end
      end

      def define_finalizer
        ObjectSpace.define_finalizer(
          self,
          proc do |_id|
            binding.eval("#{global_variable_string} = nil",
                         __FILE__,
                         __LINE__ - 2)
          end
        )
      end
    end
  end
end
