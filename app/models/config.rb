class Config < ApplicationRecord

  serialize :value

  validates :key, presence: true, uniqueness: true
  
  # Returns the value of a setting when you say Config.<key>
  def self.method_missing(key, *args, &blk)
    # If the method ends in '=', set the config variable
    return set_config_variable(key.to_s.sub("=", ""), *args) if key.to_s.last == "="
    
    config = Config.find_by(key: key)
    return config.value unless config.nil?
    return Rails.application.config.send(key) if Rails.application.config.respond_to?(key)
    return nil
  end
  
  # Sets a config variable if possible
  def self.set_config_variable(key, *args)
    return false if Rails.application.config.respond_to?(key)
    return Config.find_or_create_by(key: key).update_attributes(value: args.first)
  end


  ### ATIS MAPPING ##########################
  def self.update_atis_otp_mapping file
    require 'open-uri'
    require 'csv'
    mapping_file = open(file)
    mapping = {}
    CSV.foreach(mapping_file, {:col_sep => ",", :headers => true}) do |row|
      mapping[row[0].to_sym] = {gtfs_id: row[1], gtfs_short_name: row[2], gtfs_long_name: row[3]}
    end
    self.set_config_variable("atis_otp_mapping", mapping)
    return
  end 
  ### END ATIS MAPPING ######################
  
end
