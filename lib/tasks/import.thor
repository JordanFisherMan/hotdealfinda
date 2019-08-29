require './config/environment'
require 'rest-client'
class Import < Thor
  desc 'fetch', 'Fetches deals from Ebay'
  def fetch
    url = "https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByCategory&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&categoryId=10181&paginationInput.entriesPerPage=2"
    params = {
      operation_name: "OPERATION-NAME=findItemsByCategory",
      service_version:"SERVICE-VERSION=1.0.0",
      app_id:"SECURITY-APPNAME=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f",
      response_data_format: "RESPONSE-DATA-FORMAT=JSON",
      category_id:"categoryId=10181",
      pagination_input:"paginationInput.entriesPerPage=2"
    }
    url_start = "https://svcs.ebay.com/services/search/FindingService/v1?"
    url = "#{url_start}#{params.to_query}"
    puts url
  end
end
