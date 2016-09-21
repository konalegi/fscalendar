class EventUpdateService
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_reader :current_user, :params, :base_event, :id
  attr_accessor :name, :virtual, :update_all_future, :update_type, :event_date

  def initialize(current_user, params)
    @id = params[:id]
    @params = params
    @current_user = current_user
    @base_event = current_user.events.find(id)
    @virtual = params[:virtual]
    @update_type = params[:update_type]
  end

  def update
    if virtual?
      update_virtual
    else
      update_persisted
    end
  end

  def update_virtual
    event_params = params.permit(:name, :start_date)
    ActiveRecord::Base.transaction do
      if update_single_event?
        event = Event.create!(event_params.merge(user_id: current_user.id))
        OccurrenceOverride.create!(event_id: event.id, overriden_date: event_date,
                                                 recurrence_period_id: base_event.recurrence_period(event_date).id)
      else
        if rule = schedule_rule
          base_event.recurrence_period(event_date).update(end_date: event_date - 1.day)
          base_event.recurrence_periods.create!(schedule: rule, start_date: event_date)
          base_event.update(event_params)
        end
      end
    end
  end

  def schedule_rule
    rule = params[:schedule]
    if RecurringSelect.is_valid_rule?(rule)
      s = IceCube::Schedule.new(start_date)
      s.add_recurrence_rule RecurringSelect.dirty_hash_to_rule(rule)
      s.add_exception_time(start_date)
      s
    end
  end

  def update_persisted
    base_event.update(params.permit(:name, :start_date))
  end

  def virtual?
    @virtual.to_b
  end

  def update_all_future?
    @update_all_future.to_b
  end

  def schedule
    @base_event.schedule(event_date).try(:rrules).try(:first)
  end

  def event_date
    SupportService.parse_date(params[:event_date])
  end

  alias_method :start_date, :event_date

  def persisted?; true; end

  def self.model_name
    self
  end

  def self.param_key
    'event'
  end

  def self.singular_route_key
    'event'
  end

  def _path
  end

  def self.i18n_key
    'asd'
  end

  def self.human
    'Event'
  end

  def name
    base_event.name
  end

  def update_future_events?
    @update_type == 'all_future'
  end

  def update_single_event?
    return true if @update_type.nil?
    @update_type == 'single'
  end

end