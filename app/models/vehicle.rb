class Vehicle < ApplicationRecord
  has_many :maintenance_services, dependent: :destroy

  enum status: { active: "active", inactive: "inactive", in_maintenance: "in_maintenance" }

  validates :vin, presence: true, uniqueness: { case_sensitive: false }, length: { is: 17 }
  validates :plate, presence: true, uniqueness: { case_sensitive: false }
  validates :brand, :model, presence: true
  validates :year, presence: true, inclusion: { in: 1990..2050 }
  validates :status, presence: true
  validates :mileage, presence: false, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  before_save :upcase_vin_and_plate

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_brand, ->(brand) { where(brand: brand) if brand.present? }
  scope :by_year, ->(year) { where(year: year) if year.present? }
  scope :search, ->(term) {
    if term.present?
      where("vin ILIKE ? OR plate ILIKE ? OR brand ILIKE ? OR model ILIKE ?",
            "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
    end
  }

  def update_maintenance_status!
    pending_or_in_progress = maintenance_services.where(status: %w[pending in_progress]).exists?

    new_status = if pending_or_in_progress
                   "in_maintenance"
    elsif status == "inactive"
                   "inactive"
    else
                   "active"
    end

    if status != new_status
      Rails.logger.info "Vehicle #{id}: Updating status from #{status} to #{new_status} (pending/in_progress: #{pending_or_in_progress})"
      update!(status: new_status)
    end
  end

  private

  def upcase_vin_and_plate
    self.vin = vin.upcase if vin.present?
    self.plate = plate.upcase if plate.present?
  end
end
