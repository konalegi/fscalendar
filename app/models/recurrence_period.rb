class RecurrencePeriod < ActiveRecord::Base
  include IceCube
  serialize :schedule, IceCube::Schedule
  belongs_to :event
  has_many :occurrence_overrides

  validates :start_date, presence: true

  scope :between_dates, -> (date) { where('(start_date >= ?) AND (end_date <= ?)', date, date) }


  def has_recurring_events?(from_date, to_date)
    schedule.occurs_between?(from_date, to_date)
  end

  def generate_events(from_date, to_date)
    return [] if schedule.nil?
    return [] unless has_recurring_events?(from_date, to_date)
    occurrence_overrides.each{ |oo| schedule.add_exception_time(oo.overriden_date) }
    to_date = if end_date.nil?
      to_date
    elsif to_date > end_date
      end_date
    else
      to_date
    end

    schedule.occurrences_between(from_date, to_date).map do |event_date|
      Event.new(start_date: event_date, name: event.name, id: event.id, virtual: true, user_id: event.user_id)
    end
  end

end
