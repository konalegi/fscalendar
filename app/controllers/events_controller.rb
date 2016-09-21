class EventsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_my_event, only: [:destroy]
  before_action :set_event, only: [:show]

  # GET /events
  # GET /events.json
  def index
    event_service = EventIndexService.new(current_user, params)
    @events = event_service.events
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = EventCreateService.new(current_user, params)
  end

  # GET /events/1/edit

  # POST /events
  # POST /events.json
  def create
    @event = EventCreateService.new(current_user, params)

    if @event.save
      redirect_to events_path, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  def edit
    @event = EventUpdateService.new(current_user, params)
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @event = EventUpdateService.new(current_user, params[:event].merge(id: params[:id]))
    if @event.update
      redirect_to events_path, notice: 'Event was successfully updated.'
    else
      render :edit
    end
    # if @event.update(event_params)
    #
    # else
    #
    # end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    def set_my_event
      @event = current_user.events.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :start_date, :recurrence_period_attributes => [:schedule])
    end
end
