module Carmin
	class Migrate
		def initialize
		    @config_hash = Carmin::Config.get_config_hash
		    mongo_helper = Carmin::MongoHelper.new @config_hash
			@card_repository = Carmin::CardRepository.new mongo_helper
		end

		def migrate_labels
		    

			cards = @card_repository.get_cards_from_period(DateTime.new(2016,01,01), DateTime.new(2016,12,31))
			
			cards.select{|card| !card['card_labels'].blank?}.each do |card|
				if card['card_labels'].none?{|label| label['color'] == "orange"}
					puts card['short_id']
					card['card_labels'] << { "color" => "orange", "name" => "tekst", "id" => "5692a5471847e9844acf0010", "idBoard" => "567476511c0f8704a142ffcc"}
					@card_repository.update(card)
				end
				if card['card_labels'].none?{|label| label['color'] == "red"}
					puts card['short_id']
					card['card_labels'] << { "color" => "red", "name" => "pl", "id" => "5692a54863f937efaf5f242a", "idBoard" => "567476511c0f8704a142ffcc"}
					@card_repository.update(card)
				end
			end
		end

		def migrate_dates
			cards = @card_repository.get_cards_from_period(DateTime.new(2016,01,01), DateTime.new(2016,12,31))
			
			cards.each do |card|
				puts card['last_activity_date']
				date = DateTime.parse(card['last_activity_date'].to_s).iso8601
				card['last_activity_date'] = date
				@card_repository.update(card)
				break
				#end
			end
		end
	end
end	