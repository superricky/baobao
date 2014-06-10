class BranchSliderImageUploader < BaseImageUploader

  # Include RMagick or MiniMagick support:
  #include CarrierWave::RMagick
  #include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  #storage :azure
  # storage :fog

  after :store, :delete_old_tmp_file

  # remember the tmp file
  def cache!(new_file)
    super
    @old_tmp_file = new_file
  end

  def delete_old_tmp_file(dummy)
    @old_tmp_file.try :delete
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
     "branch_slider_#{secure_token}.#{File.extname(original_filename).downcase}" if original_filename.present?
  end

  version :medium do
    process :resize_to_fill => [720,400]
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

end
