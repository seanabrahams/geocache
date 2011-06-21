class LocationsController < ApplicationController

  def geocode
    q = request.query_string.gsub("&expire=true",'')

    # require 'ruby-debug'
    # Debugger.start
    # debugger

    if params[:expire]
      @location = Location.geocode(q)
      render :json => @location.to_json
    else
      # Check Cache
      if @location = Location.find_by_parameters(q)
        render :json => @location.to_json
      else
        # Geocode it
        @location = Location.geocode(q)
        render :json => @location.to_json
      end
    end
  end

end
