# frozen_string_literal: true

RSpec.describe Aide::MQ::Payload do
  let(:payload) do
    { data:    data,
      success: success,
      errors:  errors }
  end

  let(:model) { described_class.new payload }

  describe 'Attributes:' do
    let(:data)    { { cool: :runnings } }
    let(:success) { true }
    let(:errors)  { ['nah'] }

    it 'allows access by method' do
      expect(model.data   ).to eq data
      expect(model.success).to eq success
      expect(model.errors ).to eq errors
    end

    it 'allows access by #[]' do
      expect(model[:data]   ).to eq data
      expect(model[:success]).to eq success
      expect(model[:errors] ).to eq errors
    end
  end

  describe 'Methods:' do
    [true, false].each do |bool|
      context "When is#{' NOT' unless bool} success:" do
        let(:data)    { { cool: :runnings } }
        let(:errors)  { ['a couple'] }
        let(:success) { bool }

        it '#to_failure_h always fails' do
          expect(model.to_failure_h).to eq(
            data:    data,
            errors:  errors,
            success: false
          )
        end

        it '#to_success_h always succeeds' do
          expect(model.to_success_h).to eq(
            data:    data,
            errors:  errors,
            success: true
          )
        end
      end
    end

    let(:data)    { { cool: :runnings } }
    let(:success) { true }
    let(:errors)  { ['nah'] }

    it '#== is equal when hashes are equal' do
      expect(model == described_class.new(payload)).to eq true
      expect(model == described_class.new(data: { na: :ah })).to eq false
    end

    it '#eql? is equal when hashes are equal' do
      expect(model.eql?(described_class.new(payload))).to eq true
      expect(model.eql?(described_class.new(data: { na: :ah }))).to eq false
    end

    it '#[] treats model like a hash' do
      expect(model[:data]).to eq data
    end

    it '#to_json' do
      expect(model.to_json).to eq '{"data":{"cool":"runnings"},"success":true,"errors":["nah"]}'
    end
  end
end
