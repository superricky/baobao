require 'file_size_validator'
class Ckeditor::Picture < Ckeditor::Asset
  mount_uploader :data, CkeditorPictureUploader, :mount_on => :data_file_name
  validates :data, :file_size => { :maximum => 0.5.megabytes.to_i }
  def url_content
    url(:content)
  end
end
