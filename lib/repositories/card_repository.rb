require 'mongo'

module Carmin
	class CardRepository
		def initialize(mongo_helper)
			@mongo_helper = mongo_helper
		end

		def card_in_repo?(url)
			puts url
            @mongo_helper.cards_collection.find({:source_url => "#{url}"}).first() != nil
        end

		def add_card(card)
			attributes = card.attributes
			attributes[:source_url] = get_url(card)
        	@mongo_helper.cards_collection.insert_one(attributes)
        end

        def update_card(card)
        	attributes = card.attributes
			attributes[:source_url] = get_url(card)
        	@mongo_helper.cards_collection.update_one({:source_url => "#{attributes[:source_url]}"}, attributes)
        end

        private

        def get_url(card)
            card.attachments.select{|att| att.name == "url"}.first.url
        end
	end
end