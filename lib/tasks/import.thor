require './config/environment'
require 'rest-client'
class Import < Thor
 @@goods_categories = [
   ['xbox-one-games','54968'],
   ['video-game-manuals','182174'],
   ['video-game-strategy-guides','156595'],
  ['auto-and-home-improvement', '159907'],
  ['baby-kids-and-toys', '2984'],
  ['baby-kids-and-toys', '220'],
  %w[collectibles 1],
  %w[electronics 293],
  %w[electronics 9355],  # mobile phones
  %w[electronics 9394],  # cell phone accessories
  %w[electronics 178893], # smart watches
  ['entertainment-and-media', '11233'],
  ['entertainment-and-media', '11232'],
  ['entertainment-and-media', '1249'],
  ['for-the-home', '11700'],
  ['for-the-home', '159907'],
  ['groceries-household-and-pets', '1281'],
  ['health-and-beauty', '26395'],
  ['health-and-beauty', '110633'], # artisan jewellery
  ['jewelry-and-watches', '281'],
  ['mens-clothing-shoes-and-accessories', '1059'],
  ['mens-clothing-shoes-and-accessories', '93427'],
  ['mens-clothing-shoes-and-accessories', '4250'],
  ['sports-and-outdoors', '888'],
  ['womens-clothing-shoes-and-accessories', '4251'],
  ['womens-clothing-shoes-and-accessories', '15724'],
  ['womens-clothing-shoes-and-accessories', '3034']
]

# ['&keywords=crackdown%203', 'video-games'],
# ['&keywords=halo%20reach',  'video-games'],
# ['&keywords=zoo%20tycoon',  'video-games'],
# ['&keywords=skyrim', 'video-games'],
@@search_queries = [
  ['xbox-one-accessories', '&keywords=xbox%20one%20accessories'],
  ['xbox-one-controller', '&keywords=xbox%20one%20controller'],
  ['xbox-live-gold', '&keywords=xbox%20live%20gold%20months'],
  ['xbox-one-game-manuals', '&keywords=xbox%20one%20game%20manuals'],
  ['xbox-one-strategy-guides', '&keywords=xbox%20one%20strategy%20guides'],
  ['video-games', '&keywords=xbox%20one%20games'],
  ['video-game-consoles','&keywords=xbox%20one'],
  ['video-games','&keywords=xbox%20gift%20card'],
  ['video-games-accessories','&keywords=elite%20controller'],
  ['for-the-home','&keywords=colon%20cancer'],
  ['health-and-beauty','&keywords=bikini%20line%20hair%20removal'],
  ['collectibles','&keywords=public%20record%20office'],
  ['health-and-beauty','&keywords=denture%20implants'],
  ['health-and-beauty','&keywords=denture%20implants&categoryId=267'],
  ['health-and-beauty','&keywords=senior&categoryId=15032'],
  ['t-shirts','&keywords=zombieland%20shirt'],
  ['t-shirts','&keywords=greta%20thunberg%20shirt'],
]

desc 'remove_expired_deals', 'A task to delete all stored deals that have expired'
  def remove_expired_deals
    # delete deals that have expired
    Deal.where('expiry_date < ?', Date.current).destroy_all
    log "[EBAY import:remove_expired_deals] Finished - #{Time.now}"
  end

  desc 'fetch', 'A task to fetch the latest deals from Ebay'
  def fetch
    # we will delete deals that are not pulled in by this fetch
    deals = Deal.all
    deals.update(new: false)
    log "[EBAY IMPORT:FETCH] Started - #{Time.now}"
    service_version = "&SERVICE-VERSION=1.0.0"
    security_appname = "&SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f"
    response_data_format = "&RESPONSE-DATA-FORMAT=JSON"
    entries_per_page = "&entriesPerPage=2"
    rest_payload = "&REST_PAYLOAD=true"
    tracking_id = "trackingId=5338584772"
    shared = "#{service_version}#{security_appname}#{response_data_format}#{entries_per_page}#{rest_payload}#{tracking_id}"

    operation_name = "OPERATION-NAME=findItemsAdvanced"

    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    @base_url = "#{url_start}#{operation_name}#{shared}"
    @request_type = 'findItemsAdvancedResponse'
    @@search_queries.each do |query|
      @url = "#{@base_url}#{query[1]}"
      @category = query[0]
      send_ebay_request
    end
    
    operation_name = "OPERATION-NAME=findItemsByCategory"

    params = "#{operation_name}#{shared}"
    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    @base_url = "#{url_start}#{params}"

    @request_type = 'findItemsByCategoryResponse'
    @@goods_categories.each do |category|
      @url = "#{@base_url}&categoryId=#{category[1]}"
      @category = category[0]
      send_ebay_request
    end
    deals.where(new: false).destroy_all
    log "[EBAY IMPORT:FETCH] Finished - #{Time.now}"
  end

  private

  def ebay_send_url(url)
    begin
      response = RestClient.get(url)
    rescue RestClient::BadRequest => e
      log "Error: #{e}"
      return nil
    end
    JSON.parse(response.body)
  end

  def send_ebay_request
    json = ebay_send_url @url
    @ebay_items = json[@request_type][0]['searchResult'].first['item']
    @ebay_items.each do |item|
      extract_json(item)
    end
  end

  def extract_json item
    return unless item['galleryURL'].present? # some deals don't have images uploaded by the seller
    save_deal(
      "ebay_#{item['itemId'].first}",
      item['galleryURL'].first,
      item['title'].first,
      '',
      format('$%2.2f', item['sellingStatus'][0]['currentPrice'][0]['__value__']),
      item['listingInfo'].first['endTime'][0],
      item['viewItemURL'].first,
      @category,
      item['country'].first,
      item['topRatedListing'][0],
      item['sellingStatus'][0]['currentPrice'][0]['__value__'],
      item['country'].first
    )
  end

    # fetched deal either is saved to database or replaces existing deal
    def save_deal(id,
      image_url,
      title,
      highlights,
      price,
      expiry_date,
      url,
      category,
      division,
      rating,
      sort_price,
      country_code)
    deal = Deal.find_or_initialize_by(deal_id: id)
    deal[:image_url] = image_url
    deal[:title] = title
    deal[:highlights] = highlights
    deal[:price] = price
    # some deals don't seem to have an expiry so we need to allow for this
    return if expiry_date == '' || expiry_date.nil?
    deal[:expiry_date] = expiry_date
    deal[:url] = url
    deal[:category] = category
    deal[:division] = division
    deal[:rating] = rating
    deal[:sort_price] = sort_price
    deal[:country_code] = country_code
    deal.new = true
    deal.save!
    category = Category.find_or_initialize_by(slug: category)
    category.save!
  end

    # output to console
    def log(info)
      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO
      Rails.logger = logger
      logger.info info
    end
end
