class Subdomain
  class << self
    def matches?(request)
      result = filter_slug_from_subdomain(request)
      return false if result == false
      true
    end

    def filter_slug_from_subdomain(request)
      url = request.host
      #use shop.domain
      shop = Shop.find_by_domain_and_validated_domain url, true
      return false if shop && shop.is_multipe_base_version?
      return shop if shop
      #use three level subdomain
      domain = Shop::REGEXDOMAIN.match request.host
      sub = request.host.gsub domain.to_s, ""
      return false unless sub.present?
      subs = sub.split "."
      return false if 1 == subs.length
      shop = Shop.find_by_slug subs.first
      return false if shop && shop.is_multipe_base_version?
      return shop if shop
      return false
    end
  end
end
