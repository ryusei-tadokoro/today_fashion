# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[line]

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :prefecture
  belongs_to :second_prefecture, class_name: 'Prefecture', optional: true
  belongs_to :constitution
  has_many :closets, dependent: :destroy

  mount_uploader :image, ImageUploader

  validates :name, presence: true, if: -> { validation_context == :step1 }
  validates :email, presence: true, if: -> { validation_context == :step1 }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { validation_context == :step1 }
  validates :password_confirmation, presence: true, if: -> { validation_context == :step1 }

  def default_image
    ActionController::Base.helpers.asset_path('default_image.png')
  end

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  def self.from_omniauth(auth)
    user = find_or_initialize_user(auth)
    update_user_attributes(user, auth)
    user.save
    user
  end

  def admin?
    true
  end

  class << self
    private

    def find_or_initialize_user(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_initialize
    end

    def update_user_attributes(user, auth)
      user.email = extract_email(auth)
      user.password = Devise.friendly_token[0, 20] if user.new_record?
      user.name = auth.info.name
    end

    def extract_email(auth)
      auth.info.email || "#{auth.uid}-#{auth.provider}@example.com"
    end
  end
end
