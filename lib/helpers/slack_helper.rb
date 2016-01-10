module Carmin
	class SlackHelper
		def initialize(incoming_hook, board_url)
			@notifier = Slack::Notifier.new incoming_hook
			@board_url = board_url
		end

		def return_user_error_message(user_name, error_message)
			message = user_name.blank? ? "" : "#{user_name}: "
			message = "#{message}*#{error_message}*"
			message_to_response(message, "error")
		end

		def return_user_ok_message(user_name)
			message = user_name.blank? ? "" : "#{user_name}: "
			message = "#{message}Dziękujemy zagłoszenie!"
			notify("New Inbox message! => <#{@board_url}|Visit Trello board>")
			message_to_response(message, "ok")
		end

		def notify(message)
			@notifier.ping message 
		end
		
		private

		def message_to_response(message, status)
			{ "response_type" => "ephemeral","text" => message, "status" => status }.to_json
		end
	end
end