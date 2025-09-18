class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [ :show, :edit, :update, :destroy ]

  def index
    @vehicles = Vehicle.all.includes(:maintenance_services)
  end

  def show
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)

    if @vehicle.save
      redirect_to @vehicle, notice: t("messages.vehicle_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: t("messages.vehicle_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path, notice: t("messages.vehicle_deleted")
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:vin, :brand, :model, :year, :plate, :mileage)
  end
end
