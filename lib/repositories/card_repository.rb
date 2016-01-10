require 'mongo'

module Carmin
	class CardRepository
		def initialize(mongo_helper)
			@mongo_helper = mongo_helper
		end

		def card_in_repo?(name)
            @mongo_helper.cards_collection.find({:name => "#{name}"}).first() != nil
        end

		def add_card(card)
        	@mongo_helper.cards_collection.insert_one(card.attributes)
        end
	end
end