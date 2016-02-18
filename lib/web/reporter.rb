module Carmin
	class Reporter

		def initialize(config_hash)
			@config_hash = config_hash
		end

		def report(params)
			log = []
			log << "# Start"
			start_time = Time.now
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('report', params['token'])
				return 401
			end

			mongo_helper = Carmin::MongoHelper.new @config_hash

			date_from = params['date_from'].blank? ? Date.new(2016,01,01) : Date.parse(params['date_from'])
			date_to = params['date_to'].blank? ? Date.today : Date.parse(params['date_to'])

			cards = search_cards(mongo_helper, date_from, date_to)

			create_csv(cards)
		end

		private

		def search_cards(mongo_helper, date_from, date_to)
			card_repository = Carmin::CardRepository.new mongo_helper

			card_repository.get_cards_from_period(date_from, date_to)			
		end

		def create_csv(cards)
			retval = "id|last_activity_date|source|channel|language|medium|scope|tags|trash\n"
			cards.each do |card|
				retval << "#{card['short_id']}|"
				retval << "#{card['last_activity_date']}|"
				retval << "#{card['desc']['source']}|"
				retval << "#{card['desc']['channel']}|"
				retval << "#{get_label_name(card['card_labels'], "red")}|"
				retval << "#{get_label_name(card['card_labels'], "orange")}|"
				retval << "#{get_label_name(card['card_labels'], "green")}|"
				retval << "#{card['card_labels'].select{|label| label['color'] == "purple"}.map{ |label| label['name']}.join(",")}|"
				retval << "#{card['desc']['list_name'] == nil}|"
				retval << "\n"
			end
			retval
		end

		def get_label_name(labels, color)
			if labels.any?{ |label| label['color'] == color } 
				labels.find{ |label| label['color'] == color }['name']
			else
				"empty"
			end
		end
	end
end