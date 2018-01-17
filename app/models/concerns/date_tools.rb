require 'date'
require 'holidays'

module DateTools

  def get_non_holiday_date date
    holidays = Holidays.on(date, :us)
    if holidays.size == 0
      date
    else
      get_non_holiday_date(date + 7.days);
    end
  end

  def get_date_for_day day_index
    Date.today.beginning_of_week(DaysOfWeek[day_index])
  end

  def is_day value
    DaysOfWeek.has_key? value.capitalize
  end

  DaysOfWeek = {
      0 => :sunday,
      1 => :monday,
      2 => :tuesday,
      3 => :wednesday,
      4 => :thursday,
      5 => :friday,
      6 => :saturday
  }

end
