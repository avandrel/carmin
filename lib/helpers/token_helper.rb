module Carmin
	class TokenHelper
		def initialize(config_hash)
			@config_hash = config_hash
			@error_message = ''
		end

		def error_message
			@error_message
		end

		def try_set_channel(params)
			token = params['token']

			case token
				when @config_hash['slack_wywiad_outgoing_token'] then 
					begin
						params['channel'] = "slack" 
						return true
					end
				when @config_hash['ff_plugin_token'] then 
					begin
						params['channel'] = "ff_plugin" 
						return true
					end
				when @config_hash['chrome_plugin_token'] then 
					begin
						params['channel'] = "chrome_plugin" 
						return true
					end
				when @config_hash['safati_plugin_token'] then 
					begin
						params['channel'] = "safari_plugin" 
						return true
					end
			end

			@error_message = invalid_token
			return false
		end

		def validate_token(endpoint, token)
			case endpoint
				when 'healthcheck' 
					return token == @config_hash['healthcheck_token']
				when 'dispatch'
					return token == @config_hash['dispatch_token']
				when 'add'
					return token == @config_hash['add_recipient_token']
				when 'post'
					return token == @config_hash['discourse_publish_token']
				when 'search'
					return token == @config_hash['search_token']
			end

			return true
		end

		def invalid_token
			"Nieprawidłowy token!"
		end
	end
end