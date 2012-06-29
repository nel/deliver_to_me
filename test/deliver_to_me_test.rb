# encoding: utf-8
require File.join(File.dirname(__FILE__),'/test_helpers')

class DeliverToMeTest < Test::Unit::TestCase
  def setup
     ActionMailer::Base.delivery_method = :test
     ActionMailer::Base.deliveries = []
     ActionMailer::Base.my_settings = {}
     
     @expected = mail_fixture
   end
  
  def teardown
    ActionMailer::Base.delivery_method = :test
  end
  
  # Replace this with your real tests.
  def test_should_get_expected_mail
    created = nil
    assert_nothing_raised do
      assert created = MyTestDelivery.deliver_love_letter
    end

    assert_not_nil ActionMailer::Base.deliveries.first
    assert_equal @expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end
  
  def test_should_have_default_options
    
  end
  
  def test_should_rewrite_recipients
    ActionMailer::Base.my_settings = {
      :recipients => 'postmaster@localhost',
      :delivery_method => :test,
      :real_recipients_in_body => false
    }
    
    ActionMailer::Base.delivery_method = :my
    
    assert MyTestDelivery.deliver_love_letter
    assert_equal ['postmaster@localhost'], ActionMailer::Base.deliveries.first.destinations
  end
  
  def test_should_support_multiple_recipients
    ActionMailer::Base.delivery_method = :my
    ActionMailer::Base.my_settings = {
      :recipients => ['"Foo é"<bar@joo.fr>', "rails@toto.com"],
      :delivery_method => :test,
      :real_recipients_in_body => false
    }
    assert MyTestDelivery.deliver_love_letter
    assert_equal %W(bar@joo.fr rails@toto.com), ActionMailer::Base.deliveries.first.destinations
  end
  
  def test_should_support_rewrited_body
    ActionMailer::Base.my_settings = {
      :recipients => 'postmaster@localhost',
      :delivery_method => :test,
      :real_recipients_in_body => true
    }
    ActionMailer::Base.delivery_method = :my
    
    assert MyTestDelivery.deliver_love_letter
    @expected.to = 'postmaster@localhost'
    @expected.cc = nil
    @expected.bcc = nil
    @expected.body=  @expected.body << "\nto 1:\nJsus <listener@externaldrain.org>\ncc 1:\nmydog@externalrain.org\nbcc 1:\nyourdog@externalslain.org\n"
    assert_equal @expected.encoded, ActionMailer::Base.deliveries.first.encoded
  end
  
  def test_should_perform_smtp_delivery   
    ActionMailer::Base.my_settings = {
      :recipients => 'postmaster@localhost',
      :delivery_method => :smtp,
      :real_recipients_in_body => true
    }
    ActionMailer::Base.delivery_method = :my
    
    MyTestDelivery.any_instance.expects(:perform_delivery_smtp)
    MyTestDelivery.deliver_love_letter
  end
  
  def test_should_perform_sendmail_delivery   
    ActionMailer::Base.my_settings = {
      :recipients => 'postmaster@localhost',
      :delivery_method => :sendmail,
      :real_recipients_in_body => true
    }
    ActionMailer::Base.delivery_method = :my
    
    MyTestDelivery.any_instance.expects(:perform_delivery_sendmail)
    MyTestDelivery.deliver_love_letter
  end

  private
    def mail_fixture
      expected = new_mail
      expected.to      = '"Jsus"<listener@externaldrain.org>'
      expected.cc      = 'mydog@externalrain.org'
      expected.bcc     = 'yourdog@externalslain.org'
      expected.subject = '=?utf-8?Q?Blop_=C3=A9_=C3=A7?='
      expected.body    = "externalbrain is da host, café çélà, hail to Rick Olson, Ezra, Nick, Jamis and so much more"
      expected.from    = '"Renaud (nel) Morvan"<nel@externaltrain.org>'
      expected.date    = Time.local 2004, 12, 12
      expected
    end
    
    def new_mail( charset="utf-8" )
      mail = TMail::Mail.new
      mail.mime_version = "1.0"
      if charset
        mail.set_content_type "text", "plain", { "charset" => charset }
      end
      mail
    end
end
