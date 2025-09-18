module Api
  module V1
    class ReportsController < BaseController
      def maintenance_summary
        date_range = build_date_range
        services = MaintenanceService.includes(:vehicle)
        services = services.by_date_range(date_range[:from], date_range[:to]) if date_range

        report = {
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
          send_data generate_csv(report),
                   filename: "maintenance_summary_#{Date.current}.csv",
                   type: "text/csv"
        when "excel", "xlsx"
          send_data generate_excel(report),
                   filename: "maintenance_summary_#{Date.current}.xlsx",
                   type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        else
          json_response(report)
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
        raise ActionController::BadRequest, "Invalid date format. Use YYYY-MM-DD"
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
        end.group_by { |item| item[:status] }
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

          csv << []
          csv << [ "TOP 3 VEHICLES BY COST" ]
          csv << [ "Rank", "Vehicle ID", "Plate", "Brand/Model", "Total Cost" ]
          report[:top_vehicles_by_cost].each_with_index do |vehicle_data, index|
            csv << [
              index + 1,
              vehicle_data[:vehicle][:id],
              vehicle_data[:vehicle][:plate],
              "#{vehicle_data[:vehicle][:brand]} #{vehicle_data[:vehicle][:model]}",
              "$#{vehicle_data[:total_cost_dollars]}"
            ]
          end
        end
      end

      def generate_excel(report)
        generate_csv(report)
      end
    end
  end
end
