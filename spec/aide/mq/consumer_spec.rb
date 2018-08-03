# frozen_string_literal: true

RSpec.describe Aide::MQ::Consumer do
  describe '#call' do
    let(:consume_q) { 'CONSUME_IT' }
    let(:respond_q) { 'RESPOND_HERE' }
    let(:payload) do
      Aide::MQ::Payload.new(data: { 'kwarg_1' => 3, 'kwarg_2' => 5 })
    end
    let(:consume_process) do
      lambda do |payload:, **|
        [payload.data['kwarg_1'] * 2,
         payload.data['kwarg_2'] * 2]
      end
    end

    let(:mq_client) do
      Aide::MQ::Client.new(name: '#new spec') do |c|
        c.connection.user = 'ConsumerSpec'
      end
    end

    let(:params) do
      { mq_client:       mq_client,
        consume_q:       consume_q,
        consume_process: consume_process,
        respond_q:       respond_q }
    end

    let(:model) { described_class.new(params) }

    context 'with :respond_q' do
      it 'submits consumption process result to queue' do
        model.subscribe! # subscribe to consume_q

        mq_client.publish(consume_q, payload)

        mq_client.queue(respond_q) do |q|
          delivery       = q.pop # [delivery_info, properties, body]
          parsed_payload = JSON.parse(delivery[:message])
          expect(parsed_payload).to eq [6, 10]
        end
      end
    end

    context 'without :respond_q' do
      let(:respond_q) { nil }

      it 'returns consumes without responding' do
        mq_client.publish(consume_q, payload)

        first_hit = false
        mq_client.queue(consume_q) do |q|
          expect(q.message_count).to eq 1
          first_hit = true
        end
        expect(first_hit).to eq true

        model.subscribe! # subscribe to consume_q

        second_hit = false
        mq_client.queue(consume_q) do |q|
          expect(q.message_count).to eq 0
          second_hit = true
        end
        expect(second_hit).to eq true
      end
    end
  end
end
