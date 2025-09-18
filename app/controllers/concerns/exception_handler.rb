module ExceptionHandler
  extend ActiveSupport::Concern

  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ExceptionHandler::MissingToken, with: :four_twenty_two
    rescue_from ExceptionHandler::InvalidToken, with: :four_twenty_two
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from ActionController::UnpermittedParameters, with: :bad_request
  end

  private

  def four_twenty_two(e)
    json_response(
      {
        error: {
          code: "UNPROCESSABLE_ENTITY",
          message: e.message,
          details: e.respond_to?(:record) ? e.record.errors : nil
        }
      },
      :unprocessable_entity
    )
  end

  def unauthorized_request(e)
    json_response(
      {
        error: {
          code: "UNAUTHORIZED",
          message: e.message
        }
      },
      :unauthorized
    )
  end

  def not_found(e)
    json_response(
      {
        error: {
          code: "NOT_FOUND",
          message: e.message
        }
      },
      :not_found
    )
  end

  def bad_request(e)
    json_response(
      {
        error: {
          code: "BAD_REQUEST",
          message: e.message
        }
      },
      :bad_request
    )
  end
end
