namespace :aliyun do
  prefix = "http://portalvhds9gwr2bscx8z2.blob.core.chinacloudapi.cn/development-container/uploads"
  desc "migrate pictures from azure to aliyun oos"
  task :migrate_image => :environment do
    migrate_product_image(prefix)
  end

  task :migrate_shop => :environment do
    migrate_shop_image(prefix)
    migrate_promotion_image(prefix)
    migrate_product_slider(prefix)
    migrate_ckeditor_picture(prefix)
    migrate_attachment_file(prefix)
    migrate_branch_slider(prefix)
    migrate_base_branch(prefix)
    migrate_article_image(prefix)
  end

  def migrate_product_image(prefix)
    puts "welcome to migrate image"
    count = 0
    Product.where("pic is NOT NULL").each do |product|
      url = "#{prefix}/#{product.pic}"
      count += 1
      puts "migrate the #{count} product #{product.id} #{product.name} #{url}" if count%10 == 0
      begin
        image = ProductImageUploader.new
        image.download! url
        product.update_attribute(:image, image)
      rescue =>e
        puts  "product #{product.id}: #{e.message}"
      end
    end
  end

  def migrate_shop_image(prefix)
    puts "welcome to migrate shop image"
    Shop.where("qrcode is NOT NULL or image is NOT NULL").each do |shop|
      qrcode_url = shop.read_attribute(:qrcode)
      image_url = shop.read_attribute(:image)
      if qrcode_url.present?
        begin
          url = [prefix, qrcode_url].join("/")
          qrcode = ShopQrcodeUploader.new
          qrcode.download! url
          shop.update_attribute(:qrcode, qrcode)
        rescue =>e
          puts "failed to upload qrcode for shop #{shop.id}: #{e.message}"
        end
      end

      if image_url.present?
        begin
          url = [prefix, image_url].join("/")
          image = ShopImageUploader.new
          image.download! url
          shop.update_attribute(:image, image)
        rescue =>e
          puts "failed to upload image for shop #{shop.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_promotion_image(prefix)
    puts "welcome to migrate promotion image"
    Promotion.where("image is NOT NULL").each do |promotion|
      image_url = promotion.read_attribute(:image)
      if image_url.present?
        begin
          url = [prefix, image_url].join("/")
          image = PromotionImageUploader.new
          image.download! url
          promotion.update_attribute(:image, image)
        rescue =>e
          puts "failed to upload image for promotion #{promotion.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_product_slider(prefix)
    puts "welcome to migrate product_slider image"
    ProductSlider.where("img is NOT NULL").each do |product_slider|
      image_url = product_slider.read_attribute(:img)
      if image_url.present?
        begin
          url = [prefix, image_url].join("/")
          image = ProductSliderImageUploader.new
          image.download! url
          product_slider.update_attribute(:img, image)
        rescue =>e
          puts "failed to upload img for product_slider #{product_slider.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_ckeditor_picture(prefix)
    puts "welcome to migrate ckeditor image"
    Ckeditor::Picture.where("data_file_name is NOT NULL").each do |picture|
      image_url = picture.read_attribute(:data_file_name)
      if image_url.present?
        begin
          url = [prefix, "ckeditor/pictures/#{picture.id}/#{image_url}"].join("/")
          data = CkeditorPictureUploader.new
          data.download! url
          picture.update_attribute(:data, data)
        rescue =>e
          puts "failed to upload image for ckeditor picture #{picture.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_attachment_file(prefix)
    puts "welcome to migrate attachment file"
     Ckeditor::AttachmentFile.where("data_file_name is NOT NULL").each do |attachment|
      file_url = attachment.read_attribute(:data_file_name)
      if file_url.present?
        begin
          url = [prefix, "ckeditor/attachments/#{attachment.id}/#{file_url}"].join("/")
          data = CkeditorAttachmentFileUploader.new
          data.download! url
          attachment.update_attribute(:data, data)
        rescue =>e
          puts "failed to upload attachment for ckeditor attachment #{attachment.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_branch_slider(prefix)
    puts "welcome to migrate branch slider image"
    BranchSlider.where("img is NOT NULL").each do |branch_slider|
      image_url = branch_slider.read_attribute(:img)
      if image_url.present?
        begin
          url = [prefix, image_url].join("/")
          image = BranchSliderImageUploader.new
          image.download! url
          branch_slider.update_attribute(:img, image)
        rescue =>e
          puts "failed to upload img for branch_slider #{branch_slider.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_base_branch(prefix)
    puts "welcome to migrate base branch image"
    BaseBranch.where("image is NOT NULL").each do |base_branch|
      image_url = base_branch.read_attribute(:image)
      if image_url.present?
        begin
          url = [prefix, image_url].join("/")
          image = BranchImageUploader.new
          image.download! url
          base_branch.update_attribute(:image, image)
        rescue =>e
          puts "failed to upload image for base_branch #{base_branch.id}: #{e.message}"
        end
      end
    end
  end

  def migrate_article_image(prefix)
    puts "welcome to migrate artcile image"
    Article.where("image is NOT NULL").each do |article|
      image_url = article.read_attribute(:image)
      if image_url.present?
        begin
          url = [prefix, image_url].join("/")
          image = ArticleImageUploader.new
          image.download! url
          article.update_attribute(:image, image)
        rescue =>e
          puts "failed to upload image for article #{article.id}: #{e.message}"
        end
      end
    end
  end
end
