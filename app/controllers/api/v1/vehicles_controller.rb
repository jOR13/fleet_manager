module Api
  module V1
    class VehiclesController < BaseController
      before_action :find_vehicle, only: [ :show, :update, :destroy ]

      def index
        vehicles = Vehicle.includes(:maintenance_services)
        vehicles = apply_filters(vehicles)
        vehicles = apply_search(vehicles)
        vehicles = apply_sorting(vehicles)

        pagy, paginated_vehicles = pagy(vehicles, items: params[:per_page] || 20)

        paginated_response(
          paginated_vehicles,
          pagy,
          serializer: VehicleBasicSerializer
        )
      end

      def show
        json_response(@vehicle.as_json(
          include: {
            maintenance_services: {
              only: [ :id, :service_type, :service_date, :description, :cost_cents, :status ],
              methods: [ :cost ]
            }
          }
        ))
      end

      def create
        vehicle = Vehicle.create!(vehicle_params)
        json_response(vehicle, :created)
      end

      def update
        @vehicle.update!(vehicle_params)
        json_response(@vehicle)
      end

      def destroy
        @vehicle.destroy
        head :no_content
      end

      private

      def find_vehicle
        @vehicle = Vehicle.find(params[:id])
      end

      def vehicle_params
        params.require(:vehicle).permit(:vin, :plate, :brand, :model, :year, :status)
      end

      def apply_filters(vehicles)
        vehicles = vehicles.by_status(params[:status])
        vehicles = vehicles.by_brand(params[:brand])
        vehicles = vehicles.by_year(params[:year])
        vehicles
      end

      def apply_search(vehicles)
        vehicles = vehicles.search(params[:search])
        vehicles
      end

      def apply_sorting(vehicles)
        return vehicles unless params[:sort_by].present?

        sort_column = params[:sort_by]
        sort_direction = params[:sort_direction]&.downcase == "desc" ? :desc : :asc

        case sort_column
        when "vin", "plate", "brand", "model", "year", "status", "created_at", "updated_at"
          vehicles.order(sort_column => sort_direction)
        else
          vehicles.order(created_at: :desc)
        end
      end
    end
  end
end
