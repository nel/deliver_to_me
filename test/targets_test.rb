require File.join(File.dirname(__FILE__),'/test_helpers')

module Targets
  module MyTargetMock
    class << self
      def get
        ['this@wor.ks','so@we.ll']
      end
    end
  end
end

class DeliverToMeTargetsTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.delivery_method = :my
    ActionMailer::Base.my_settings = {
      :recipients => :my_target_mock,
      :delivery_method => :test
    }
  end
  
  def test_should_use_target_mock
    assert MyTestDelivery.deliver_love_letter
    assert_equal ["this@wor.ks", "so@we.ll"], ActionMailer::Base.deliveries.first.destinations
  end
end