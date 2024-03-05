class ApiModel

  # Get all ApiModel objects from the API. 
  # == Returns:
  # [<ApiModel> object]
  def self.get_from_totally_real_api
    # ideally this data would be coming from a database and be connected auto-magically via ActiveRecord.
    # however, I didn't want to host a db and have that be hardcoded in this project. so we're going to use this
    # absolutely real API to get our data ;)
    db_data = get_db_data
    results = db_data.map { |obj| parse_to_model(obj:) }
    results
  end

  # Get JSON data representation of the data.
  # In the real world this would not be read from a JSON file, but from the DB itself a la ActiveRecord.
  # == Params:
  # filepath: string of the JSON file to read in. Stand-in for the db.
  # == Returns:
  # The parsed JSON data. Ex:
  # [
  #     {
  #       "id"=>1,
  #       "first_name"=>"John",
  #       "last_name"=>"Doe"
  #     },
  #     ...
  # ]
  def self.get_db_data
    JSON.parse(File.read(@filepath))
  end

  # Save the data to the appropriate DB
  # == Params:
  # data: <ApiModel> to save to the corresponding database
  def self.save_db_data(data:)
    # Only having to do this because I'm using JSON "db". If we were using ActiveRecord, this would not be a thing.
    curr_db = self.get_db_data
    curr_db << data
    File.write(@filepath, curr_db.to_json)
  end

  def self.remove_db_record(data:)
    # This would need to be fleshed out before production readiness. 
    # ActiveRecord would do this for us via destroy! but for now, this method just won't work :/
    raise NotImplementedError
  end

  # Parse JSON data representation of the data into the specific model.
  # == Params:
  # obj: a JSON object of an <ApiModel>
  # == Returns:
  # <ApiModel> object. ex: 
  # {
  #   "id"=>1,
  #   "first_name"=>"John",
  #   "last_name"=>"Doe"
  # }
  def self.parse_to_model(obj:)
    raise ArgumentError, "Call this method only with a single object, not an array." if obj.is_a? Array
    # It's okay if there are other fields in the object, but we don't care about them.
    attributes = @required_fields.each_with_object({}) do |field, attrs|
      value = obj[field]
      attrs[field.to_sym] = value if value.present?
    end
    self.new(**attributes)
  end

  class UnableToParseError < StandardError
    def initialize(field:, type:)
      super("Unable to parse field #{field} for #{type}.")
    end
  end
end
