# frozen_string_literal: true

class PartnerLogoUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w(jpg jpeg gif png svg tiff)
  end

  def default_url(*args)
    ActionController::Base.helpers.asset_path('' + [version_name, 'placeholder.png'].compact.join('_'))
  end

  version :unmodified

  # This is just for active admin
  version :original do
    process resize_to_fill: [80, 80]
  end

  def exists?
    file.present?
  end

  def original_filename
    if file.present?
      file.filename
    else
      super
    end
  end
end
