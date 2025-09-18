class MaintenanceServiceSerializer < ActiveModel::Serializer
  attributes :id, :description, :status, :service_date, :cost_cents, :cost_in_dollars,
             :priority, :completed_at, :created_at, :updated_at, :vehicle_id

  belongs_to :vehicle, serializer: VehicleBasicSerializer

  def cost_in_dollars
    object.cost_in_dollars
  end
end
