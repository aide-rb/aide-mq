# frozen_string_literal: true

module Aide
  module MQ
    #
    # Use ::build with a configuration block to return a configured class
    #
    # Configured class has API:
    # - ::connection_settings
    # - ::connection_name
    # - readers set below
    #
    module ConnectionConfiguration
      class << self
        def build(connection_name, &block)
          block_given? or
            raise ArgumentError, 'ConnectionConfiguration needs a config block'

          new_config_klass.tap do |k|
            k.instance_variable_set :@connection_name, connection_name
            k.configure(&block)
            k.finalize!
          end
        end

        private

        def new_config_klass
          Class.new do
            extend Dry::Configurable
            setting :mock,   true,               reader: true
            setting :logger, Logger.new(STDOUT), reader: true

            setting :connection, reader: true do
              setting :host,           'localhost'
              setting :port,           5_672
              setting :user,           'guest'
              setting :pass,           'guest'
              setting :vhost,          '/'
              setting :ssl,            false
              setting :heartbeat,      :server, &:to_sym
              setting :frame_max,      131_072
              setting :auth_mechanism, 'PLAIN'
              setting :threaded,       true
              setting :tls
              setting :tls_cert
              setting :tls_key
              setting(:tls_ca_certificates, []) { |value| Array(value) }
              setting :verify_peer, true
            end

            class << self
              attr_reader :connection_name

              def connection_settings
                config.to_h[:connection]
              end

              def inspect
                "<Aide::MQ::ConnectionConfiguration connection_name=#{connection_name}>"
              end
            end
          end
        end
      end
    end
  end
end
