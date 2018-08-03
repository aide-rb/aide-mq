# frozen_string_literal: true

module Aide
  module MQ
    #
    # Value class for message queue payloads
    class Payload
      attr_reader :data, :success, :errors

      # @param [Hash] input string or symbol keys
      # @option input [Hash]    :data ({})
      # @option input [Boolean] :success (false)
      # @option input [Array]   :errors ([])
      def initialize(input)
        sym_or_str = lambda do |sym, default|
          val = input[sym].nil? ? input[sym.to_s] : input[sym]
          val.nil? ? default : val
        end
        @data    = sym_or_str.(:data,    {})
        @success = sym_or_str.(:success, false)
        @errors  = sym_or_str.(:errors,  [])
      end

      def failure?
        !success
      end

      def success?
        success
      end

      def ==(other)
        to_h == other.to_h
      end
      alias_method :eql?, :==

      def [](key)
        to_h[key]
      end

      def to_h
        { data:    data,
          success: success,
          errors:  errors }
      end
      alias_method :===, :to_h

      def to_failure_h
        to_h.merge success: false
      end

      def to_success_h
        to_h.merge success: true
      end

      def to_json
        to_h.to_json
      end
      alias_method :to_s, :to_json
    end
  end
end
