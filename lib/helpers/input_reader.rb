# encoding UTF-8

module DiTrello
	class InputReader
		def initialize(raw_input)
			@link = raw_input
			@groups = []
			@link = ''
			@error_message = ''
		end

		def read
			validate
		end

		def link
			@link
		end

		def groups
			@groups
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

		def validate()
		    valid = begin
		      URI.parse(@link).kind_of?(URI::HTTP)
		    rescue URI::InvalidURIError
		      false
		    end
		    unless valid
		      @error_message = "Błędny format url'a"
		    end
		end
	end
end