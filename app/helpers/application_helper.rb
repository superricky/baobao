module ApplicationHelper
  def location_img(options={})
    "http://api.map.baidu.com/staticimage?center=#{options[:location_y]},#{options[:location_x]}&width=#{options[:width]}&height=#{options[:height]}&zoom=#{options[:zoom]}&markers=|#{options[:location_y]},#{options[:location_x]}|"
  end

  def geocode_ip_address(ip)
    if ip.nil? or ip.empty?
      "IP为空"
    else
      location =  Geokit::Geocoders::MultiGeocoder.geocode(ip, :language=>"zh")
      if location.nil?
        "未知位置"
      else
        location.city||location.state
      end
    end
  end
end
