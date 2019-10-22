# Start consuming the SQS queue using Shoryuken
# -v Verbose option for showing debug output
# bundle exec shoryuken -q dev_archive --rails -C config/shoryuken.yml -r ./app/jobs -v
class OTPDataLoaderWorker
  include Shoryuken::Worker

  # queue: This option should match the queue name in AWS. The queue should already be created using the AWS console.
  # auto_delete: The message is deleted from the queue after it is received, but only if the worker doesn't raise any exception 
  #              during the consumption. AWS doesn't automatically delete the message.
  # body_parser: The received message is parsed as JSON.
  # Shoryuken tries to grab 10 messages at time (max allowed by SQS), but it calls a worker per message, unless you enable batch.
  shoryuken_options queue: ENV['SQS_QUEUE'], auto_delete: true, body_parser: :json
  # batch: true

  # When batch is enabled, the sqs_msg and body arguments are arrays.
  def perform(sqs_msg, body)    
    Shoryuken.logger.debug("Received message: #{body}")

    # Sample format of OTP message:
    # {"type_id"=>1, "from_place"=>"40.754910,-73.994102", "from_lat"=>40.75491, "from_lon"=>-73.994102, 
    #  "to_place"=>"40.754006,-73.988301", "to_lat"=>40.754006, "to_lon"=>-73.988301, 
    #  "request_time"=>1551123863000, "server_time"=>1551123863828, "arrive_by"=>false}
    Shoryuken.logger.debug( "type_id: #{body['type_id']}" )
    Shoryuken.logger.debug( "from_place: #{body['from_place']}" )
    Shoryuken.logger.debug( "from_lat: #{body['from_lat']}" )
    Shoryuken.logger.debug( "from_lon: #{body['from_lon']}" )
    Shoryuken.logger.debug( "to_place: #{body['to_place']}" )
    Shoryuken.logger.debug( "to_lat: #{body['to_lat']}" )
    Shoryuken.logger.debug( "to_lon: #{body['to_lon']}" )
    Shoryuken.logger.debug( "request_time: #{body['request_time']}" )
    Shoryuken.logger.debug( "server_time: #{body['server_time']}" )
    Shoryuken.logger.debug( "arrive_by: #{body['arrive_by']}" )

    # OTP passes times formatted as Unix epoch time in milliseconds e.g. 1551123863000.
    # This needs to be converted to Ruby datetime.
    request_datetime = Time.at(body['request_time'] / 1000.0);
    server_datetime = Time.at(body['server_time'] / 1000.0);

    Shoryuken.logger.debug( "Converted request_time: #{request_datetime}" )
    Shoryuken.logger.debug( "Converted server_time: #{server_datetime}" )

    if (body['from_lat'] == 0.0 || body['from_lon'] == 0.0 || body['to_lat'] == 0.0 || body['to_lon'] == 0.0) then
      Shoryuken.logger.debug("Ignored message from monitoring service. Has zero lat/long.")
    else
      Shoryuken.logger.debug("Saving message as plan.")
    	plan = Plan.new
    	plan.type_id = body['type_id']
    	plan.from_lat = body['from_lat']
    	plan.from_lng = body['from_lon']
    	plan.to_lat = body['to_lat']
    	plan.to_lng = body['to_lon']
    	plan.request_time = request_datetime
    	plan.server_time = server_datetime
    	plan.arrive_by = body['arrive_by']
    	plan.save

      # Save plan locations later with update_plan_locations rake task.
    end
  end
end