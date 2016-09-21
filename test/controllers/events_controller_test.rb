require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test 'should create event' do
    sign_in users(:one)
    post :create, { event: {name: 'Event 1'}.merge(date_to_array_hash(:start_date, Date.today)) }
    assert_response :success

    assert_equal 1, Event.count
  end

  test 'should create recurring event' do
    user = users(:one)
    sign_in user

    s = IceCube::Rule.weekly.day(:monday, :tuesday)
    start_date = Date.today
    post :create, { event: { schedule: s.to_json, name: 'Event 1'}.merge(date_to_array_hash(:start_date, start_date)) }
    assert_redirected_to events_path
    assert_equal 1, Event.count

    range = CustomCalendar.date_range_params(start_date + 40.days)
    event_index_service = EventIndexService.new(user, range)
    assert_equal (range[:from_date]..range[:to_date]).map(&:wday).select {|wday| wday == 1 || wday == 2}.count,
                 event_index_service.events.count
  end

  test 'should update all future recurring events' do
    user = users(:one)
    sign_in user
    start_date = Date.today + 3.days
    create_recurring_event(user, start_date)
    range = CustomCalendar.date_range_params(start_date + 20.days)
    event_index_service = EventIndexService.new(user, range)
    event = event_index_service.events[2]

    s = IceCube::Rule.weekly.day(:tuesday)
    put :update, {event: { schedule: s.to_json, event_date: event.start_date, virtual: true, update_type: 'all_future' }, id: event.id }
    assert_redirected_to events_path

    event_index_service.events[0..1].each{|d| assert_equal 1, d.start_date.wday }
    event_index_service.events[2..-1].each{|d| assert_equal 2, d.start_date.wday }
  end

  test 'should update single recurring event' do
    user = users(:one)
    sign_in user
    start_date = Date.today + 3.days
    create_recurring_event(user, start_date)
    range = CustomCalendar.date_range_params(start_date + 20.days)
    event_index_service = EventIndexService.new(user, range)
    event = event_index_service.events[2]

    new_date = event.start_date + 2.days
    put :update, {event: { start_date: new_date, name: event.name, event_date: event.start_date,
          virtual: true, update_type: 'single' }, id: event.id }
    assert_redirected_to events_path

    refute_equal event.start_date, event_index_service.events[2].start_date
    assert_equal 1, event_index_service.events.select{|e| e.start_date == new_date}.count
  end

  test 'should update none reccurring event' do
    user = users(:one)
    sign_in user
    start_date = Date.today + 3.days
    create_recurring_event(user, start_date)

    event = Event.first
    new_date = event.start_date + 2.days
    new_name = 'New name 1'
    put :update, {event: { start_date: new_date, name: new_name, virtual: false, update_type: 'single' }, id: event.id }
    assert_redirected_to events_path
    event.reload

    assert_equal  new_date, event.start_date
    assert_equal  new_name, event.name
  end


  def date_to_array_hash(key, date)
    { :"#{key}(1i)" => date.year, :"#{key}(2i)" => date.month, :"#{key}(3i)" => date.day }
  end

  def create_recurring_event(user, start_date)
    s = IceCube::Rule.weekly.day(:monday)
    post :create, { event: { schedule: s.to_json, name: 'Event 1'}.merge(date_to_array_hash(:start_date, start_date)) }
    assert_redirected_to events_path
  end
end
