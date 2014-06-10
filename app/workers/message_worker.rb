#encoding:utf-8
class MessageWorker
  include Sidekiq::Worker
  
  def perform(shop_id, url)
    shop = Shop.find(shop_id)
    PrivatePub.publish_to "/messages/shop/#{shop.slug}", :msg => {
        :title => "有新的客户留言",
        :content => "您的客户给您发来了留言，请尽快与客户进行联系哦",
        :link => url
    }
  end
end