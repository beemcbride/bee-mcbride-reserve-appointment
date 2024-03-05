class ApplicationController < ActionController::Base
    def index
        render json: { title: "Welcome to Bee McBride's solution to Henry Med's Provider-Client Appointment Scheduling Coding Challenge! Enjoy your stay." }, status: :ok
      end
end
