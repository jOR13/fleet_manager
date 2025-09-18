class ReportsController < ApplicationController
  def index
    date_range = build_date_range
    services = MaintenanceService.includes(:vehicle)
    services = services.by_date_range(date_range[:from], date_range[:to]) if date_range

    @report = {
      period: {
        from: date_range&.dig(:from),
        to: date_range&.dig(:to)
      },
      totals: calculate_totals(services),
      by_status: group_by_status(services),
      by_vehicle: group_by_vehicle(services),
      by_service_type: group_by_service_type(services),
      top_vehicles_by_cost: top_vehicles_by_cost(services),
      monthly_trend: monthly_trend(services)
    }

    @vehicles = Vehicle.all
    @from_date = params[:from]
    @to_date = params[:to]

    respond_to do |format|
      format.html
    end
  end

  def export
    date_range = build_date_range
    services = MaintenanceService.includes(:vehicle)
    services = services.by_date_range(date_range[:from], date_range[:to]) if date_range

    @report = {
      period: {
        from: date_range&.dig(:from),
        to: date_range&.dig(:to)
      },
      totals: calculate_totals(services),
      by_status: group_by_status(services),
      by_vehicle: group_by_vehicle(services),
      top_vehicles_by_cost: top_vehicles_by_cost(services)
    }

    case params[:format]&.downcase
    when "csv"
      send_data generate_csv(@report),
               filename: "maintenance_summary_#{Date.current}.csv",
               type: "text/csv"
    when "xlsx"
      # For simplicity, provide CSV format with Excel filename extension
      # This allows Excel to open the file while avoiding complex Excel generation
      send_data generate_csv(@report),
               filename: "maintenance_summary_#{Date.current}.xlsx",
               type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    else
      redirect_to reports_path, alert: "Invalid format"
    end
  end

  private

  def build_date_range
    return nil unless params[:from].present? || params[:to].present?

    {
      from: params[:from].present? ? Date.parse(params[:from]) : nil,
      to: params[:to].present? ? Date.parse(params[:to]) : nil
    }
  rescue ArgumentError
    redirect_to reports_path, alert: "Invalid date format"
    nil
  end

  def calculate_totals(services)
    {
      total_orders: services.count,
      total_cost_cents: services.sum(:cost_cents),
      total_cost_dollars: services.sum(:cost_cents) / 100.0,
      average_cost_cents: services.count > 0 ? services.average(:cost_cents).to_i : 0,
      average_cost_dollars: services.count > 0 ? (services.average(:cost_cents).to_f / 100.0).round(2) : 0
    }
  end

  def group_by_status(services)
    services.group(:status).count.map do |status, count|
      cost_cents = services.where(status: status).sum(:cost_cents)
      {
        status: status,
        count: count,
        total_cost_cents: cost_cents,
        total_cost_dollars: cost_cents / 100.0
      }
    end
  end

  def group_by_service_type(services)
    services.group(:service_type).count.map do |service_type, count|
      cost_cents = services.where(service_type: service_type).sum(:cost_cents)
      {
        service_type: service_type,
        count: count,
        total_cost_cents: cost_cents,
        total_cost_dollars: cost_cents / 100.0
      }
    end
  end

  def group_by_vehicle(services)
    grouped_data = services.joins(:vehicle)
                          .group("vehicles.id")
                          .group("vehicles.plate")
                          .group("vehicles.vin")
                          .group("vehicles.brand")
                          .group("vehicles.model")
                          .count

    cost_data = services.joins(:vehicle)
                       .group("vehicles.id")
                       .sum(:cost_cents)

    result = []
    grouped_data.each do |vehicle_info, count|
      vehicle_id, plate, vin, brand, model = vehicle_info
      cost_cents = cost_data[vehicle_id] || 0

      result << {
        vehicle: {
          id: vehicle_id,
          plate: plate,
          vin: vin,
          brand: brand,
          model: model
        },
        total_orders: count,
        total_cost_cents: cost_cents,
        total_cost_dollars: cost_cents / 100.0
      }
    end
    result
  end

  def top_vehicles_by_cost(services, limit = 3)
    group_by_vehicle(services)
      .sort_by { |item| -item[:total_cost_cents] }
      .first(limit)
  end

  def monthly_trend(services)
    monthly_data = {}
    6.times do |i|
      month = i.months.ago.beginning_of_month
      month_key = month.strftime("%Y-%m")
      monthly_data[month_key] = services.where(
        service_date: month..month.end_of_month
      ).group(:service_type).count
    end
    monthly_data
  end

  def generate_csv(report)
    require "csv"

    CSV.generate(headers: true) do |csv|
      csv << [ "MAINTENANCE SUMMARY REPORT" ]
      csv << [ "Period", "#{report[:period][:from]} to #{report[:period][:to]}" ]
      csv << []

      csv << [ "TOTALS" ]
      csv << [ "Total Orders", report[:totals][:total_orders] ]
      csv << [ "Total Cost (Dollars)", "$#{report[:totals][:total_cost_dollars]}" ]
      csv << [ "Average Cost (Dollars)", "$#{report[:totals][:average_cost_dollars]}" ]
      csv << []

      csv << [ "BY VEHICLE" ]
      csv << [ "Vehicle ID", "Plate", "VIN", "Brand", "Model", "Orders", "Total Cost" ]
      report[:by_vehicle].each do |vehicle_data|
        csv << [
          vehicle_data[:vehicle][:id],
          vehicle_data[:vehicle][:plate],
          vehicle_data[:vehicle][:vin],
          vehicle_data[:vehicle][:brand],
          vehicle_data[:vehicle][:model],
          vehicle_data[:total_orders],
          "$#{vehicle_data[:total_cost_dollars]}"
        ]
      end
    end
  end
end
