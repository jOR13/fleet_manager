module Api
  module V1
    class AuthController < ApplicationController
      include Response
      include ExceptionHandler

      skip_before_action :verify_authenticity_token

      def login
        auth_token = AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
        json_response(auth_token: auth_token)
      end

      private

      def auth_params
        params.permit(:email, :password)
      end
    end
  end
end
