desc "interior set the winners"
task :set_promotion_winners, [:article_id] =>  :environment do |t, args|
  users = get_users
  article = Article.find(args[:article_id]) rescue nil
  if article
    shop = article.shop
    users.sample(3).each do |user|
      shop.users.find_or_create_by(fake_user_name: user[1], name: user[0])
      max_count = (get_promotion_logs_hash(article).values.max rescue 0).to_i
      user_count = (get_promotion_logs_hash(article)[user[1]] rescue 0).to_i
      balance = [max_count, user_count].max
      if balance > 0
        (balance + Random.rand(10) + 5).times do
          add_promotion_logs(article, user[1], user[0])
        end
      else
        (Random.rand(10) + 5).times do
          add_promotion_logs(article, user[1], user[0])
        end
      end
    end
  end
end

def add_promotion_logs(article, sharer, sharer_nickname)
  shop = article.shop
  browser = get_fake_user_name
  if !shop.promotion_logs.find_by(article: article, browser: browser).present?
    browser_nickname = nil
    shop.promotion_logs.create!(
      article: article,
      sharer: sharer,
      sharer_nickname: sharer_nickname,
      browser: browser,
      browser_nickname: browser_nickname
      )
  end
end

def get_users
  file_path = "lib/tasks/winners.json"
  if File::exists?(file_path)
    JSON.parse(File.read(file_path)).to_a
  else
    nicknames = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j","k", "l", "m", "n", "o", "p", "q", "r", "s", "t"]
    users = []
    nicknames.each do |name|
      users << [name, get_fake_user_name]
    end
    File.open(file_path,"w") do |f|
      f.write(Hash[users].to_json)
    end
    users
  end
end

def get_fake_user_name
  arr = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split("")
  strs = []
  26.times.each do
    strs << arr.sample
  end
  strs.insert((Random.rand(26) + 1), "**").join("")
end

def get_promotion_logs_hash(article)
  Hash[article.promotion_logs.all.group_by{|p| p.sharer}.sort_by{|k, v| v.length}.map{|a| [a[0], a[1].size]}]
end