class Appointment < ApiModel
  DATETIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%N%z".freeze
  private_constant :DATETIME_FORMAT

  protected

  @required_fields = %w[id provider_id client_id appointment_date_time time_zone status last_updated_at].freeze
  @filepath = "db/mock_db/appointments.json"

  public

  attr_accessor :id, :provider_id, :client_id, :appointment_date_time, :time_zone, :status, :last_updated_at

  def initialize(id:, provider_id:, client_id:, appointment_date_time:, time_zone:, status: nil, last_updated_at:)
    @id = id
    @provider_id = provider_id
    @client_id = client_id
    @appointment_date_time = appointment_date_time.is_a?(DateTime) ? appointment_date_time : DateTime.parse(appointment_date_time)
    @time_zone = time_zone # we can parse this from the appointment date time
    @status = status
    @last_updated_at = last_updated_at.is_a?(DateTime) ? last_updated_at : DateTime.parse(last_updated_at)
  end

  def self.get_appointment(appointment_id:)
    # should be AR
    Appointment.get_from_totally_real_api.select { |appointment| appointment.id == appointment_id }.first # if there's more than one we have a DB problem.
  end

  # all appointment slots that are not confirmed, ordered by the appointment's date
  def self.get_all_available_appointments
    cutoff_time = (Time.now.utc + 24.hours).to_datetime
    # should be ActiveRecord
    Appointment.get_from_totally_real_api.select do |appointment|
      # confirmed should be a const here
      appointment.appointment_date_time > cutoff_time && a.status != "confirmed"
    end.sort_by { |appointment| appointment.appointment_start_date }
  end

  def self.get_all_booked_or_pending_upcoming_appointments
    current_time = Time.now.utc
    pending_cutoff_time = (current_time - 30.minutes).to_datetime
    cutoff_time_24 = (current_time + 24.hours).to_datetime
    # should be ActiveRecord
    Appointment.get_from_totally_real_api.select do |appointment|
      # only want the ones that are upcoming (future)
      # and only those that are booked or pending
      # (pending is derived as nil status and a last_updated_at time of less than 30 minutes ago)
      appointment.appointment_date_time > cutoff_time_24 &&
        # confirmed should be a const here
      (appointment.status == "confirmed" ||
       (appointment.status != "confirmed" && appointment.last_updated_at < pending_cutoff_time))
    end
  end

  def confirm
    # ought to be AR. this causes some odd ordering bugs in the data. 
    self.status = "confirmed"
    self.last_updated_at = Time.now.utc.to_datetime
    self.save
  end

  # Really ought to be ActiveRecord.
  # Saves the <Appointment> object to the JSON database.
  def save
    Appointment.save_db_data(data: self)
  end
end
