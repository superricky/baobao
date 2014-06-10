module Webstore::BranchesHelper
  def baidu_static_map_api
    "http://api.map.baidu.com/staticimage?width=340&height=200&center=&markers=#{@branch.longitude},#{@branch.latitude}&zoom=16&markerStyles=l,A,0xff0000"
  end
end
