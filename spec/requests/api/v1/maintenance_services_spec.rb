require 'swagger_helper'

RSpec.describe 'Maintenance Services API', type: :request do
  path '/api/v1/vehicles/{vehicle_id}/maintenance_services' do
    parameter name: :vehicle_id, in: :path, type: :integer, description: 'Vehicle ID'

    get('List maintenance services') do
      tags 'Maintenance Services'
      description 'Get list of maintenance services for a specific vehicle'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, type: :integer, description: 'Page number', example: 1
      parameter name: :per_page, in: :query, type: :integer, description: 'Items per page', example: 10
      parameter name: :status, in: :query, type: :string, description: 'Filter by status', enum: [ 'pending', 'in_progress', 'completed' ]
      parameter name: :service_type, in: :query, type: :string, description: 'Filter by service type'
      parameter name: :priority, in: :query, type: :string, description: 'Filter by priority', enum: [ 'low', 'medium', 'high' ]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       description: { type: :string },
                       status: { type: :string },
                       service_date: { type: :string, format: :date },
                       cost_cents: { type: :integer },
                       cost_in_dollars: { type: :number, format: :float },
                       priority: { type: :string },
                       service_type: { type: :string },
                       completed_at: { type: :string, format: :datetime, nullable: true },
                       vehicle_id: { type: :integer },
                       created_at: { type: :string, format: :datetime },
                       updated_at: { type: :string, format: :datetime }
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

        let(:vehicle_id) { 1 }
        run_test!
      end

      response(404, 'vehicle not found') do
        let(:vehicle_id) { 999 }
        run_test!
      end
    end

    post('Create maintenance service') do
      tags 'Maintenance Services'
      description 'Create a new maintenance service for a vehicle'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :maintenance_service, in: :body, schema: {
        type: :object,
        properties: {
          maintenance_service: {
            type: :object,
            properties: {
              description: { type: :string, example: 'Oil change and filter replacement' },
              status: { type: :string, enum: [ 'pending', 'in_progress', 'completed' ], example: 'pending' },
              service_date: { type: :string, format: :date, example: '2024-01-15' },
              cost_cents: { type: :integer, example: 5000 },
              priority: { type: :string, enum: [ 'low', 'medium', 'high' ], example: 'medium' },
              service_type: { type: :string, example: 'Preventive Maintenance' },
              completed_at: { type: :string, format: :datetime, nullable: true }
            },
            required: [ 'description', 'service_date' ]
          }
        }
      }

      response(201, 'created') do
        let(:vehicle_id) { 1 }
        let(:maintenance_service) {
          {
            maintenance_service: {
              description: 'Oil change',
              service_date: '2024-01-15',
              status: 'pending',
              priority: 'medium'
            }
          }
        }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:vehicle_id) { 1 }
        let(:maintenance_service) { { maintenance_service: { description: '' } } }

        run_test!
      end
    end
  end

  path '/api/v1/maintenance_services/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Maintenance Service ID'

    patch('Update maintenance service') do
      tags 'Maintenance Services'
      description 'Update an existing maintenance service'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :maintenance_service, in: :body, schema: {
        type: :object,
        properties: {
          maintenance_service: {
            type: :object,
            properties: {
              description: { type: :string },
              status: { type: :string, enum: [ 'pending', 'in_progress', 'completed' ] },
              service_date: { type: :string, format: :date },
              cost_cents: { type: :integer },
              priority: { type: :string, enum: [ 'low', 'medium', 'high' ] },
              service_type: { type: :string },
              completed_at: { type: :string, format: :datetime, nullable: true }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:id) { 1 }
        let(:maintenance_service) { { maintenance_service: { status: 'completed', completed_at: Time.current } } }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:id) { 1 }
        let(:maintenance_service) { { maintenance_service: { status: 'completed' } } }

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 999 }
        let(:maintenance_service) { { maintenance_service: { status: 'completed' } } }

        run_test!
      end
    end

    delete('Delete maintenance service') do
      tags 'Maintenance Services'
      description 'Delete a maintenance service'
      security [ bearerAuth: [] ]

      response(204, 'no content') do
        let(:id) { 1 }

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 999 }

        run_test!
      end
    end
  end
end

RSpec.describe "Api::V1::MaintenanceServices", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.generate_jwt_token}" } }
  let(:vehicle) { create(:vehicle) }
  let!(:maintenance_services) { create_list(:maintenance_service, 3, vehicle: vehicle) }

  describe "GET /api/v1/vehicles/:vehicle_id/maintenance_services" do
    context 'when authenticated' do
      before { get "/api/v1/vehicles/#{vehicle.id}/maintenance_services", headers: auth_headers }

      it 'returns all maintenance services for the vehicle' do
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
      let!(:pending_service) { create(:maintenance_service, vehicle: vehicle, status: 'pending') }
      let!(:completed_service) { create(:maintenance_service, vehicle: vehicle, status: 'completed') }

      before { get "/api/v1/vehicles/#{vehicle.id}/maintenance_services?status=pending", headers: auth_headers }

      it 'returns only pending services' do
        expect(json['data'].size).to eq(1)
        expect(json['data'][0]['status']).to eq('pending')
      end
    end

    context 'when vehicle does not exist' do
      before { get "/api/v1/vehicles/999/maintenance_services", headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns error message' do
        expect(json['error']['code']).to eq('NOT_FOUND')
      end
    end

    context 'when not authenticated' do
      before { get "/api/v1/vehicles/#{vehicle.id}/maintenance_services" }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "POST /api/v1/vehicles/:vehicle_id/maintenance_services" do
    let(:valid_attributes) do
      {
        description: 'Regular maintenance check',
        service_date: Date.current,
        status: 'pending',
        priority: 'medium',
        service_type: 'Preventive Maintenance'
      }
    end

    let(:invalid_attributes) do
      {
        description: '',
        service_date: ''
      }
    end

    context 'when authenticated with valid params' do
      before { post "/api/v1/vehicles/#{vehicle.id}/maintenance_services", params: { maintenance_service: valid_attributes }, headers: auth_headers }

      it 'creates a maintenance service' do
        expect(json['description']).to eq('Regular maintenance check')
        expect(json['vehicle_id']).to eq(vehicle.id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'associates the service with the vehicle' do
        expect(json['vehicle_id']).to eq(vehicle.id)
      end
    end

    context 'when authenticated with invalid params' do
      before { post "/api/v1/vehicles/#{vehicle.id}/maintenance_services", params: { maintenance_service: invalid_attributes }, headers: auth_headers }

      it 'returns validation errors' do
        expect(json['error']['code']).to eq('UNPROCESSABLE_ENTITY')
        expect(json['error']['details']).to be_present
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when trying to mark as completed without completed_at' do
      let(:incomplete_completion) { valid_attributes.merge(status: 'completed') }

      before { post "/api/v1/vehicles/#{vehicle.id}/maintenance_services", params: { maintenance_service: incomplete_completion }, headers: auth_headers }

      it 'returns validation error' do
        expect(response).to have_http_status(422)
        expect(json['error']['details']['completed_at']).to include('is required when status is completed')
      end
    end
  end

  describe "PUT /api/v1/maintenance_services/:id" do
    let(:maintenance_service) { maintenance_services.first }
    let(:valid_attributes) { { description: 'Updated maintenance check' } }

    context 'when authenticated with valid params' do
      before { put "/api/v1/maintenance_services/#{maintenance_service.id}", params: { maintenance_service: valid_attributes }, headers: auth_headers }

      it 'updates the maintenance service' do
        expect(json['description']).to eq('Updated maintenance check')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when updating vehicle status after completion' do
      let!(:pending_service) { create(:maintenance_service, vehicle: vehicle, status: 'pending') }

      before do
        put "/api/v1/maintenance_services/#{pending_service.id}",
            params: { maintenance_service: { status: 'completed', completed_at: Time.current } },
            headers: auth_headers
      end

      it 'updates vehicle status to active when no pending services remain' do
        vehicle.reload
        expect([ 'active', 'in_maintenance' ]).to include(vehicle.status)
      end
    end

    context 'when service does not exist' do
      before { put "/api/v1/maintenance_services/999", params: { maintenance_service: valid_attributes }, headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns error message' do
        expect(json['error']['code']).to eq('NOT_FOUND')
      end
    end
  end

  describe "DELETE /api/v1/maintenance_services/:id" do
    let(:maintenance_service) { maintenance_services.first }

    context 'when authenticated' do
      before { delete "/api/v1/maintenance_services/#{maintenance_service.id}", headers: auth_headers }

      it 'deletes the maintenance service' do
        expect(MaintenanceService.find_by(id: maintenance_service.id)).to be_nil
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when service does not exist' do
      before { delete "/api/v1/maintenance_services/999", headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns error message' do
        expect(json['error']['code']).to eq('NOT_FOUND')
      end
    end
  end

  describe "Business Rules" do
    let(:maintenance_service) { create(:maintenance_service, vehicle: vehicle, status: 'pending') }

    context 'when marking service as completed' do
      before do
        put "/api/v1/maintenance_services/#{maintenance_service.id}",
            params: { maintenance_service: { status: 'completed', completed_at: Time.current } },
            headers: auth_headers
      end

      it 'allows completion with completed_at timestamp' do
        expect(response).to have_http_status(200)
        expect(json['status']).to eq('completed')
        expect(json['completed_at']).to be_present
      end
    end

    context 'when vehicle has pending/in_progress services' do
      let!(:pending_service) { create(:maintenance_service, vehicle: vehicle, status: 'pending') }

      before do
        vehicle.update_maintenance_status!
        vehicle.reload
      end

      it 'sets vehicle status to in_maintenance' do
        expect(vehicle.status).to eq('in_maintenance')
      end
    end
  end

  private

  def json
    JSON.parse(response.body)
  end
end