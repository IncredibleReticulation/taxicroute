# assets.rb - Class to manage a hash of the mapping between assetIDs and card numbers

require "./config.rb"

class Assets
	attr_accessor :assetMap

	def initialize() 
		self.assetMap = []
	end

	def getCard(card)
		if h = assetMap.find { |h| h[:card] == card }
			h
		else
			return nil
		end
	end

	def checkMap(card, asset)
	
		assetHash = getCard(card);
		if(assetHash == nil)
			assetMap << {:card => card, :asset => asset}
			return true
		else if(assetHash[:asset] == asset)
			return true
		else
			return false
		end
		end
	end

end
