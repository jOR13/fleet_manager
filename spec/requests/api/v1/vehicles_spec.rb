require 'swagger_helper'

RSpec.describe 'Vehicles API', type: :request do
  path '/api/v1/vehicles' do
    get('List vehicles') do
      tags 'Vehicles'
      description 'Get list of vehicles with optional filtering and pagination'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, type: :integer, description: 'Page number', example: 1
      parameter name: :items, in: :query, type: :integer, description: 'Items per page', example: 10
      parameter name: :search, in: :query, type: :string, description: 'Search by VIN, plate, brand, or model'
      parameter name: :status, in: :query, type: :string, description: 'Filter by status', enum: [ 'active', 'inactive', 'in_maintenance' ]
      parameter name: :brand, in: :query, type: :string, description: 'Filter by brand'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       vin: { type: :string },
                       brand: { type: :string },
                       model: { type: :string },
                       year: { type: :integer },
                       plate: { type: :string },
                       mileage: { type: :integer },
                       status: { type: :string }
                     }
                   }
                 },
                 pagination: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer },
                     per_page: { type: :integer }
                   }
                 }
               }

        run_test!
      end

      response(422, 'unauthorized') do
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

        run_test!
      end
    end

    post('Create vehicle') do
      tags 'Vehicles'
      description 'Create a new vehicle'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          vehicle: {
            type: :object,
            properties: {
              vin: { type: :string, example: '1HGBH41JXMN109186' },
              brand: { type: :string, example: 'Toyota' },
              model: { type: :string, example: 'Corolla' },
              year: { type: :integer, example: 2020 },
              plate: { type: :string, example: 'ABC-123' },
              mileage: { type: :integer, example: 15000 }
            },
            required: [ 'vin', 'brand', 'model', 'year', 'plate' ]
          }
        }
      }

      response(201, 'created') do
        let(:vehicle) { { vehicle: { vin: '1HGBH41JXMN109186', brand: 'Toyota', model: 'Corolla', year: 2020, plate: 'ABC-123' } } }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:vehicle) { { vehicle: { brand: 'Toyota' } } }

        run_test!
      end
    end
  end

  path '/api/v1/vehicles/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Vehicle ID'

    get('Show vehicle') do
      tags 'Vehicles'
      description 'Get vehicle details'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let(:id) { 1 }

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 999 }

        run_test!
      end
    end

    put('Update vehicle') do
      tags 'Vehicles'
      description 'Update vehicle information'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          vehicle: {
            type: :object,
            properties: {
              vin: { type: :string },
              brand: { type: :string },
              model: { type: :string },
              year: { type: :integer },
              plate: { type: :string },
              mileage: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:id) { 1 }
        let(:vehicle) { { vehicle: { brand: 'Honda', model: 'Civic' } } }

        run_test!
      end
    end

    delete('Delete vehicle') do
      tags 'Vehicles'
      description 'Delete a vehicle'
      security [ bearerAuth: [] ]

      response(204, 'no content') do
        let(:id) { 1 }

        run_test!
      end
    end
  end
end

RSpec.describe "Api::V1::Vehicles", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.generate_jwt_token}" } }
  let!(:vehicles) { create_list(:vehicle, 3) }

  describe "GET /api/v1/vehicles" do
    context 'when authenticated' do
      before { get '/api/v1/vehicles', headers: auth_headers }

      it 'returns all vehicles' do
        expect(json['data'].size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns pagination metadata' do
        expect(json['pagination']).to include(
          'current_page',
          'total_pages',
          'total_count',
          'per_page'
        )
      end
    end

    context 'when filtering by status' do
      let!(:active_vehicle) { create(:vehicle, status: 'active') }
      let!(:inactive_vehicle) { create(:vehicle, status: 'inactive') }

      before { get '/api/v1/vehicles?status=active', headers: auth_headers }

      it 'returns only active vehicles' do
        expect(json['data'].size).to eq(4) # 3 from factory + 1 active
        json['data'].each do |vehicle|
          expect(vehicle['status']).to eq('active')
        end
      end
    end

    context 'when searching' do
      let!(:toyota_vehicle) { create(:vehicle, brand: 'Toyota', model: 'Camry') }

      before { get '/api/v1/vehicles?search=toyota', headers: auth_headers }

      it 'returns matching vehicles' do
        expect(json['data'].size).to eq(1)
        expect(json['data'][0]['brand']).to eq('Toyota')
      end
    end

    context 'when not authenticated' do
      before { get '/api/v1/vehicles' }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns error message' do
        expect(json['error']['code']).to eq('UNPROCESSABLE_ENTITY')
      end
    end
  end

  describe "GET /api/v1/vehicles/:id" do
    let(:vehicle) { vehicles.first }

    context 'when authenticated and vehicle exists' do
      before { get "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers }

      it 'returns the vehicle' do
        expect(json['id']).to eq(vehicle.id)
        expect(json['vin']).to eq(vehicle.vin)
        expect(json['plate']).to eq(vehicle.plate)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when vehicle does not exist' do
      before { get "/api/v1/vehicles/999", headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns error message' do
        expect(json['error']['code']).to eq('NOT_FOUND')
      end
    end
  end

  describe "POST /api/v1/vehicles" do
    let(:valid_attributes) do
      {
        vin: 'WBAJW5C50EG123456',
        plate: 'ABC-123',
        brand: 'BMW',
        model: 'X5',
        year: 2020
      }
    end

    let(:invalid_attributes) do
      {
        vin: '',
        plate: 'ABC-123',
        brand: 'BMW'
      }
    end

    context 'when authenticated with valid params' do
      before { post '/api/v1/vehicles', params: { vehicle: valid_attributes }, headers: auth_headers }

      it 'creates a vehicle' do
        expect(json['vin']).to eq('WBAJW5C50EG123456')
        expect(json['brand']).to eq('BMW')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when authenticated with invalid params' do
      before { post '/api/v1/vehicles', params: { vehicle: invalid_attributes }, headers: auth_headers }

      it 'returns validation errors' do
        expect(json['error']['code']).to eq('UNPROCESSABLE_ENTITY')
        expect(json['error']['details']).to be_present
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PUT /api/v1/vehicles/:id" do
    let(:vehicle) { vehicles.first }
    let(:valid_attributes) { { brand: 'Updated Brand' } }

    context 'when authenticated with valid params' do
      before { put "/api/v1/vehicles/#{vehicle.id}", params: { vehicle: valid_attributes }, headers: auth_headers }

      it 'updates the vehicle' do
        expect(json['brand']).to eq('Updated Brand')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "DELETE /api/v1/vehicles/:id" do
    let(:vehicle) { vehicles.first }

    context 'when authenticated' do
      before { delete "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers }

      it 'deletes the vehicle' do
        expect(Vehicle.find_by(id: vehicle.id)).to be_nil
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  private

  def json
    JSON.parse(response.body)
  end
end
