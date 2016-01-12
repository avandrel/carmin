require 'trello'
require 'yaml'

module Carmin
	class Setup
		def initialize(clear)
		    config_hash = Carmin::Config.get_config_hash

		    Trello.configure do |config|
		        config.developer_public_key = config_hash["trello_developer_public_key"]
		        config.member_token = config_hash["trello_member_token"]
		    end

		    board = Trello::Board.find(config_hash["trello_board_id"])

		    if clear
		    	clear_lists(board.lists)
		    end

		    create_lists(board)
		    create_labels(board)
		end

		private 

		def create_lists(board)
			create_list(board, "KOSZ")
			create_list(board, "Finanse i budżet")
			create_list(board, "Kultura")
			create_list(board, "LGBT")
			create_list(board, "Nauka i szkolnictwo wyższe")
			create_list(board, "Obszary wiejskie i rolnictwo")
			create_list(board, "Ochrona praw zwięrząt")
			create_list(board, "Ochrona przyrody")
			create_list(board, "Oświata i edukacja")
			create_list(board, "Polityka mieszkaniowa")
			create_list(board, "Polityka przestrzenna")
			create_list(board, "Polityka społeczna")
			create_list(board, "Polityka zagraniczna")
			create_list(board, "Prawa kobiet")
			create_list(board, "RAZEM w mediach")
			create_list(board, "Świeckie państwo")
			create_list(board, "Ustrój państwa i samorząd")
			create_list(board, "Zdrowie")
			create_list(board, "INBOX")

		end

		def create_labels(board)
			create_label(board, "okręg wrocławski", "green")
			create_label(board, "region", "green")
			create_label(board, "kraj", "green")
			create_label(board, "inny okręg", "green")
			create_label(board, "UE", "green")
			create_label(board, "zagranica", "green")

			create_label(board, "gr1", "purple")

			create_label(board, "audio", "orange")
			create_label(board, "wideo", "orange")
			create_label(board, "tekst", "orange")
			create_label(board, "obraz", "orange")

			create_label(board, "pl", "red")
			create_label(board, "de", "red")
			create_label(board, "en", "red")
			create_label(board, "fr", "red")
			create_label(board, "es", "red")
		end

		def create_label(board, name, color)
			if !board.labels.any? { |label| label.name == name && label.color == color }
				Trello::Label.create({:name => name, :board_id => board.id, :color => color})
			end
		end

		def clear_lists(lists)
			lists.each do |list|
				list.close!
			end
		end

		def create_list(board, list_name)
			if !board.lists.any? { |list| list.name == list_name}
				list = Trello::List.create({
		    		:name => list_name,
	    			:board_id => board.id
	    			})
	    		list.save
	    	end
		end
	end
end	