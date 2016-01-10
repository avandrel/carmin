module Carmin
	class MessageHelper
		def initialize(incoming_hook, board_url)
			@notifier = Slack::Notifier.new incoming_hook
			@board_url = board_url
		end

		def return_error_message(user_name, error_message)
			message = user_name.blank? ? "" : "#{user_name}: "
			message = "#{message}*#{error_message}*"
			message_to_response(message, "error")
		end

		def return_ok_message(user_name)
			message = user_name.blank? ? "" : "#{user_name}: "
			message = "#{message}Dziękujemy zagłoszenie!"
			notify()
			message_to_response(message, "ok")
		end

		private

		def notify()
			@notifier.ping "New Inbox message! => <#{@board_url}|Visit Trello board>"
		end

		def message_to_response(message, status)
			{ "response_type" => "ephemeral","text" => message, "status" => status }.to_json
		end
	end
end