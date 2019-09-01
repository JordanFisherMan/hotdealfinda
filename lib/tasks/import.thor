require './config/environment'
require 'rest-client'
class Import < Thor
  desc 'fetch', 'Fetches deals from Ebay'
  def fetch
    operation_name = "OPERATION-NAME=findItemsByCategory&"
    service_version = "SERVICE-VERSION=1.0.0&"
    security_appname = "SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f&"
    response_data_format = "RESPONSE-DATA-FORMAT=JSON&"
    category_id = "categoryId=118255&"
    entries_per_page = "entriesPerPage=2&"
    rest_payload = "REST_PAYLOAD"
    params = "#{operation_name}#{service_version}#{security_appname}#{response_data_format}#{category_id}#{entries_per_page}#{rest_payload}"
    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    url = "#{url_start}#{params}"
    puts url
    begin
      response = RestClient.get(url)
    rescue RestClient::BadRequest => e
      log "Error: #{e}"
      return nil
    end
    puts JSON.parse(response.body)
  end
end
