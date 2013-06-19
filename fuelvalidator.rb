#!/usr/bin/env ruby -wKU

# fuelvalidator - a simple program to spot anomolies in fuel usage
# Licensed under the MIT license. See LICENSE for full license text
# Copyright 2013

require "open-uri"
require "rubygems"
require "colorize"
require "csv"

require "./config.rb"
require "./address.rb"
require "./trip.rb"
require "./assets.rb"



Appdata.config do
  parameter :muni
  parameter :nominatim_endpoint
  parameter :nominatim_options
  parameter :gosmore_endpoint
  parameter :gosmore_options
  parameter :debug
  parameter :round
  parameter :stationDistanceThresh
  parameter :authorizedFuelCodes
  parameter :sAddrGeo
end

Appdata.config do
	muni 'Rochester'
	nominatim_endpoint 'http://nominatim.openstreetmap.org/search/'
	nominatim_options '?format=json&addressdetails=1'
	gosmore_endpoint 'http://www.yournavigation.org/api/1.0/gosmore.php'
	gosmore_options '?geometry=0&v=motorcar&fast=1&format=geojson&layer=mapnik'
	debug 'false'
	round 0
	stationDistanceThresh 1
	authorizedFuelCodes ["UNL", "ETH"]
	sAddrGeo Address.new "Rochester, NY"
end

def checkFuel(type)
	Appdata.authorizedFuelCodes.each{ |authorizedCode|
		if authorizedCode == type
			return true
		end
	}
	return false
end

csv_data = CSV.read ARGV[0]
headers = csv_data.shift.map {|i| i.to_s }
string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
fillups = string_data.map {|row| Hash[*headers.zip(row).flatten] }
assets = Assets.new
previousAddr = ""
previousAddrGeo = nil
previousAddrFail = false

fillups.each { |fillup|
	
	puts "#{fillup['Transaction Date']} @ #{fillup['Transaction Time']} - #{fillup['Custom Vehicle/Asset ID']} bought #{fillup['Units']} of #{fillup['Product Description']} for #{fillup['Total Fuel Cost']}".green
	#check card user
	if(! assets.checkMap(fillup['Card Number'],fillup['Custom Vehicle/Asset ID']) )
		puts "\tCard #{fillup['Card Number']} used by #{fillup['Driver Last Name']}, #{fillup['Driver First Name']}, which does not match card owner (#{assets.getCard(fillup['Card Number'])[:asset]}).".red
	end
	#check fuel type
	if(! checkFuel(fillup['Product']))
		puts "\tProduct was #{fillup['Product Description']} (#{fillup['Product']}), which is not an authorized fuel type.".red
	end
	#check station distance to rochester
	fail = false
	begin
		sAddrGeo = Appdata.sAddrGeo;
	rescue
		fail = true
	end
	dAddr = fillup['Merchant Address']+" "+fillup['Merchant City']+" "+fillup['Merchant State / Province']
	if(previousAddr == dAddr)
		dAddrGeo = previousAddrGeo
		fail = previousAddrFail
	else
		begin
			previousAddr = dAddr
			dAddrGeo = Address.new dAddr
			previousAddrGeo = dAddrGeo
			previousAddrFail = false
		rescue
			previousAddrFail = true
			fail = true
		end
	end
	if(!fail)
		if(!dAddrGeo.municipality?)
			trip = Trip.new(sAddrGeo,dAddrGeo)
			if(Integer(trip.mileage) > Appdata.stationDistanceThresh)
				puts "\tStation (#{fillup['Merchant Address']+" "+fillup['Merchant City']+" "+fillup['Merchant State / Province']}) was above distance threshold! [#{trip.mileage}]".blue
			end
		end
	else
		puts "\tFailed to geocode station (#{fillup['Merchant Address']+" "+fillup['Merchant City']+" "+fillup['Merchant State / Province']}) for distance check.".yellow
	end
	#trip data?
}

#puts fillups.to_json;

