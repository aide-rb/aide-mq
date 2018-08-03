# frozen_string_literal: true

RSpec.describe Aide::MQ::Client do
  let(:name)    { 'queue.test' }
  let(:message) { { 'test_key' => 'test_value' } }

  describe '#new' do
    it 'uses given connection' do
      connection = Aide::MQ::Connection.new(name: '#new spec') do |c|
        c.connection.user = 'Flitwick'
      end

      model = described_class.new(name: '#new spec', connection: connection)
      expect(model.connection).to eq connection
    end

    it 'uses block for new connection' do
      model = described_class.new(name: '#new spec') do |c|
        c.connection.user = 'Burbage'
      end
      expect(model.connection).not_to be_nil
    end
  end

  it '#queue yields a queue to a block' do
    model = described_class.new(name: '#queue spec') { |c| c.mock = true }

    hit = false
    model.queue(name) do |q|
      hit = true
      expect(q).to be_a BunnyMock::Queue
      expect(q.message_count).to eq 0
      expect(q.name).to eq name
    end
    expect(hit).to eq true
  end

  it '#publish, #subscribe' do
    model = described_class.new(name: '#publish,subscribe spec') do |c|
      c.mock = true
    end

    model.publish(name, message)

    q_is_hit = false
    model.queue(name) do |q|
      q_is_hit = true
      expect(q.message_count).to eq 1
    end
    expect(q_is_hit).to eq true

    subscribe_is_run = false
    model.subscribe(name) do |info, properties, message|
      subscribe_is_run = true
      expect(info           ).to be_a BunnyMock::GetResponse
      expect(info.to_h      ).to include routing_key:  'queue.test'
      expect(properties     ).to be_a BunnyMock::MessageProperties
      expect(properties.to_h).to eq({})

      expect(message).to eq message
    end
    model.publish(name, message)

    expect(subscribe_is_run).to eq true
  end
end
