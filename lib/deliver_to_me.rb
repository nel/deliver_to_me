module DeliverToMe    
  def self.included(base)
    base.class_eval do
      @@my_settings = {
        :recipients => 'postmaster@localhost',
        :delivery_method => :test,
        :real_recipients_in_body => true
      }
      cattr_accessor :my_settings
    end
  end

  def perform_delivery_my(mail)
    my_alter_email_body!(mail, my_recipients_presenter(my_parse_recipients(mail))) if @@my_settings[:real_recipients_in_body]
    my_override_destinations!(mail)

    begin
      __send__("perform_delivery_#{self.class.my_settings[:delivery_method]}", mail)
    rescue Exception => e  # Net::SMTP errors or sendmail pipe errors
      raise e if raise_delivery_errors
    end
  end
  
  private
    # force delivered email to be send to my recipients
    def my_override_destinations!(mail)
      mail.bcc = nil
      mail.cc = nil
      mail.to = my_recipients
      mail
    end
  
    # convert my recipients if they are dynamic (using targets)
    def my_recipients
      @my_recipients ||= if @@my_settings[:recipients].is_a? Symbol
        "Targets::#{@@my_settings[:recipients].to_s.camelize}".constantize.get
      else
        @@my_settings[:recipients]
      end
    end
  
    # alter email body, should not work with multipart email
    def my_alter_email_body!(mail, string)
      return my_alter_multipart_email!(mail, string) if mail.multipart?
      
      current_body = mail.body
      mail.body = current_body + "\n#{string}"
    end

    def my_alter_multipart_email!(mail, string)
      current_body = "###############   Multipart email   ###############\n"
      mail.parts.each do |part|
        current_body << "###############  -#{part.content_type}   ###############\n"
        current_body << part.body
        current_body << "\n\n"
      end
      current_body << "\n###############\n"

      mail.content_type = 'text/plain'
      mail['Content-Type'] = 'text/plain'
      mail.parts.delete_if{true}

      mail.body = current_body + "\n#{string}"
    end

    # take a hash of recipients array and return a string
    def my_recipients_presenter(recipients_hash)
      %W(to cc bcc).inject('') do |ret, header|
        ret << "#{header} #{recipients_hash[header].size}:\n#{recipients_hash[header].join("\n")}\n"
      end
    end
  
    # return a hash of formatted email array
    def my_parse_recipients(mail)
      %W(to cc bcc).inject({}) do |acc, header|
        acc[header] = mail.header_string(header, []).collect {|address| address.to_s}
        acc
      end
    end
end
