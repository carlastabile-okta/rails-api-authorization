require 'net/http'
require 'pry'

class OpenfgaService
  def initialize()
  end

  # curl -X POST $FGA_API_URL/stores \
  # -H "content-type: application/json" \
  # -d '{"name": "FGA Demo Store"}'
  def create_store
    uri = URI("#{ENV['FGA_API_URL']}/stores")
    header = {'Content-Type': 'application/json'}
    body = { name: "#{ENV['STORE_NAME']}" }
    
    http = Net::HTTP.new(uri.host,uri.port)
    req = Net::HTTP::Post.new(uri.path, header)
    req.body = body.to_json 
    
    res = http.request(req)
    Rails.cache.write("store_id", JSON.parse(res.body)["id"])
  end

  def create_authorization_model
  end

  def check_if(entity1, relation, entity2)
  end
end