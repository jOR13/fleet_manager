class AddFieldsToMaintenanceServices < ActiveRecord::Migration[7.2]
  def change
    add_column :maintenance_services, :service_type, :string
    add_column :maintenance_services, :service_date, :date
    add_column :maintenance_services, :mileage_at_service, :integer
    add_column :maintenance_services, :notes, :text
  end
end
