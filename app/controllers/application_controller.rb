class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
