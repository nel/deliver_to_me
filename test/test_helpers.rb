require 'test/unit'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'action_mailer'
require 'mocha'
require 'deliver_to_me.rb'
ActionMailer::Base.send :include, DeliverToMe

ActionMailer::Base.my_settings = {
    :recipients => 'postmaster@localhost',
    :delivery_method => :test,
    :real_recipients_in_body => true
}

class MyTestDelivery < ActionMailer::Base
  def love_letter
    from '"Renaud (nel) Morvan"<nel@externaltrain.org>'
    recipients '"Jésus"<listener@externaldrain.org>'
    cc 'mydog@externalrain.org'
    bcc 'yourdog@externalslain.org'
    sent_on Time.local(2004, 12, 12)
    subject 'Blop é ç'
    body "externalbrain is da host, café çélà, hail to Rick Olson, Ezra, Nick, Jamis and so much more"
  end
end