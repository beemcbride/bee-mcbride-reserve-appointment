class ClientController < ActionController::API
    def index
      all_clients = Client.get_from_totally_real_api
      render json: all_clients
    end
  
    def create
      # Assuming params[:client] contains the nested data for a client.
      # we should validate all data is in the format we expect, not just shove it through
      # I didn't want to fully implement ActiveRecord, because that felt dramatically out of scope for this project,
      # but I would opt to use its validation functionality rather than building it out myself and reinventing the wheel
      client_params = params.require(:client).permit(:first_name, :last_name, :time_zone)
  
      new_client = Client.new(id: SecureRandom.uuid, # would be taken care of by AR.
                                  first_name: client_params[:first_name],
                                  last_name: client_params[:last_name],
                                  time_zone: client_params[:time_zone])
  
      if new_client.save
        render json: { status: "success", message: "Client created successfully" }, status: :ok
      else
        # future proofing. json db doesn't have this error functionality yet.
        render json: { status: "error", message: "Client creation failed", errors: new_client.errors }, status: :unprocessable_entity
      end
    end
  end
  