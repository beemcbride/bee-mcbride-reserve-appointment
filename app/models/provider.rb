class Provider < ApiModel
  protected

  @required_fields = %w[id first_name last_name license time_zone licensed_states].freeze
  @filepath = "db/mock_db/providers.json"

  public

  attr_accessor :id, :display_name, :first_name, :last_name, :license, :time_zone, :licensed_states

  def initialize(id:, first_name:, last_name:, license:, time_zone:, licensed_states:)
    @id = id
    @first_name = first_name
    @last_name = last_name
    @license = license
    @time_zone = time_zone
    @licensed_states = licensed_states

    @display_name = "#{license} #{first_name.chars.first}. #{last_name}" # Dr. H. Jekyll
    # @date_time = date_time.is_a?(DateTime) ? date_time : DateTime.strptime(date_time, PURCHASE_DT_FORMAT)
  end

  def self.get_providers_in_time_zone(time_zone:)
    # should be ActiveRecord
    all_providers = Provider.get_from_totally_real_api
    all_providers.select { |p| p.time_zone == time_zone }
  end

  # Really ought to be ActiveRecord.
  # Saves the <Provider> object to the JSON database.
  def save
    Provider.save_db_data(data: self)
  end
end
