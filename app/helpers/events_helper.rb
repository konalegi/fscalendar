module EventsHelper
  def able_to_edit_event?(event)
    event.user_id == current_user.id
  end
end
