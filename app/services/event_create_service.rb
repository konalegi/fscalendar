class EventCreateService
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_reader :params, :name, :start_date, :schedule, :current_user

  validates :start_date, :name, presence: true

  def initialize(current_user, params)
    @current_user = current_user
    @params = params
  end

  def save
    return false if invalid?
    ActiveRecord::Base.transaction do

      event = Event.create!(event_params.merge({user_id: current_user.id}))
      if rule = schedule_rule
        event.recurrence_periods.create!(schedule: rule, start_date: start_date)
      end
    end
  end

  def event_params
    return {} unless params.has_key?(:event)
    params.require(:event).permit(:name, :start_date)
  end

  def schedule_rule
    rule = params[:event][:schedule]
    if RecurringSelect.is_valid_rule?(rule)
      s = IceCube::Schedule.new(start_date)
      s.add_recurrence_rule RecurringSelect.dirty_hash_to_rule(rule)
      s
    end
  end

  def virtual
    false
  end

  def event_date
    Date.today
  end

  def start_date
    Date.new(*%w(1 2 3).map { |e| event_params["start_date(#{e}i)"].to_i }) rescue nil
  end

  def name; event_params[:name]; end

  def persisted?; false; end
  def self.route_key; 'events'; end
  def self.model_name; self; end
  def self.param_key; 'event'; end
  def self.singular_route_key; 'event'; end
  def _path; end
  def self.i18n_key; 'asd'; end
  def self.human; 'Event'; end
end