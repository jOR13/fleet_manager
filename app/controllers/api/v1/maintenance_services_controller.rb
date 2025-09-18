module Api
  module V1
    class MaintenanceServicesController < BaseController
      before_action :find_vehicle, only: [ :index, :create ]
      before_action :find_maintenance_service, only: [ :update, :destroy ]

      def index
        services = @vehicle.maintenance_services.includes(:vehicle)
        services = apply_filters(services)
        services = apply_sorting(services)

        pagy, paginated_services = pagy(services, items: params[:per_page] || 20)

        paginated_response(
          paginated_services,
          pagy,
          serializer: MaintenanceServiceSerializer
        )
      end

      def create
        service = @vehicle.maintenance_services.create!(maintenance_service_params)
        json_response(service, :created)
      end

      def update
        @maintenance_service.update!(maintenance_service_params)

        if @maintenance_service.completed? && @maintenance_service.completed_at.blank?
          @maintenance_service.update!(completed_at: Time.current)
        end

        json_response(@maintenance_service)
      end

      def destroy
        @maintenance_service.destroy!
        head :no_content
      end

      private

      def find_vehicle
        @vehicle = Vehicle.find(params[:vehicle_id])
      end

      def find_maintenance_service
        @maintenance_service = MaintenanceService.find(params[:id])
      end

      def maintenance_service_params
        params.require(:maintenance_service).permit(
          :description, :status, :service_date, :cost_cents, :priority, :completed_at, :service_type
        )
      end

      def apply_filters(services)
        services = services.by_status(params[:status])
        services = services.by_priority(params[:priority])
        services = services.by_date_range(params[:from], params[:to])
        services
      end

      def apply_sorting(services)
        return services unless params[:sort_by].present?

        sort_column = params[:sort_by]
        sort_direction = params[:sort_direction]&.downcase == "desc" ? :desc : :asc

        case sort_column
        when "service_date", "date", "cost_cents", "priority", "status", "created_at", "updated_at"
          services.order(sort_column => sort_direction)
        else
          services.order(service_date: :desc)
        end
      end
    end
  end
end
