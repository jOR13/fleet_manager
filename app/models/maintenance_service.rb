class MaintenanceService < ApplicationRecord
  belongs_to :vehicle

  enum status: { pending: "pending", in_progress: "in_progress", completed: "completed" }
  enum priority: { low: "low", medium: "medium", high: "high" }

  validates :description, presence: true
  validates :status, :priority, presence: true
  validates :cost_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :service_type, presence: true
  validates :service_date, presence: true
  validates :mileage_at_service, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validate :service_date_cannot_be_future
  validate :completed_status_requires_completed_at

  after_save :update_vehicle_status
  after_destroy :update_vehicle_status

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_date_range, ->(from, to) {
    if from.present? && to.present?
      where(service_date: from..to)
    elsif from.present?
      where("service_date >= ?", from)
    elsif to.present?
      where("service_date <= ?", to)
    end
  }

  def cost_in_dollars
    cost_cents / 100.0
  end

  def cost_in_dollars=(dollars)
    self.cost_cents = (dollars.to_f * 100).round
  end

  def cost
    cost_in_dollars
  end

  def cost=(dollars)
    self.cost_in_dollars = dollars
  end

  private

  def service_date_cannot_be_future
    return unless service_date.present?

    errors.add(:service_date, "can't be in the future") if service_date > Date.current
  end

  def completed_status_requires_completed_at
    if completed? && completed_at.blank?
      errors.add(:completed_at, "is required when status is completed")
    end

    if !completed? && completed_at.present?
      self.completed_at = nil
    end
  end

  def update_vehicle_status
    Rails.logger.info "MaintenanceService #{id}: Updating vehicle #{vehicle_id} status after service status changed to #{status}"
    vehicle.update_maintenance_status!
  end
end
