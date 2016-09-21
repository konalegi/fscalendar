class Event < ActiveRecord::Base
  attr_writer :virtual
  belongs_to :user
  has_many :recurrence_periods, class_name: 'RecurrencePeriod'

  validates :user, :start_date, :name, presence: true
  validate :date_should_be_greater_than_today

  scope :from_date, -> (date) { where('events.start_date >= ?', date) }
  scope :to_date, -> (date) { where('events.start_date <= ?', date) }

  def start_time; start_date; end

  def date_should_be_greater_than_today
    return if start_date.nil?
    errors.add(:start_date, :you_cannot_create_event_in_past) if (start_date < Date.today)
  end

  def virtual
    @virtual || false
  end

  alias_method :virtual?, :virtual

  def event_date; nil; end

  def recurrence_period(for_date)
    period = recurrence_periods.between_dates(for_date).take
    return period if period.present?
    recurrence_periods.where('end_date IS NULL').take
  end

  def schedule(for_date)
    return nil if recurrence_period(for_date).nil?
    recurrence_period(for_date).schedule
  end

end
