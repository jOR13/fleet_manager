class User < ApplicationRecord
  has_secure_password

  enum role: { admin: "admin", manager: "manager", operator: "operator" }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :role, presence: true

  before_save :downcase_email

  scope :by_role, ->(role) { where(role: role) if role.present? }

  def generate_jwt_token
    payload = {
      user_id: id,
      email: email,
      role: role,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def self.decode_jwt_token(token)
    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base).first
      find(decoded["user_id"])
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      nil
    end
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
