class ProviderAvailabilityController < ActionController::API
    DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S%z".freeze
    private_constant :DATETIME_FORMAT

  def index
    render json: available_provider_availabilities
  end

  def available_provider_availabilities
    all_provider_availabilities = ProviderAvailability.get_from_totally_real_api
    all_booked_or_pending_appointment_times = Appointment.get_all_booked_or_pending_upcoming_appointments.map(&:appointment_date_time)
    # remove the times that are booked or pending
    viable_provider_availabilities = all_provider_availabilities.reject do |provider_availability|
      all_booked_or_pending_appointment_times.include?(provider_availability.start_date_time)
    end.sort_by do |provider_availability|
      provider_availability.start_date_time
    end
  end

  def create
    # Assuming params[:provider_availability] contains the nested data for a provider_availability.
    # we should validate all data is in the format we expect, not just shove it through
    # I didn't want to fully implement ActiveRecord, because that felt dramatically out of scope for this project,
    # but I would opt to use its validation functionality rather than building it out myself and reinventing the wheel
    provider_availability_params = params.require(:provider_availability).permit(:provider_id, :start_date_time, :end_date_time)

    # We accept a large time slot (such as 8 AM to 4 PM) from a provider, 
    # and then convert it into 15 minute increments for storage internally.
    available_time_slots = ProviderAvailabilityController.convert_availability_to_time_slots(
      start_date_time: provider_availability_params[:start_date_time],
      end_date_time: provider_availability_params[:end_date_time],
    )

    # need some way, like a transaction, to wrap all of these to render a full pass/fail
    # for now, hardcode it 
    successful_saves = []
    errors = []
    available_time_slots.keys.each do |start_time|
      new_provider_availability = ProviderAvailability.new(
        id: SecureRandom.uuid, # would be taken care of by AR.
        provider_id: provider_availability_params[:provider_id],
        start_date_time: start_time,
        end_date_time: available_time_slots[start_time],
      )

      if new_provider_availability.save
        successful_saves << new_provider_availability
      else 
        errors << new_provider_availability.errors
      end
    end

    if errors.empty?
        render json: { status: "success", message: "Provider Availability created successfully" }, status: :ok
      else
        # future proofing. json db doesn't have this error functionality yet.
        render json: { status: "error", message: "Provider Availability creation failed", errors: errors.first }, status: :unprocessable_entity
      end
  end

  # could parameterize the time slot length here
  def self.convert_availability_to_time_slots(start_date_time:, end_date_time:)
    time_slots = {}
    start_time = Time.zone.parse(start_date_time)
    end_time = Time.zone.parse(end_date_time)
    # Loop through the time range in 15-minute increments
    while start_time < end_time
      # Convert the current time slot to format we expect
      current_time = start_time.strftime(DATETIME_FORMAT)
      # Get our end time (hardcoded here to be 15 minutes, but could be passed in)
      current_end_time = start_time + 15.minutes
      # Now save the time slot as a map of start time -> end time
      time_slots[current_time] = current_end_time.strftime(DATETIME_FORMAT)

      # continue the loop
      start_time = current_end_time
    end
    time_slots
  end

  def remove_availability(provider_id:, provider_availability_id:)
    # would call ProviderAvailability.remove_db_record but that's a future change for sake of time
  end
end
