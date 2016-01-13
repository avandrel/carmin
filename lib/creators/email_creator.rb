# encoding UTF-8

module Carmin
	class EmailCreator
		def self.create(list_name, card_txt_collection)
			%Q(
Lista "#{list_name}"

#{body(card_txt_collection)}

#{Carmin::EmailHelper.delimiter}
)
		end

		private

		def self.body(card_txt_collection)
			retval = ''
			card_txt_collection.each do |range, card_collection|
				retval << "\n=#{range.upcase}=\n"
				card_collection.each { |card| retval << card }
			end
			retval
		end
	end
end