# encoding UTF-8

module DiTrello
	class InputReader
		def initialize(raw_input)
			@raw_input = raw_input
			@groups = []
			@link = ''
			@error_message = ''
		end

		def read
			if @raw_input.include? 'do ['
				read_with_groups
			else
				@link = @raw_input
			end
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

		def read_with_groups
			input_array = @raw_input.scan(/do \[(.*)\] (.*)/)[0]
			if input_array.blank? || input_array.length != 2
				@error_message = "Błędny fomat zgłoszenia!"
				return
			end
			input_array[0].split(',').map { |group| @groups << group.strip}
			@link = input_array[1]
		end
	end
end