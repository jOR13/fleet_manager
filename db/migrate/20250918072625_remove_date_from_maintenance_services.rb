class RemoveDateFromMaintenanceServices < ActiveRecord::Migration[7.2]
  def change
    remove_column :maintenance_services, :date, :date
  end
end
