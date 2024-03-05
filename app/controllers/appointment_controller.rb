class AppointmentController < ActionController::API
  def index
    all_appointments = Appointment.get_from_totally_real_api
    render json: all_appointments
  end

  def create
    # Assuming params[:appointment] contains the nested data for an appointment.
    # we should validate all data is in the format we expect, not just shove it through
    # I didn't want to fully implement ActiveRecord, because that felt dramatically out of scope for this project,
    # but I would opt to use its validation functionality rather than building it out myself and reinventing the wheel
    appointment_params = params.require(:appointment).permit(:provider_id, :client_id, :appointment_date_time, :time_zone)

    # Before moving to production this would be heavily validated, 
    # including making sure the appointment time is still valid
    # This endpoint would ideally be used in conjunction with the index/list of available
    # appointment times, which only displays the valid appointment times
    new_appointment = Appointment.new(id: SecureRandom.uuid, # would be taken care of by AR.
                                      provider_id: appointment_params[:provider_id],
                                      client_id: appointment_params[:client_id],
                                      appointment_date_time: appointment_params[:appointment_date_time],
                                      time_zone: appointment_params[:time_zone],
                                      last_updated_at: Time.now.utc.to_datetime) # would be taken care of by AR.

    if new_appointment.save
      render json: { status: "success", message: "Appointment created successfully" }, status: :ok
    else
      # future proofing. json db doesn't have this error functionality yet.
      render json: { status: "error", message: "Appointment creation failed", errors: new_appointment.errors }, status: :unprocessable_entity
    end
  end

  def confirm
    appointment_id = params.require(:appointment_id)
    appointment = Appointment.get_appointment(appointment_id: appointment_id.to_i) # again, we should validate via AR.
    if (appointment.present?)
      appointment.confirm
      render json: appointment, status: :ok
    else
      render json: { status: "failure", message: "Appointment not found" }, status: :not_found
    end
  end
end
