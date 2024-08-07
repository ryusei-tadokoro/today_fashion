class ImageUploader < CarrierWave::Uploader::Base
  storage :fog

  if Rails.env.development? || Rails.env.test?
    storage :file
  else
    storage :fog
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    if model.is_a?(User)
      'default_image.png'
    elsif model.is_a?(Closet)
      'sample.png'
    else
      'default_image.png'
    end
  end
end
