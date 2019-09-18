Aws.config.update({ 
  region:      "us-east-1",
  credentials: Aws::Credentials.new('AKIAITSTWL6U3EYF3WUQ', 'JFH4BjzhjYqybAT4vnmdb1VUIcUXRXDBUsXOADZz')
})

Shoryuken.configure_client do |config|
  config.sqs_client = Aws::SQS::Client.new(
    region: 'us-east-1',
    access_key_id: 'AKIAITSTWL6U3EYF3WUQ',
    secret_access_key: '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',
    endpoint: 'https://sqs.us-east-1.amazonaws.com/347059689224/dev_archive',
    verify_checksums: false
  )
end