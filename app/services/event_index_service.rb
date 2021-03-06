class EventIndexService
  attr_reader :current_user, :params

  def initialize(current_user, params)
    @params = params
    @current_user = current_user
  end

  def events
    singular_events + recurrent_events
  end

  def from_date
    SupportService.parse_date(params[:from_date] || range[:from_date])
  end

  def to_date
    SupportService.parse_date(params[:to_date] || range[:to_date])
  end

  def range
    CustomCalendar.date_range_params(Date.today)
  end

  def see_all?
    params[:see_all] || false
  end

  def singular_events
    events = Event.all
    events = events.where(user_id: current_user.id) unless see_all?
    events.includes(:recurrence_periods).where(recurrence_periods: { id: nil }).from_date(from_date).to_date(to_date).to_a
  end

  def recurrent_events
    recurrence_periods = RecurrencePeriod.joins(:event)
    recurrence_periods = recurrence_periods.where(events: {user_id: current_user.id}) unless see_all?
    recurrence_periods = recurrence_periods.where('events.start_date < ?', to_date).
                                            where('(end_date >= ?) OR (end_date IS NULL)', from_date).to_a
    recurrence_periods.map{ |rp| rp.generate_events(from_date, to_date) }.flatten
  end

end