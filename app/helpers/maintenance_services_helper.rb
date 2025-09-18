module MaintenanceServicesHelper
  def service_type_color(service_type)
    case service_type
    when "Mantenimiento Preventivo"
      "is-success"
    when "Reparación"
      "is-danger"
    when "Inspección"
      "is-info"
    when "Cambio de Aceite"
      "is-warning"
    else
      "is-light"
    end
  end

  def service_type_icon(service_type)
    case service_type
    when "Mantenimiento Preventivo"
      "fas fa-tools"
    when "Reparación"
      "fas fa-wrench"
    when "Inspección"
      "fas fa-search"
    when "Cambio de Aceite"
      "fas fa-oil-can"
    else
      "fas fa-cog"
    end
  end

  def format_service_cost(cost)
    return "No especificado" unless cost.present?
    "$#{number_with_delimiter(cost.to_i)}"
  end

  def days_since_service(service_date)
    return 0 unless service_date.present?
    (Date.current - service_date.to_date).to_i
  end

  def service_urgency_class(days_since)
    case days_since
    when 0..30
      "is-success"
    when 31..90
      "is-warning"
    else
      "is-danger"
    end
  end

  def maintenance_frequency_status(vehicle)
    return { status: "unknown", message: "Sin datos suficientes" } if vehicle.maintenance_services.count < 2

    services = vehicle.maintenance_services.order(:service_date)
    intervals = []

    services.each_cons(2) do |prev_service, current_service|
      days_between = (current_service.service_date - prev_service.service_date).to_i
      intervals << days_between
    end

    avg_interval = intervals.sum / intervals.size.to_f
    last_service = services.last
    days_since_last = days_since_service(last_service.service_date)

    if days_since_last > avg_interval * 1.5
      { status: "overdue", message: "Mantenimiento atrasado" }
    elsif days_since_last > avg_interval
      { status: "due", message: "Mantenimiento próximo" }
    else
      { status: "current", message: "Mantenimiento al día" }
    end
  end
end
