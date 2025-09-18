class VehicleSerializer < ActiveModel::Serializer
  attributes :id, :vin, :plate, :brand, :model, :year, :status, :created_at, :updated_at

  has_many :maintenance_services, serializer: MaintenanceServiceSerializer

  def maintenance_services
    object.maintenance_services.includes(:vehicle)
  end
end
