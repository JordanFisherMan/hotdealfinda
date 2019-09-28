require './config/environment'
require 'rest-client'
class Import < Thor
 @@goods_categories = [
  ['auto-and-home-improvement', '34998'],
  ['auto-and-home-improvement', '43983'], # Tire Deals
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
  ['groceries-household-and-pets', '66780'],  # dog food
  ['groceries-household-and-pets', '63073'],  # cat food
  ['health-and-beauty', '26395'],
  ['health-and-beauty', '31413'], # Hair loss treatments
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

@@travel_categories = [
  ['cruise-travel', '16078'],
  ['tour-travel', '3256'], # vacation packages with air
  ['tour-travel', '29578'], # vacation packages without air
  ['hotels-and-accommodations', '164802'], # campground and rv parks
  ['hotels-and-accomodations', '16123'] # lodging
]

@@search_queries = [
  ['&keywords=colon%20cancer&categoryId=1059', 'goods', 'for-the-home'],
  ['&keywords=bikini%20line%20hair%20removal', 'goods', 'health-and-beauty'],
  ['&keywords=public%20record%20office', 'goods', 'collectibles'],
  ['&keywords=denture%20implants', 'goods', 'health-and-beauty'],
  ['&keywords=denture%20implants&categoryId=267', 'goods', 'health-and-beauty'],
  ['&keywords=senior&categoryId=15032', 'goods', 'health-and-beauty']
]

desc 'remove_expired_deals', 'A task to delete all stored deals that have expired'
  def remove_expired_deals
    # delete deals that have expired
    Deal.where('expiry_date < ?', Date.current).destroy_all
  end

  desc 'fetch', 'A task to fetch the latest deals from Ebay'
  def fetch
    operation_name = "OPERATION-NAME=findItemsByCategory"
    tracking_id = "&trackingId=5338584772"
    service_version = "&SERVICE-VERSION=1.0.0"
    security_appname = "&SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f"
    response_data_format = "&RESPONSE-DATA-FORMAT=JSON"
    entries_per_page = "&entriesPerPage=2"
    rest_payload = "&REST_PAYLOAD"
    output_selector = "&outputSelector=PictureURLLarge"
    params = "#{operation_name}#{tracking_id}#{service_version}#{security_appname}#{response_data_format}#{entries_per_page}#{rest_payload}#{output_selector}"
    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    @base_url = "#{url_start}#{params}"
    log "[EBAY IMPORT:FETCH] Started - #{Time.now}"
    @request_type = 'findItemsByCategoryResponse'
    @@goods_categories.each do |category|
      @url = "#{@base_url}&categoryId=#{category[1]}"
      @channel = 'goods'
      @category = category
      send_ebay_request
    end

    @@travel_categories.each do |category|
      @url = "#{@base_url}&categoryId=#{category[1]}"
      @channel = 'travel'
      @category = category
      send_ebay_request
    end
    @base_url = 'https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD=true'
    @request_type = 'findItemsAdvancedResponse'
    @@search_queries.each do |query|
      @url = "#{@base_url}#{query[0]}"
      @channel = query[1]
      @category = query[2]
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
      @channel,
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
      channel,
      division,
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
    deal[:channel] = channel
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
