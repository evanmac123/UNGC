require 'minitest/autorun'

class OrganizationSocialNetworkTest < ActiveSupport::TestCase
  describe 'uniqueness' do
    describe 'organization scope' do
      let(:network_code) { 'twitter' }
      let(:handle) { 'tweeter' }
      let(:social_organization) do
        org = create(:organization)
        org.social_network_handles << create(:organization_social_network,
                                             network_code: network_code,
                                             handle: handle)
        org
      end


      describe 'handles' do
        subject do
          social_organization
          duplicate_handle = build(:organization_social_network,
                                    network_code: network_code,
                                    handle: handle)
          duplicate_handle.valid?
          duplicate_handle
        end

        it 'disallows duplicate handle for the same social network' do
          subject.errors[:handle].must_equal ["is already used by another organization"]
        end
      end

      describe 'for organization' do
        subject do
          duplicate_social = build(:organization_social_network,
                                   organization: social_organization,
                                   network_code: network_code,
                                   handle: 'another_handle')
          duplicate_social.valid?
          duplicate_social
        end

        it 'disallows duplicate social networks for the same organization' do
          subject.errors[:organization].must_equal ["already has an account for the Social Network"]
        end
      end
    end
  end

end
