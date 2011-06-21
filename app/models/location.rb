# Geokit::Geocoders::google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
class Location < ActiveRecord::Base

  def self.geocode(q)
    location = Location.find_or_create_by_parameters(q)
    # geo = Geokit::Geocoders::GoogleGeocoder.geocode(params[:address])
    # response = geo.response
    response = Net::HTTP.get URI.parse("http://maps.googleapis.com/maps/api/geocode/json?#{q}")
    location.cached_response = response
    location.updated_at = Time.now
    location.save!
    return location
  end

  def to_json(with_timestamp=true)
    json = ActiveSupport::JSON.decode(self.cached_response)
    if with_timestamp && json
      # Inject timestamp
      json['timestamp'] = self.updated_at
    end
    json
  end
end
