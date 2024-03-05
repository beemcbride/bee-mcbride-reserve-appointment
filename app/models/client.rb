class Client < ApiModel
    protected
  
    @required_fields = %w[id first_name last_name time_zone].freeze
    @filepath = "db/mock_db/clients.json"
  
    public
  
    attr_accessor :id, :display_name, :first_name, :last_name, :time_zone
  
    def initialize(id:, first_name:, last_name:, time_zone: nil)
      @id = id
      @first_name = first_name
      @last_name = last_name
      @time_zone = time_zone
  
      @display_name = "#{first_name} #{last_name}" # Jane Smith
    end
  
    # Really ought to be ActiveRecord.
    # Saves the <Client> object to the JSON database.
    def save
      Client.save_db_data(data: self)
    end
  end
  