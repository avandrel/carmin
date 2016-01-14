# encoding UTF-8

module Carmin
	class EmailCreator

		DELIMITER = "-"

		def self.create_body(list_txt_collection, groups)
			%Q(Witaj!

To jest wiadomość z systemu zbierania informacji CARMIN. Została wygenerowana automatycznie, nie odpowiadaj na nią. Miłej lektury!

#{delimiter}

#{list_txt_collection.select{ |key,value| groups.include?(key)}.values.join("\n")}

#{delimiter}

To wszystko na dziś. Pozdrawiamy i przypominamy, że tylko RAZEM damy radę!

Więcej informacji: #carmin)
		end

		def self.create_list_body(list_name, card_txt_collection)			
			%Q(===== #{list_name.upcase} =====
#{body(card_txt_collection)})
		end

		def self.create_card_txt(card)
			name = card.name
			card_url = card.attachments.select{ |att| att.bytes == 0 }.first.url
			card_url_string = name == card_url ? "" : "\n  #{card_url}"
			media = get_label_value(card, "orange")
			language = get_label_value(card, "red")
			tags = get_labels_collection(card, "purple")
			tags_string = tags.blank? ? "" : "\n  Tagi: #{tags.join(" ")}"
%Q(
# #{name}#{card_url_string}  
  Żródło: #{card.desc['source']}
  Media: #{media} [#{language}]#{tags_string}
)
		end

		def self.get_label_value(card, color)
			card.labels.select{ |label| label.color == color }.first.name
		end

		private

		def self.body(card_txt_collection)
			retval = ''
			card_txt_collection.each do |range, card_collection|
				retval << "\n= #{range} =\n"
				card_collection.each { |card| retval << card }
			end
			retval
		end

		def self.get_labels_collection(card, color)
			card.labels.select{ |label| label.color == color }.map{ |label| "[#{label.name}]" }
		end

		def self.delimiter
			([DELIMITER] * 30).join()
		end
	end
end