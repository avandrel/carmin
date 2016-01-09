# encoding UTF-8

module DiTrello
	class InputReader
		def initialize()
			@link = ''
			@error_message = ''
			@uri = nil
		end

		def try_read(params)
			validate(sanitize(params['text']))
			if @uri != nil
				params['link'] = @uri.to_s
				params['source'] = @uri.host
				return true
			end
			false
		end

		def error_message
			@error_message
		end

		private 
=begin

		def read_with_groups
			input_array = @raw_input.scan(/do \[(.*)\] (.*)/)[0]
			if input_array.blank? || input_array.length != 2
				@error_message = "Błędny fomat zgłoszenia!"
				return
			end
			input_array[0].split(',').map { |group| @groups << group.strip}
			@link = input_array[1]
		end
=end
		def sanitize(raw_input)
			raw_input.gsub(/\A"|"\Z/, '')
		end

		def validate(raw_input)
		    begin
		      @uri = URI.parse(raw_input)
		    rescue URI::InvalidURIError
		      @error_message = "Błędny format url'a"
		    end
		end
	end
end