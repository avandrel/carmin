module Carmin
	class Searcher

		LIST_IDIOMS = ['lista', 'listy', 'grupy', 'kategorie']
		TAGS_IDIOMS = ['tagi', 'tags']
		HELP_IDIOMS = ['info', 'help', 'pomoc']

		EXCLIUDE = ['INBOX', 'KOSZ']

		def initialize(config_hash)
			@config_hash = config_hash
			@slack_helper = Carmin::SlackHelper.new @config_hash['slack_wywiad_incoming_hooks'], @config_hash['trello_board_url']
			@card_helper = Carmin::CardHelper.new @config_hash
		end

		def search(params)
			log = []
			log << "# Start"
			start_time = Time.now
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('search', params['token'])
				return 401
			end

			mongo_helper = Carmin::MongoHelper.new @config_hash

			search_phrase = params['text']

			if LIST_IDIOMS.include?(search_phrase)
				return search_list_names()
			elsif TAGS_IDIOMS.include?(search_phrase)
				return search_tag_names()
			elsif HELP_IDIOMS.include?(search_phrase)
				return prepare_help_response()
			else
				return search_cards(search_phrase, params['color'], mongo_helper, params.include?('response_url'))
			end
		end

		private

		def search_cards(search_phrase, color, mongo_helper, from_slack)
			card_repository = Carmin::CardRepository.new mongo_helper

			cards_with_label = card_repository.get_cards_with_label(color, search_phrase)			
			cards_in_category = card_repository.get_cards_in_category(search_phrase)			

			cards = cards_with_label | cards_in_category

			if from_slack
				if cards.count > 0
					@slack_helper.message_to_response(create_message(cards, search_phrase), "ok")
				else
					@slack_helper.message_to_response("*#{search_phrase} - nie ma takiego tematu!*", "error")
				end				
			else
				cards
			end
		end

		def search_list_names()
			Trello.configure do |config|
          		config.developer_public_key = @config_hash["trello_developer_public_key"]
          		config.member_token = @config_hash["trello_member_token"]
        	end
			wywiad_board = Trello::Board.find(@config_hash["trello_board_id"])
			@slack_helper.message_to_response("*Kategorie CARMIN*\n#{wywiad_board.lists.select{|list| !EXCLIUDE.include?(list.name)}.map{|list| list.name}.join("\n")}", "ok")
		end

		def search_tag_names()
			Trello.configure do |config|
          		config.developer_public_key = @config_hash["trello_developer_public_key"]
          		config.member_token = @config_hash["trello_member_token"]
        	end
			wywiad_board = Trello::Board.find(@config_hash["trello_board_id"])
			@slack_helper.message_to_response("*Tagi CARMIN*\n#{wywiad_board.labels.map{|label| label.name}.sort.join(", ")}", "ok")
		end

		def create_message(cards, label)
			message = "*#{label}*\n"
			cards.take(20).each do |card|
				message << "#{card['last_activity_date'].strftime("%F")} <#{card['source_url']}|#{card['name']}>\n"
			end
			message
		end

		def prepare_help_response()
			response = %Q(*Carmin* - aplikacja pozwalająca wszystkim zRazom dzielić się z partią informacjami o ważnych lub wymagających działania wydarzeniach.
				
*Przydatne polecenia:*
/carmin pomoc - właśnie oglądasz
/carmin lista - lista dostępnych kategorii
/carmin tagi - lista dostępnych tagów
/camin &lt;tag lub kategoria&gt; - wyświetl ostatnie 20 artykułów na zadany temat

*Jak zapisać się do systemu:*
Z wyników polecenia '/carmin lista' wybierz interesujące Cię kategorie i podaj je wraz ze swoim emailem: na Slacku, mailowo lub jako PW na forum jednej z następujących osób: Agata Murawska, Arek Gochnio, Jacek Stefaniak, Michał Choroszy. To wszystko!

*Jak dodawać linki do systemu:*
na Slacku: podaj na dowolnym kanale '/wywiad &lt;url&gt;' 
wtyczka FireFox: https://drive.google.com/file/d/0B9f6nkaUBDLRRi1tNW5wOUdmb00/view?usp=sharing
wtyczka Chrome: https://chrome.google.com/webstore/detail/carmin/elegbgmmhbhlnhnfdalbdedefhchihjg?hl=pl&amp;gl=PL

*Ostatnie zmiany*
- uporządkowanie kategorii
- nowe polecenia Slacka)
			@slack_helper.message_to_response(response, "ok")
		end
	end
end