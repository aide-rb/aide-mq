# frozen_string_literal: true

module Aide
  module MQ
    # Consumes a RabbitMQ message and responds
    #
    class Consumer
      attr_reader :mq_client,
                  :consume_q,
                  :consume_process,
                  :respond_q
      def initialize(mq_client:,
                     consume_q:,
                     consume_process:,
                     respond_q: nil)
        @mq_client       = mq_client
        @consume_q       = consume_q
        @consume_process = consume_process
        @respond_q       = respond_q
      end

      def subscribe!
        mq_client.subscribe(consume_q) do |delivery_info, properties, payload|
          result = consume_process.(delivery_info: delivery_info,
                                    properties:    properties,
                                    payload:       payload)
          mq_client.publish(respond_q, result) unless respond_q.nil?
        end
      end
    end
  end
end
