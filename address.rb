# address.rb - Class to represent a single street address, as well as perform some related functions

require "./config.rb"
require "json"
require "colorize"

class Address
	NotImplemented = Class.new(StandardError)
	InvalidAddress = Class.new(StandardError)
	GeocodeFailed  = Class.new(StandardError)

	attr_accessor :streetAddress, :latitude, :longitude, :geocode

	def initialize(streetAddress,autoGeocode=true)
		@streetAddress = streetAddress
		if(autoGeocode)
			geocode!
		end
	end

	def geocode!
		

		if @streetAddress == "" or @streetAddress == nil
			raise InvalidAddress
		end


		@nominatim_raw = open(Appdata.nominatim_endpoint+URI::encode(@streetAddress)+Appdata.nominatim_options).read


		if @nominatim_raw == "[]"
			raise GeocodeFailed
		end

		@geocode = JSON.parse!(@nominatim_raw).first
		@latitude = @geocode["lat"]
		@longitude = @geocode["lon"]

		@geocode

	end

	def municipality?
		#TODO check whether address is part of municipality
		
		@geocode["address"].each { |addressFragment|
			if(Appdata.debug == 'true')
				puts "#{addressFragment} <-> #{Appdata.muni}"
			end

			if(addressFragment.last == Appdata.muni)
				return true
			end
		}
		return false
	end


end