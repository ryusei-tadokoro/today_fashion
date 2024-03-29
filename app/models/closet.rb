# frozen_string_literal: true

class Closet < ApplicationRecord
  mount_uploader :image, ImageUploader
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :subcategory, optional: true

  validates :name, presence: true
  def default_image
    ActionController::Base.helpers.asset_path('sample.png')
  end

  def image_url
    image.present? ? image.url : default_image
  end
end
