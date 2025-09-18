class MaintenanceServicesController < ApplicationController
  before_action :set_vehicle, only: [ :index, :new, :create ]
  before_action :set_maintenance_service, only: [ :show, :edit, :update, :destroy ]

  def index
    @maintenance_services = @vehicle.maintenance_services.includes(:vehicle)
  end

  def show
  end

  def new
    @maintenance_service = @vehicle.maintenance_services.build
  end

  def create
    @maintenance_service = @vehicle.maintenance_services.build(maintenance_service_params)

    @maintenance_service.service_date if @maintenance_service.service_date.present?
    @maintenance_service.status = "pending" if @maintenance_service.status.blank?
    @maintenance_service.priority = "medium" if @maintenance_service.priority.blank?

    if @maintenance_service.status == "completed"
      @maintenance_service.completed_at = Time.current
    end

    if @maintenance_service.save
      redirect_to @maintenance_service, notice: t("messages.service_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    params_to_update = maintenance_service_params
    if params_to_update[:status] == "completed" && @maintenance_service.completed_at.blank?
      @maintenance_service.completed_at = Time.current
    elsif params_to_update[:status] != "completed"
      @maintenance_service.completed_at = nil
    end

    if @maintenance_service.update(params_to_update)
      redirect_to @maintenance_service, notice: t("messages.service_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vehicle = @maintenance_service.vehicle
    @maintenance_service.destroy
    redirect_to vehicle_maintenance_services_path(vehicle), notice: t("messages.service_deleted")
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
  end

  def set_maintenance_service
    @maintenance_service = MaintenanceService.find(params[:id])
  end

  def maintenance_service_params
    params.require(:maintenance_service).permit(:service_type, :service_date, :description, :cost, :mileage_at_service, :notes, :date, :status, :priority)
  end
end
