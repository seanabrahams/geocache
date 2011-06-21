require 'test_helper'
require 'net/http'
require 'uri'

class LocationsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "geocoding parameters" do
    get :geocode, { :address => "1600 Amphitheatre Parkway, Mountain View, CA", :sensor => "false" }

    assert_response :success
  end

  test "goog vs us" do
    google_response = Net::HTTP.get URI.parse('http://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&sensor=false')
    our_response = Location.geocode('address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&sensor=false')
    
    assert_equal our_response.to_json(with_timestamp=false), ActiveSupport::JSON.decode(google_response)
  end

  test "caching" do
    get :geocode, { :address => "1600 Amphitheatre Parkway, Mountain View, CA", :sensor => "false" }

    first_hit = assigns(:location)
    created_at = first_hit.created_at
    updated_at = first_hit.updated_at

    sleep 1 

    get :geocode, { :address => "1600 Amphitheatre Parkway, Mountain View, CA", :sensor => "false" }

    assert_equal first_hit.created_at.to_s, assigns(:location).created_at.to_s

    sleep 1

    get :geocode, { :address => "1600 Amphitheatre Parkway, Mountain View, CA", :sensor => "false", :expire => "true" }

    assert_not_equal updated_at, assigns(:location).updated_at
    first_hit.reload
    assert_not_equal updated_at, first_hit.updated_at
  end

  test "response includes timestamp" do
    get :geocode, { :address => "1600 Amphitheatre Parkway, Mountain View, CA" }

    assert ActiveSupport::JSON.decode(response.body).has_key?("timestamp")
  end
end
