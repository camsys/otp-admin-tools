Aws.config.update({ 
  region:      ENV['AWS_SQS_REGION'],
  credentials: Aws::Credentials.new(ENV['SQS_AWS_ACCESS_KEY'], ENV['SQS_AWS_SECRET_KEY'])
})

Shoryuken.configure_server do |config|
  Shoryuken.add_group('default', 1)
  Shoryuken.add_queue(ENV['SQS_QUEUE'], 1, 'default')
end

Shoryuken.configure_client do |config|
  config.sqs_client = Aws::SQS::Client.new(
    region: ENV['AWS_SQS_REGION'],
    access_key_id: ENV['SQS_AWS_ACCESS_KEY'],
    secret_access_key: ENV['SQS_AWS_SECRET_KEY'],
    endpoint: ENV['SQS_ENDPOINT'],
    log_level: :info,
    verify_checksums: false
  )
end