require 'minitest/autorun'

class SalesforceRecordTest < ActiveSupport::TestCase
  should validate_presence_of(:record_id)
  should validate_length_of(:record_id).is_at_most(18).is_at_least(15)
  should validate_uniqueness_of(:record_id)

  describe 'salesforce record id component helpers' do
    let(:salesforce_record) { build(:salesforce_record) }

    it :record_id do
      build(:salesforce_record).must_be :valid?
    end
  end

  describe 'salesforce record id component helpers' do
    let(:salesforce_record) { build(:salesforce_record, record_id: "00DX00000000001MVK") }

    it :record_id do
      salesforce_record.must_be :valid?
    end

    it :record_prefix do
      salesforce_record.record_prefix.must_equal '00D'
    end

    it :server_id do
      salesforce_record.server_id.must_equal 'X0'
    end

    it :identifier do
      salesforce_record.identifier.must_equal '0000000001MVK'
    end
  end
end
