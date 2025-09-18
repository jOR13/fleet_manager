require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/login' do
    post('Login') do
      tags 'Authentication'
      description 'Authenticate user and get JWT token'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'admin@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: [ 'email', 'password' ]
      }

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 token: { type: :string, description: 'JWT token' },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     email: { type: :string },
                     name: { type: :string },
                     role: { type: :string }
                   }
                 }
               }

        let(:credentials) { { email: 'admin@example.com', password: 'password123' } }

        run_test!
      end

      response(401, 'unauthorized') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     message: { type: :string },
                     code: { type: :string }
                   }
                 }
               }

        let(:credentials) { { email: 'wrong@example.com', password: 'wrongpass' } }

        run_test!
      end
    end
  end

  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe "POST /api/v1/auth/login" do
    let(:valid_credentials) { { email: user.email, password: 'password123' } }
    let(:invalid_credentials) { { email: user.email, password: 'wrong_password' } }

    context 'when credentials are valid' do
      before { post '/api/v1/auth/login', params: valid_credentials }

      it 'returns auth token' do
        expect(json['token']).not_to be_nil
      end

      it 'returns user data' do
        expect(json['user']).to include(
          'id' => user.id,
          'email' => user.email,
          'name' => user.name,
          'role' => user.role
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when credentials are invalid' do
      before { post '/api/v1/auth/login', params: invalid_credentials }

      it 'returns failure message' do
        expect(json['error']['message']).to match(/Invalid credentials/)
      end

      it 'returns error code' do
        expect(json['error']['code']).to eq('UNAUTHORIZED')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when email is missing' do
      before { post '/api/v1/auth/login', params: { password: 'password123' } }

      it 'returns failure message' do
        expect(json['error']['message']).to be_present
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end

    context 'when password is missing' do
      before { post '/api/v1/auth/login', params: { email: user.email } }

      it 'returns failure message' do
        expect(json['error']['message']).to be_present
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end
  end

  private

  def json
    JSON.parse(response.body)
  end
end
