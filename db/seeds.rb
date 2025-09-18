puts "Creating users for authentication..."

admin_user = User.create!(
  email: "admin@numaris.com",
  password: "password123",
  password_confirmation: "password123",
  name: "Admin User",
  role: "admin"
)

manager_user = User.create!(
  email: "manager@numaris.com",
  password: "password123",
  password_confirmation: "password123",
  name: "Manager User",
  role: "manager"
)

operator_user = User.create!(
  email: "operator@numaris.com",
  password: "password123",
  password_confirmation: "password123",
  name: "Operator User",
  role: "operator"
)

puts "Users created: #{User.count}"

puts "Creating sample vehicles..."

vehicle1 = Vehicle.create!(
  vin: "1HGBH41JXMN109186",
  brand: "Toyota",
  model: "Corolla",
  year: 2020,
  plate: "ABC-123",
  mileage: 45000
)

vehicle2 = Vehicle.create!(
  vin: "2HGFC2F59MH123456",
  brand: "Honda",
  model: "Civic",
  year: 2019,
  plate: "DEF-456",
  mileage: 52000
)

vehicle3 = Vehicle.create!(
  vin: "3N1AB7AP5MN789012",
  brand: "Nissan",
  model: "Sentra",
  year: 2021,
  plate: "GHI-789",
  mileage: 32000
)

vehicle4 = Vehicle.create!(
  vin: "1FMCU0F70NUA12345",
  brand: "Ford",
  model: "Escape",
  year: 2022,
  plate: "JKL-012",
  mileage: 28000
)

vehicle5 = Vehicle.create!(
  vin: "5N1AT3CAXSC123456",
  brand: "Nissan",
  model: "Pathfinder",
  year: 2018,
  plate: "MNO-345",
  mileage: 87000
)

puts "Creating sample maintenance services..."

MaintenanceService.create!(
  vehicle: vehicle1,
  service_type: "Cambio de Aceite",
  service_date: 3.months.ago,
  date: 3.months.ago,
  description: "Cambio de aceite 5W-30 sintético y filtro de aceite",
  cost: 45.00,
  mileage_at_service: 42000,
  status: 'completed',
  priority: 'medium',
  completed_at: 3.months.ago
)

MaintenanceService.create!(
  vehicle: vehicle1,
  service_type: "Mantenimiento Preventivo",
  service_date: 6.months.ago,
  date: 6.months.ago,
  description: "Mantenimiento de 40,000 km: cambio de aceite, filtros de aire y combustible, revisión de frenos",
  cost: 120.00,
  mileage_at_service: 40000,
  status: 'completed',
  priority: 'high',
  completed_at: 6.months.ago
)

MaintenanceService.create!(
  vehicle: vehicle1,
  service_type: "Inspección",
  service_date: Date.current,
  date: Date.current,
  description: "Inspección técnico-mecánica anual programada",
  cost: 25.00,
  mileage_at_service: 45000,
  status: 'pending',
  priority: 'medium'
)

MaintenanceService.create!(
  vehicle: vehicle2,
  service_type: "Reparación",
  service_date: 2.months.ago,
  date: 2.months.ago,
  description: "Cambio de pastillas de freno delanteras y discos",
  cost: 180.00,
  mileage_at_service: 50000,
  status: 'completed',
  priority: 'high',
  completed_at: 2.months.ago
)

MaintenanceService.create!(
  vehicle: vehicle2,
  service_type: "Cambio de Aceite",
  service_date: 4.months.ago,
  date: 4.months.ago,
  description: "Cambio de aceite convencional 10W-40",
  cost: 35.00,
  mileage_at_service: 48000,
  status: 'completed',
  priority: 'low',
  completed_at: 4.months.ago
)

MaintenanceService.create!(
  vehicle: vehicle2,
  service_type: "Reparación",
  service_date: Date.current,
  date: Date.current,
  description: "Revisión y reparación de sistema de aire acondicionado",
  cost: 145.00,
  mileage_at_service: 52000,
  status: 'in_progress',
  priority: 'medium'
)

MaintenanceService.create!(
  vehicle: vehicle3,
  service_type: "Mantenimiento Preventivo",
  service_date: 1.month.ago,
  date: 1.month.ago,
  description: "Mantenimiento de 30,000 km: cambio de aceite, filtros, revisión general",
  cost: 95.00,
  mileage_at_service: 30000,
  status: 'completed',
  priority: 'medium',
  completed_at: 1.month.ago
)

MaintenanceService.create!(
  vehicle: vehicle3,
  service_type: "Inspección",
  service_date: 2.weeks.ago,
  date: 2.weeks.ago,
  description: "Diagnóstico de ruido en motor",
  cost: 55.00,
  mileage_at_service: 31500,
  status: 'completed',
  priority: 'high',
  completed_at: 2.weeks.ago
)

MaintenanceService.create!(
  vehicle: vehicle4,
  service_type: "Cambio de Aceite",
  service_date: 1.month.ago,
  date: 1.month.ago,
  description: "Cambio de aceite sintético 0W-20 y filtro",
  cost: 52.00,
  mileage_at_service: 27000,
  status: 'completed',
  priority: 'medium',
  completed_at: 1.month.ago
)

MaintenanceService.create!(
  vehicle: vehicle4,
  service_type: "Mantenimiento Preventivo",
  service_date: Date.current,
  date: Date.current,
  description: "Mantenimiento programado de 30,000 km",
  cost: 165.00,
  mileage_at_service: 30000,
  status: 'pending',
  priority: 'high'
)

MaintenanceService.create!(
  vehicle: vehicle4,
  service_type: "Inspección",
  service_date: 5.months.ago,
  date: 5.months.ago,
  description: "Inspección anual obligatoria",
  cost: 30.00,
  mileage_at_service: 25000,
  status: 'completed',
  priority: 'medium',
  completed_at: 5.months.ago
)

MaintenanceService.create!(
  vehicle: vehicle5,
  service_type: "Reparación",
  service_date: 3.months.ago,
  date: 3.months.ago,
  description: "Cambio de correa de distribución y bomba de agua",
  cost: 385.00,
  mileage_at_service: 85000,
  status: 'completed',
  priority: 'high',
  completed_at: 3.months.ago
)

MaintenanceService.create!(
  vehicle: vehicle5,
  service_type: "Cambio de Aceite",
  service_date: 6.weeks.ago,
  date: 6.weeks.ago,
  description: "Cambio de aceite de alta kilometraje 5W-30",
  cost: 48.00,
  mileage_at_service: 86500,
  status: 'completed',
  priority: 'medium',
  completed_at: 6.weeks.ago
)

MaintenanceService.create!(
  vehicle: vehicle5,
  service_type: "Mantenimiento Preventivo",
  service_date: 1.week.ago,
  date: 1.week.ago,
  description: "Revisión de transmisión y cambio de aceite ATF",
  cost: 125.00,
  mileage_at_service: 87000,
  status: 'completed',
  priority: 'high',
  completed_at: 1.week.ago
)

MaintenanceService.create!(
  vehicle: vehicle5,
  service_type: "Reparación",
  service_date: Date.current,
  date: Date.current,
  description: "Reparación de sistema eléctrico - luces intermitentes",
  cost: 75.00,
  mileage_at_service: 87200,
  status: 'pending',
  priority: 'low'
)

puts "Sample data created successfully!"
puts "Vehicles: #{Vehicle.count}"
puts "Maintenance Services: #{MaintenanceService.count}"

puts "Updating vehicle statuses based on maintenance services..."
Vehicle.all.each do |vehicle|
  vehicle.update_maintenance_status!
  puts "Vehicle #{vehicle.plate}: #{vehicle.status}"
end

puts "Final vehicle statuses:"
Vehicle.all.each do |vehicle|
  pending_services = vehicle.maintenance_services.where(status: %w[pending in_progress]).count
  puts "- #{vehicle.brand} #{vehicle.model} (#{vehicle.plate}): #{vehicle.status} (#{pending_services} pending/in_progress services)"
end
