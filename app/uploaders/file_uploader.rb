class FileUploader < CarrierWave::Uploader::Base
  # Private root path
  root Rails.root

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:

  def cache_dir
    "/uploads/tmp"
  end

  def store_dir
    "/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{get_last_dir_part}"
  end

  ## define how to partition directory
  def get_last_dir_part
    p = model.id.to_s.rjust(9, '0')
    "#{p[0,3]}/#{p[3,3]}/#{p[6,3]}"
  end

end
