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
    match_subject = "OTP Test Harness Feedback"
    urls = []
    Mail.all.each do |message|
      if match_subject.in? message.subject 
        # Iterate over every messaage part
        message.parts.each do |part|
          #Iterate over every string in the message
          part.body.decoded.split(' ').each do |str|
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

  def create_trips
    
    # Get the the email group or create one
    group = Group.where(name: "Emailed Trips").first_or_create do |g|
      g.comment = "Trips created from emailed trips."
      g.save
    end

    urls = retrieve_urls.uniq 
    urls.each do |url|
      params = CGI::parse(url.split('?').last)

      # If all 4 params are present, make a trip
      if params["fromPlace"] and params["toPlace"] and params["date"] and params["time"]

        puts params.ai 

        origin =  params["fromPlace"].first 
        destination = params["toPlace"].first
        if params["arriveBy"] and params["arriveBy"].first == "true"
          arrive_by = true
        else
          arrive_by = false
        end

        Trip.where(
            group: group,
            origin: "ORIGIN",
            destination: "DESTINATION",
            origin_lat: origin.split(',').first,
            origin_lng: origin.split(',').last,
            destination_lat: destination.split(',').first,
            destination_lng: destination.split(',').last,
            arrive_by: arrive_by,
            time: Time.zone.strptime("#{params['date'].first} #{params['time'].first}", "%m/%d/%Y %k:%M") ).first_or_create!

      end

    end

  end


end #MailService