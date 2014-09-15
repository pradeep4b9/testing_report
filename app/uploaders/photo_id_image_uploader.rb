# encoding: utf-8
require "digest/md5"
class PhotoIdImageUploader < CarrierWave::Uploader::Base

  # Include CarrierWave direct uploader to background upload task.
  # include CarrierWaveDirect::Uploader
  include ::CarrierWave::Backgrounder::Delay
  
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  include CarrierWave::MimeTypes

  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

  # store! nil's the cache_id after it finishes so we need to remember it for deletion
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
  end

  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    if @cache_id_was.present? && @cache_id_was =~ /\A[\d]{8}\-[\d]{4}\-[\d]+\-[\d]{4}\z/
      FileUtils.rm_rf(File.join(root, cache_dir, @cache_id_was))
    end
  end
  
  process :set_content_type
  #process resize_to_fill: [640, 480]
  #process :resize_to_fit => [640, 480]
  #process :quality => 100
  # process :stamp
  process :convert => 'jpg'
  

  version :thumb do
    process :resize_to_fill => [300,300]
  end

  version :small do
    process :resize_to_fill => [150,150]
  end

  # Choose what kind of storage to use for this uploader:
  #storage :file
  storage :fog

  def store_dir
    "development_uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def full_filename (for_file = model.image.file)
    super.chomp(File.extname(super)) + '.jpg'
  end

  def fog_public
    false
  end

  def fog_authenticated_url_expiration
    4.minutes # in seconds from now,  (default is 10.minutes)
  end

  # def quality(percentage)
  #     manipulate! do |img|
  #     img.write(current_path){ self.quality = percentage } unless img.quality == percentage
  #     img = yield(img) if block_given?
  #     img
  #   end
  # end

  # def stamp
  # manipulate! do |img|
  # stamp_path = File.join("app", "assets","images", "black-seal.png")
  # if File.exists?(stamp_path) # use existing stamp image
  # stamp_image = Magick::Image.read(stamp_path).first
  # img.composite!(stamp_image, Magick::SouthEastGravity, Magick::OverCompositeOp) # Other Gravities: SouthEastGravity, NorthGravity(centered), etc.
  # else # no existing stamp image, generate one from text
  # logger.error("No Stamp Found: #{stamp_path}")
  # end
  # end
  # end


  # # Add a white list of extensions which are allowed to be uploaded.
  # # Override the filename of the uploaded files:
  # # see http://huacnlee.com/blog/carrierwave-upload-store-file-name-config/
  # def filename
  # if super.present?
  # # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
  # @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
  # "#{@name}.#{file.extension.downcase}"
  # end
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  
  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  # # For Rails 3.1+ asset pipeline compatibility:
  # # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  # # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  # process :scale => [50, 50]
  # end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  # "something.jpg" if original_filename
  # end

  # after :store, :delete_old_tmp_file
  # remember the tmp file
  # def cache!(new_file)
  # super
  # @old_tmp_file = new_file
  # end
  
  # def delete_old_tmp_file(dummy)
  # @old_tmp_file.try :delete
  # end

end