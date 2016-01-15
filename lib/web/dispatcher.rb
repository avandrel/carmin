module Carmin
	class Dispatcher

		KOSZ_LIST_NAME = "KOSZ"

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
			@return_message = ''
			@date = DateTime.now.strftime("%F")
		end

		def dispatch(params)
			log = []
			start_time = Time.now
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('dispatch', params['token'])
				return 401
			end

			closed_cards_per_list = @card_helper.get_closed_cards_per_list
			log << "Got #{closed_cards_per_list.values.map{ |cards| cards.count }.sum()} closed cards, Elapsed: #{Time.now - start_time}[s]"
			mongo_helper = Carmin::MongoHelper.new @config_hash
			card_repository = Carmin::CardRepository.new mongo_helper

			lists_txt_collection = {}
			closed_cards_per_list.each do |list_name, cards|
				puts list_name
				puts cards.map { |card| card.name }.join("\n")
				cards_txt_collection = {}
				cards.each do |card|
					update_desc(card, list_name)
					set_defaults(card)
					range = Carmin::EmailCreator.get_label_value(card, "green")
					(cards_txt_collection[range] ||= []) << Carmin::EmailCreator.create_card_txt(card)
				end

				lists_txt_collection[list_name] = Carmin::EmailCreator.create_list_body(list_name, cards_txt_collection)
			end
			log << "List bodies created, Elapsed: #{Time.now - start_time}[s]"

			recipient_repository = Carmin::RecipientRepository.new mongo_helper
			recipients = recipient_repository.get_all_recipients
			log << "Got #{recipients.count} recipients, Elapsed: #{Time.now - start_time}[s]"

			puts recipients.count
			recipients.select{ |recipient| recipient[:groups].count > 0 }.each do |recipient|
			#recipients.each do |recipient|
				body = Carmin::EmailCreator.create_body(lists_txt_collection, recipient[:groups])
				if recipient[:email] == @config_hash['admin_email']
					body_repository = Carmin::BodyRepository.new mongo_helper
					if body_repository.body_in_repo?(@date)
						body_repository.update_body({ :date => @date, :body => lists_txt_collection })
					else
						body_repository.add_body({ :date => @date, :body => lists_txt_collection })
					end
				end

				Carmin::EmailHelper.send_email(@config_hash, body, recipient[:email], @date)
				log << "Email send, Elapsed: #{Time.now - start_time}[s]"
			end
			
			closed_cards_per_list.values.each do |cards| 
				cards.each do |card|
					card_repository.update_card(card)
					card.delete
				end
			end

			[200, log.join("\n")]
		end

		private

		def update_desc(card, list_name)
			desc = JSON.parse(card.desc)
			desc['list_name'] = list_name
			card.desc = desc
		end

		def set_defaults(card)
			if !card.labels.any? { |label| label.color == "red" }
				label = @card_helper.board_labels.select{ |label| label.color == "red" && label.name == "pl"}.first
				card.add_label(label)
			end

			if !card.labels.any? { |label| label.color == "orange" }
				label = @card_helper.board_labels.select{ |label| label.color == "orange" && label.name == "tekst"}.first
				card.add_label(label)
			end
		end
	end
end