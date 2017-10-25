class Group < ApplicationRecord

  has_many :trips

  #### METHODS ####
  # Load new Trips from CSV
  def update_trips file
    require 'open-uri'
    require 'csv'
    trips_file = open(file)

    # Iterate through CSV.
    failed = false
    message = ""
    self.trips.delete_all
    line = 2 #Line 1 is the header, start with line 2 in the count
    begin
      CSV.foreach(trips_file, {:col_sep => ",", :headers => true}) do |row|

        begin
          #If we have already created this Landmark, don't create it again.
          Trip.create!({
            origin: row[0],
            destination: row[1],
            time: "#{row[2]} #{row[3]}",
            arrive_by: row[4],
            group: self
          })
        rescue
          #Found an error, back out all changes and restore previous POIs
          message = 'Error found on line: ' + line.to_s
          Rails.logger.info message
          self.trips.delete_all
          failed = true
          break
        end
        line += 1
      end
    rescue
      failed = true
      message = 'Error Reading File'
      Rails.logger.info message
      self.trips.delete_all
      failed = true
    end

    if failed
      return false, message
    else
      return true, self.trips.count.to_s + " trips loaded"
    end

  end #Update
end
