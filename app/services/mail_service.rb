class MailService
  
  def initialize 
    Mail.defaults do
      retriever_method :pop3, 
      :address    => "pop-mail.outlook.com",
      :port       => 995,
      :user_name  => 'dedwardstest@outlook.com',
      :password   => 'C@mbr1dg3',
      :enable_ssl => true
    end
  end

  def retrieve_urls
    match_string = "http://otp-mta-demo"
    urls = []
    Mail.all.each do |message|
      if "OTP Test Harness Feedback".in? message.subject 
        puts message.body.ai
        
         # Iterate over every messaage part
        message.parts.each do |part|
          #Iterate over every string in the message
          part.body.decoded.split(' ').each do |str|
            puts "this is teh string #{str}"
            #Check to see if the str is a URL
            if str[0..(match_string.length - 1)] == match_string and not "</a>".in? str
              urls << str
            end
          end
        end

        #CGI::parse('param1=value1&param2=value2&param3=value3')
        #CGI::parse('http://www.google.com?param1=value1&param2=value2&param3=value3'.split('?').last)
      end # Check Subject
    end #Mail.all
    urls
  end #Retrieve

end #MailService