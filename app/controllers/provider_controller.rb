class ProviderController < ActionController::API
  def index
    all_providers = Provider.get_from_totally_real_api
    render json: all_providers
  end

  def create
    # Assuming params[:provider] contains the nested data for a provider.
    # we should validate all data is in the format we expect, not just shove it through
    # I didn't want to fully implement ActiveRecord, because that felt dramatically out of scope for this project,
    # but I would opt to use its validation functionality rather than building it out myself and reinventing the wheel
    provider_params = params.require(:provider).permit(:first_name, :last_name, :license, :time_zone, :licensed_states)

    new_provider = Provider.new(id: SecureRandom.uuid, # would be taken care of by AR.
                                first_name: provider_params[:first_name],
                                last_name: provider_params[:last_name],
                                license: provider_params[:license],
                                time_zone: provider_params[:time_zone],
                                licensed_states: provider_params[:licensed_states])

    if new_provider.save
      render json: { status: "success", message: "Provider created successfully" }, status: :ok
    else
      # future proofing. json db doesn't have this error functionality yet.
      render json: { status: "error", message: "Provider creation failed", errors: new_provider.errors }, status: :unprocessable_entity
    end
  end
end
