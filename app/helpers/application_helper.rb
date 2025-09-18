module ApplicationHelper
  def service_type_color(service_type)
    service_key = service_type_key(service_type)
    case service_key
    when "preventive_maintenance"
      "is-preventive"
    when "repair"
      "is-repair"
    when "inspection"
      "is-inspection"
    when "oil_change"
      "is-oil-change"
    else
      "is-other"
    end
  end

  def translate_service_type(service_type)
    service_key = service_type_key(service_type)
    t("maintenance_services.types.#{service_key}")
  end

  private

  def service_type_key(service_type)
    case service_type
    when "Mantenimiento Preventivo", "Preventive Maintenance"
      "preventive_maintenance"
    when "Reparación", "Repair"
      "repair"
    when "Inspección", "Inspection"
      "inspection"
    when "Cambio de Aceite", "Oil Change"
      "oil_change"
    when "Otro", "Other"
      "other"
    else
      "other"
    end
  end

  def status_tag_color(status)
    case status
    when "active"
      "is-success"
    when "inactive"
      "is-danger"
    when "in_maintenance"
      "is-warning"
    when "completed"
      "is-success"
    when "pending"
      "is-warning"
    when "in_progress"
      "is-info"
    else
      "is-light"
    end
  end
end
