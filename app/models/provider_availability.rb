require "active_support/time"

class ProviderAvailability < ApiModel
  DATETIME_FORMAT = "%Y-%m-%dT%H:%M".freeze
  private_constant :DATETIME_FORMAT

  protected

  @required_fields = %w[id provider_id start_date_time end_date_time].freeze
  @filepath = "db/mock_db/provider_availabilities.json"

  public

  attr_accessor :id, :provider_id, :start_date_time, :end_date_time

  def initialize(id:, provider_id:, start_date_time:, end_date_time:)
    @id = id
    @provider_id = provider_id
    @start_date_time = start_date_time.is_a?(DateTime) ? start_date_time : DateTime.strptime(start_date_time, DATETIME_FORMAT)
    @end_date_time = end_date_time.is_a?(DateTime) ? end_date_time : DateTime.strptime(end_date_time, DATETIME_FORMAT)
  end

  # we could filter this further to only in the state that is valid.
  # i think that is probably the better way/more realistic to how HM operates,
  # but timezone at least filters some. we can filter futher based on state if that is the deciding factor later
  def self.get_availability_for_time_zone(time_zone:)
    # should be ActiveRecord
    all_providers_in_time_zone = Provider.get_providers_in_time_zone(time_zone:)
    providers_in_time_zone_ids = all_providers_in_time_zone.map(&:id)
    all_availabilities_in_time_zone = ProviderAvailability.get_from_totally_real_api.select do |a|
      providers_in_time_zone_ids.include?(a.provider_id)
    end
  end

  # Really ought to be ActiveRecord.
  # Saves the <ProviderAvailability> object to the JSON database.
  def save
    ProviderAvailability.save_db_data(data: self)
  end
end
