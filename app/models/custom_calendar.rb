class CustomCalendar < SimpleCalendar::Calendar
  def date_range
    (start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week).to_a
  end

  def url_for_next_view
    new_start_date = date_range.last + 1.day
    view_context.url_for(@params.merge(self.class.date_range_params(new_start_date)))
  end

  def url_for_previous_view
    new_start_date =date_range.first - 1.day
    view_context.url_for(@params.merge(self.class.date_range_params(new_start_date)))
  end

  def self.date_range_params(new_start_date)
    {
      start_date: new_start_date,
      from_date: new_start_date.beginning_of_month.beginning_of_week,
        to_date: new_start_date.end_of_month.end_of_week
    }
  end
end