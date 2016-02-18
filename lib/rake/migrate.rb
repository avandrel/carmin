module Carmin
	class Migrate
		def initialize
		    @config_hash = Carmin::Config.get_config_hash

		    mongo_helper = Carmin::MongoHelper.new @config_hash
			card_repository = Carmin::CardRepository.new mongo_helper

			cards = card_repository.get_cards_descriptions()
			
			cards.select{|card| card['desc']['list_name'].blank?}.each do |card|
				desc = card['desc']
				desc = JSON.parse(desc)
				desc['list_name'] = "KOSZ"
				card['desc'] = desc.to_json
				card['_id'] = nil
				puts card
				card_repository.remove(card['short_id'])
				card_repository.add(card)
			end
		end
	end
end	