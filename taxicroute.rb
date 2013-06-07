#!/usr/bin/env ruby -wKU

# taxicroute - a simple program to calculate costs for taxicab fares, as well as inner- and intra-city routes.
# Licensed under the MIT license. See LICENSE for full license text
# Copyright 2013

require "./config.rb"
require "./address.rb"
require "./trip.rb"

require "open-uri"
require "rubygems"
require "colorize"

Appdata.config do
  parameter :muni
  parameter :nominatim_endpoint
  parameter :nominatim_options
  parameter :gosmore_endpoint
  parameter :gosmore_options
  parameter :debug
  parameter :round
end

Appdata.config do
	muni 'Rochester'
	nominatim_endpoint 'http://nominatim.openstreetmap.org/search/'
	nominatim_options '?format=json&addressdetails=1'
	gosmore_endpoint 'http://www.yournavigation.org/api/1.0/gosmore.php'
	gosmore_options '?geometry=0&v=motorcar&fast=1&format=geojson&layer=mapnik'
	debug 'false'
	round 2
end

inCity = 0
outCity = 0
totalOutMileage = Float(0)

File.readlines(ARGV[0]).each do |line|

	tripInfo = line.split ','

	sAddr = tripInfo[4]+" "+tripInfo[5]+" "+tripInfo[6].strip
	sAddrGeo = Address.new sAddr
	dAddr = tripInfo[7]+" "+tripInfo[8]+" "+tripInfo[9].strip
	dAddrGeo = Address.new dAddr
	sAddrState = sAddrGeo.municipality? ? "In-City" : "Out-City"
	dAddrState = dAddrGeo.municipality? ? "In-City" : "Out-City"
	output = sAddr+" (#{sAddrState}) <-> "+dAddr+" (#{dAddrState})"
	if(sAddrState == "In-City" and dAddrState == "In-City")
		trip = :in
	else
		trip = :out
	end

	if(trip == :in)
		puts output.green
		inCity += 1
	else
		tripMetric = Trip.new(sAddrGeo,dAddrGeo)
		print output.red
		puts ("["+tripMetric.mileage+"]").blue
		totalOutMileage += Float(tripMetric.mileage)
		outCity += 1
	end


end

puts "         Inner-City Trips: #{inCity}"
puts "        Out-of-City Trips: #{outCity}"
puts "Total out-of-city Mileage: #{totalOutMileage}"