require './config/environment'
require 'rest-client'
class Import < Thor
 @@goods_categories = [
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

@@search_queries = [
  ['&keywords=xbox%20one', 'video-game-consoles'],
  ['&keywords=crackdown%203', 'video-games'],
  ['&keywords=halo%20reach',  'video-games'],
  ['&keywords=zoo%20tycoon',  'video-games'],
  ['&keywords=xbox%20gift%20card',  'video-games'],
  ['&keywords=elite%20controller',  'video-games-accessories'],
  ['&keywords=colon%20cancer',  'for-the-home'],
  ['&keywords=bikini%20line%20hair%20removal',  'health-and-beauty'],
  ['&keywords=public%20record%20office',  'collectibles'],
  ['&keywords=denture%20implants',  'health-and-beauty'],
  ['&keywords=denture%20implants&categoryId=267',  'health-and-beauty'],
  ['&keywords=senior&categoryId=15032',  'health-and-beauty'],
  ['&keywords=zombieland%20shirt',  't-shirts'],
  ['&keywords=greta%20thunberg%20shirt',  't-shirts'],
]

desc 'remove_expired_deals', 'A task to delete all stored deals that have expired'
  def remove_expired_deals
    # delete deals that have expired
    Deal.where('expiry_date < ?', Date.current).destroy_all
    log "[EBAY import:remove_expired_deals] Finished - #{Time.now}"
  end

  desc 'fetch', 'A task to fetch the latest deals from Ebay'
  def fetch
    log "[EBAY IMPORT:FETCH] Started - #{Time.now}"

    operation_name = "OPERATION-NAME=findItemsAdvanced"
    service_version = "&SERVICE-VERSION=1.0.0"
    security_appname = "&SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f"
    response_data_format = "&RESPONSE-DATA-FORMAT=JSON"
    entries_per_page = "&entriesPerPage=2"
    rest_payload = "&REST_PAYLOAD=true"
    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    @base_url = "#{url_start}#{operation_name}#{service_version}#{security_appname}#{response_data_format}#{rest_payload}#{entries_per_page}#{rest_payload}"
    @request_type = 'findItemsAdvancedResponse'
    @@search_queries.each do |query|
      @url = "#{@base_url}#{query[0]}"
      @category = query[1]
      send_ebay_request
    end

    operation_name = "OPERATION-NAME=findItemsByCategory"
    service_version = "&SERVICE-VERSION=1.0.0"
    security_appname = "&SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f"
    response_data_format = "&RESPONSE-DATA-FORMAT=JSON"
    entries_per_page = "&entriesPerPage=2"
    rest_payload = "&REST_PAYLOAD=true"
    params = "#{operation_name}#{service_version}#{security_appname}#{response_data_format}#{entries_per_page}#{rest_payload}"
    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    @base_url = "#{url_start}#{params}"

    @request_type = 'findItemsByCategoryResponse'
    @@goods_categories.each do |category|
      @url = "#{@base_url}&categoryId=#{category[1]}"
      @category = category
      send_ebay_request
    end

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
      @category[0],
      item['country'].first,
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
      sort_price,
      country_code)
    deal = Deal.find_or_initialize_by(deal_id: id)
    # get a higher quality image for the product
    # url = "http://open.api.ebay.com/shopping?ItemID=#{id}&callname=GetSingleItem&responseencoding=JSON&appid=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f&version=967"
    # image_json = ebay_send_url(url)
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
    deal[:rating] = rand < 0.2 ? 5 : 4
    deal[:sort_price] = sort_price
    deal[:country_code] = country_code
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
