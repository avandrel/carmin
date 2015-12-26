require 'trello'
require 'yaml'

module DiTrello
	class Setup
		def initialize
		    config_hash = DiTrello::Config.new

		    Trello.configure do |config|
		        config.developer_public_key = config_hash["trello_developer_public_key"]
		        config.member_token = config_hash["trello_member_token"]
		    end

		    board = Trello::Board.find(config_hash["trello_board_id"])

		  	create_list(board, "Inbox")
		  	create_list(board, "RO")
		  	create_list(board, "ZO")
		  	create_list(board, "Grupy")
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