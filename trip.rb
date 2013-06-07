# trip.rb - Class to represent a trip between two addresses, as well as perform some related functions

require "./config.rb"
require "json"

class Trip
	NotImplemented = Class.new(StandardError)
	InvalidAddress = Class.new(StandardError)

	attr_accessor :mileage

	def initialize(sAddr,dAddr,autoroute=true)

		@sLat = sAddr.latitude
		@sLon = sAddr.longitude

		@dLat = dAddr.latitude
		@dLon = dAddr.longitude


		if(autoroute)
			route!
		end

	end

	def route!
		startArgs = "&flat=#{@sLat}&flon=#{@sLon}"
		destArgs = "&tlat=#{@dLat}&tlon=#{@dLon}"
		@gosmore_raw = open(Appdata.gosmore_endpoint+Appdata.gosmore_options+startArgs+destArgs).read
		@gosmore = JSON.parse! @gosmore_raw
		@mileage = String((Float(@gosmore["properties"]["distance"])*0.621371).round(Appdata.round)) #Convert kilometers to miles
	end
end

