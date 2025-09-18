require 'swagger_helper'

RSpec.describe 'Reports API', type: :request do
  path '/api/v1/reports/maintenance_summary' do
    get('Get maintenance summary report') do
      tags 'Reports'
      description 'Get comprehensive maintenance summary with totals, groupings, and statistics'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :from, in: :query, type: :string, format: :date, description: 'Start date (YYYY-MM-DD)', example: '2024-01-01'
      parameter name: :to, in: :query, type: :string, format: :date, description: 'End date (YYYY-MM-DD)', example: '2024-12-31'
      parameter name: :format, in: :query, type: :string, description: 'Response format', enum: [ 'json', 'csv', 'excel' ], example: 'json'

      response(200, 'successful - JSON response') do
        schema type: :object,
               properties: {
                 period: {
                   type: :object,
                   properties: {
                     from: { type: :string, format: :date, nullable: true },
                     to: { type: :string, format: :date, nullable: true }
                   }
                 },
                 totals: {
                   type: :object,
                   properties: {
                     total_orders: { type: :integer, description: 'Total number of maintenance services' },
                     total_cost_cents: { type: :integer, description: 'Total cost in cents' },
                     total_cost_dollars: { type: :number, description: 'Total cost in dollars' },
                     average_cost_cents: { type: :integer, description: 'Average cost in cents' },
                     average_cost_dollars: { type: :number, description: 'Average cost in dollars' }
                   }
                 },
                 by_status: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       status: { type: :string, enum: [ 'pending', 'in_progress', 'completed' ] },
                       count: { type: :integer },
                       total_cost_cents: { type: :integer },
                       total_cost_dollars: { type: :number }
                     }
                   }
                 },
                 by_vehicle: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       vehicle: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           plate: { type: :string },
                           vin: { type: :string },
                           brand: { type: :string },
                           model: { type: :string }
                         }
                       },
                       total_orders: { type: :integer },
                       total_cost_cents: { type: :integer },
                       total_cost_dollars: { type: :number }
                     }
                   }
                 },
                 top_vehicles_by_cost: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       vehicle: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           plate: { type: :string },
                           vin: { type: :string },
                           brand: { type: :string },
                           model: { type: :string }
                         }
                       },
                       total_orders: { type: :integer },
                       total_cost_cents: { type: :integer },
                       total_cost_dollars: { type: :number }
                     }
                   },
                   description: 'Top 3 vehicles by maintenance cost'
                 }
               }

        run_test!
      end

      response(200, 'successful - CSV export') do
        produces 'text/csv'

        let(:format) { 'csv' }

        run_test! do |response|
          expect(response.content_type).to include('text/csv')
          expect(response.headers['Content-Disposition']).to include('attachment')
          expect(response.headers['Content-Disposition']).to include('.csv')
        end
      end

      response(200, 'successful - Excel export') do
        produces 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

        let(:format) { 'excel' }

        run_test! do |response|
          expect(response.content_type).to include('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
          expect(response.headers['Content-Disposition']).to include('attachment')
          expect(response.headers['Content-Disposition']).to include('.xlsx')
        end
      end

      response(400, 'bad request - invalid date format') do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     message: { type: :string, example: 'Invalid date format. Use YYYY-MM-DD' },
                     code: { type: :string, example: 'BAD_REQUEST' }
                   }
                 }
               }

        let(:from) { 'invalid-date' }

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

        run_test!
      end
    end
  end
end

RSpec.describe "Api::V1::Reports", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.generate_jwt_token}" } }
  let(:vehicle1) { create(:vehicle, plate: 'ABC-123', brand: 'Toyota', model: 'Camry') }
  let(:vehicle2) { create(:vehicle, plate: 'DEF-456', brand: 'Honda', model: 'Civic') }

  let!(:service1) { create(:maintenance_service, vehicle: vehicle1, cost_cents: 5000, status: 'completed', date: 1.month.ago) }
  let!(:service2) { create(:maintenance_service, vehicle: vehicle1, cost_cents: 7500, status: 'pending', date: 1.week.ago) }
  let!(:service3) { create(:maintenance_service, vehicle: vehicle2, cost_cents: 12000, status: 'completed', date: 2.weeks.ago) }
  let!(:service4) { create(:maintenance_service, vehicle: vehicle2, cost_cents: 3000, status: 'in_progress', date: 3.days.ago) }

  describe "GET /api/v1/reports/maintenance_summary" do
    context 'when authenticated' do
      before { get '/api/v1/reports/maintenance_summary', headers: auth_headers }

      it 'returns maintenance summary report' do
        expect(json).to have_key('totals')
        expect(json).to have_key('by_status')
        expect(json).to have_key('by_vehicle')
        expect(json).to have_key('top_vehicles_by_cost')
        expect(json).to have_key('period')
      end

      it 'returns correct totals' do
        totals = json['totals']
        expect(totals['total_orders']).to eq(4)
        expect(totals['total_cost_cents']).to eq(27500) # 5000 + 7500 + 12000 + 3000
        expect(totals['total_cost_dollars']).to eq(275.0)
      end

      it 'returns breakdown by status' do
        by_status = json['by_status']
        expect(by_status).to be_a(Hash)
        expect(by_status.keys).to include('completed', 'pending', 'in_progress')
      end

      it 'returns breakdown by vehicle' do
        by_vehicle = json['by_vehicle']
        expect(by_vehicle).to be_a(Array)
        expect(by_vehicle.size).to eq(2)

        vehicle1_data = by_vehicle.find { |v| v['vehicle']['id'] == vehicle1.id }
        expect(vehicle1_data['total_orders']).to eq(2)
        expect(vehicle1_data['total_cost_cents']).to eq(12500) # 5000 + 7500
      end

      it 'returns top 3 vehicles by cost' do
        top_vehicles = json['top_vehicles_by_cost']
        expect(top_vehicles).to be_a(Array)
        expect(top_vehicles.size).to be <= 3

        # Should be sorted by cost descending
        first_vehicle = top_vehicles.first
        expect(first_vehicle['total_cost_cents']).to eq(15000) # vehicle2: 12000 + 3000
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when filtering by date range' do
      let(:from_date) { 2.weeks.ago.to_date }
      let(:to_date) { Date.current }

      before { get "/api/v1/reports/maintenance_summary?from=#{from_date}&to=#{to_date}", headers: auth_headers }

      it 'filters services by date range' do
        expect(json['period']['from']).to eq(from_date.to_s)
        expect(json['period']['to']).to eq(to_date.to_s)

        # Should only include services within the date range
        totals = json['totals']
        expect(totals['total_orders']).to eq(3) # Excludes service1 from 1.month.ago
      end
    end

    context 'when requesting CSV format' do
      before { get '/api/v1/reports/maintenance_summary?format=csv', headers: auth_headers }

      it 'returns CSV content' do
        expect(response.content_type).to include('text/csv')
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('.csv')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'includes report data in CSV format' do
        csv_content = response.body
        expect(csv_content).to include('MAINTENANCE SUMMARY REPORT')
        expect(csv_content).to include('TOTALS')
        expect(csv_content).to include('BY VEHICLE')
        expect(csv_content).to include('TOP 3 VEHICLES BY COST')
      end
    end

    context 'when requesting Excel format' do
      before { get '/api/v1/reports/maintenance_summary?format=excel', headers: auth_headers }

      it 'returns Excel content type' do
        expect(response.content_type).to include('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('.xlsx')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid date format' do
      before { get '/api/v1/reports/maintenance_summary?from=invalid-date', headers: auth_headers }

      it 'returns bad request error' do
        expect(response).to have_http_status(400)
        expect(json['error']['message']).to include('Invalid date format')
      end
    end

    context 'when not authenticated' do
      before { get '/api/v1/reports/maintenance_summary' }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns error message' do
        expect(json['error']['code']).to eq('UNPROCESSABLE_ENTITY')
      end
    end
  end

  describe "Business Logic Validation" do
    context 'when calculating top vehicles by cost' do
      before { get '/api/v1/reports/maintenance_summary', headers: auth_headers }

      it 'correctly ranks vehicles by total cost' do
        top_vehicles = json['top_vehicles_by_cost']

        # Vehicle2 should be first (15000 cents)
        first_vehicle = top_vehicles.first
        expect(first_vehicle['vehicle']['id']).to eq(vehicle2.id)
        expect(first_vehicle['total_cost_cents']).to eq(15000)

        # Vehicle1 should be second (12500 cents)
        second_vehicle = top_vehicles.second
        expect(second_vehicle['vehicle']['id']).to eq(vehicle1.id)
        expect(second_vehicle['total_cost_cents']).to eq(12500)
      end

      it 'limits results to top 3 vehicles' do
        top_vehicles = json['top_vehicles_by_cost']
        expect(top_vehicles.size).to be <= 3
      end
    end

    context 'when grouping by status' do
      before { get '/api/v1/reports/maintenance_summary', headers: auth_headers }

      it 'correctly groups services by status' do
        by_status = json['by_status']

        # Check completed status
        completed = by_status['completed'].first
        expect(completed['count']).to eq(2)
        expect(completed['total_cost_cents']).to eq(17000) # service1: 5000 + service3: 12000

        # Check pending status
        pending = by_status['pending'].first
        expect(pending['count']).to eq(1)
        expect(pending['total_cost_cents']).to eq(7500) # service2: 7500

        # Check in_progress status
        in_progress = by_status['in_progress'].first
        expect(in_progress['count']).to eq(1)
        expect(in_progress['total_cost_cents']).to eq(3000) # service4: 3000
      end
    end

    context 'when calculating averages' do
      before { get '/api/v1/reports/maintenance_summary', headers: auth_headers }

      it 'correctly calculates average costs' do
        totals = json['totals']
        expected_average = 27500 / 4 # total_cost_cents / total_orders
        expect(totals['average_cost_cents']).to eq(expected_average)
        expect(totals['average_cost_dollars']).to eq((expected_average / 100.0).round(2))
      end
    end
  end

  private

  def json
    JSON.parse(response.body)
  end
end
