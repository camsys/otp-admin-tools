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
    match_approve = "Approve"
    match_disapprove = "Disapprove"
    urls = []
    status = nil
    Mail.all.each do |message|
      if match_subject.in? message.subject 
        # Iterate over every messaage part
        message.parts.each do |part|
          #Iterate over every string in the message
          part.body.decoded.split(' ').each do |str|
            if str == match_approve
              status = "approve"
            end
            if str == match_disapprove
              status = "disapprove"
            end
            if str[0..(match_string.length - 1)] == match_string and not "</a>".in? str
              urls << {"status" => status, "url" => str}
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
    approved_group = Group.where(name: "Emailed Approved Trips").first_or_create do |g|
      g.comment = "Approved Trips created from emailed trips."
      g.save
    end

    disapproved_group = Group.where(name: "Emailed Disapproved Trips").first_or_create do |g|
      g.comment = "Disapproved Trips created from emailed trips."
      g.save
    end

    urls = retrieve_urls.uniq
    urls.each do |url_hash|

      url = url_hash['url']
      status = url_hash['status']

      params = CGI::parse(url.split('?').last)
      if status == "approve"
        group = approved_group
      else
        group = disapproved_group
      end
      # If all 4 params are present, make a trip
      if not params["fromPlace"].blank? and not params["toPlace"].blank? and not params["date"].blank? and not params["time"].blank?

        puts params.ai

        begin
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
        rescue Exception => e
          puts "Error processing Trip"
        end

      end

    end

  end


end #MailService