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

        def get_cards_with_label(color, name)
            search_query = { "card_labels.name" => name }
            search_query["card_labels.color"] = color if !color.blank?
            retval = []
            @mongo_helper.cards_collection.find(search_query).projection({ :name => 1, :source_url => 1, :last_activity_date => 1}).each { |card| retval << card }
            retval.sort_by{|card| card['last_activity_date']}.reverse
        end

        def get_cards_in_category(name)
            search_query = { "desc.list_name" => name }
            retval = []
            @mongo_helper.cards_collection.find(search_query).projection({ :name => 1, :source_url => 1, :last_activity_date => 1}).each { |card| retval << card }
            retval.sort_by{|card| card['last_activity_date']}.reverse
        end

        private

        def get_url(card)
            card.attachments.select{|att| att.name == "url"}.first.url
        end
	end
end