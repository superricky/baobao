require 'file_size_validator'
class Ckeditor::AttachmentFile < Ckeditor::Asset
  mount_uploader :data, CkeditorAttachmentFileUploader, :mount_on => :data_file_name
  validates :data, :file_size => { :maximum => 0.5.megabytes.to_i }
  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
