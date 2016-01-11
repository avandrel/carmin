module Carmin
	class Dispatcher

		KOSZ_LIST_NAME = "Kosz"

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
			@return_message = ''
		end

		def dispatch(params)

			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.try_set_channel(params)
				return 401
			end

			closed_cards_per_list = @card_helper.get_closed_cards_per_list

			mongo_helper = Carmin::MongoHelper.new @config_hash
			card_repository = Carmin::CardRepository.new mongo_helper

			closed_cards_per_list.each do |list_name, cards|
				if list_name.name != KOSZ_LIST_NAME
					Carmin::EmailHelper.send_email(@config_hash, list_name, cards.map { |card| card.name }.join("\n"))
				end
				cards.each do |card| 
					update_desc(card, list_name)
					set_defaults(card_labels)
					card_repository.update_card(card)
					card.delete
				end
			end

			#@return_message << "OOD: #{cards_out_of_date[0]}/#{cards_out_of_date[1]} "

			#@slack_helper.notify(@return_message)
			200
		end

		private

		def update_desc(card, list_name)
			desc = JSON.parse(card.desc)
			desc[:list_name] = list_name
			card.desc = desc.to_s
		end

		def set_defaults(card)
			if !card.card_labels.any? { |label| label.color == "red" }
				label = Trello::Label.create({:color => "red", :name => "pl", :board_id => card.board_id})
				card.add(label)
			end

			if !card.card_labels.any? { |label| label.color == "orange" }
				label = Trello::Label.create({:color => "orange", :name => "tekst", :board_id => card.board_id})
				card.add(label)
			end
		end
	end
end