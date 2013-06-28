require 'test_helper'

class BulletinSubscriberTest < ActiveSupport::TestCase
  should validate_presence_of :email

   context "given a new bulletin subscriber" do
     setup do
       @bulletin_subscriber = BulletinSubscriber.create(:first_name => 'Bulletin',
                                                        :last_name => 'Subscriber',
                                                        :organization_name => 'Unspace')
     end

      should "invalid email should not be saved" do
         @bulletin_subscriber.email = 'bad+email.net'
         assert !@bulletin_subscriber.save
         assert @bulletin_subscriber.errors.get(:email)
       end

       should "valid email should be saved" do
          @bulletin_subscriber.email = 'good@email.net'
          assert @bulletin_subscriber.save
       end
   end
end
