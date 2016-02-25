require 'elasticsearch'
require 'typhoeus/adapters/faraday'

module Carmin
	class Migrate
		def initialize
		    @config_hash = Carmin::Config.get_config_hash
		    mongo_helper = Carmin::MongoHelper.new @config_hash
			@card_repository = Carmin::CardRepository.new mongo_helper
		end

		def migrate_labels
			cards = @card_repository.get_cards_from_period(DateTime.new(2016,01,01), DateTime.new(2016,12,31))
			
			cards.select{|card| !card['card_labels'].blank?}.each do |card|
				if card['card_labels'].none?{|label| label['color'] == "orange"}
					puts card['short_id']
					card['card_labels'] << { "color" => "orange", "name" => "tekst", "id" => "5692a5471847e9844acf0010", "idBoard" => "567476511c0f8704a142ffcc"}
					@card_repository.update(card)
				end
				if card['card_labels'].none?{|label| label['color'] == "red"}
					puts card['short_id']
					card['card_labels'] << { "color" => "red", "name" => "pl", "id" => "5692a54863f937efaf5f242a", "idBoard" => "567476511c0f8704a142ffcc"}
					@card_repository.update(card)
				end
			end
		end

		def migrate_dates
			cards = @card_repository.get_cards_from_period(DateTime.new(2016,01,01), DateTime.new(2016,12,31))
			
			cards.each do |card|
				puts card['last_activity_date']
				date = DateTime.parse(card['last_activity_date'].to_s).iso8601
				card['last_activity_date'] = date
				@card_repository.update(card)
				break
				#end
			end
		end

		def migrate_to_elasticsearch
			client = Elasticsearch::Client.new log: true, url: "http://paas:cc56376c6588953526684531f6898531@bifur-eu-west-1.searchly.com"
			client.search index: 'carmin_cards', body: { query: { match: { short_id: '183' } } }
			cards = @card_repository.get_cards_from_period(DateTime.new(2016,02,20), DateTime.new(2016,12,31))

			cards.each do |card|
				body = create_body(card)
				if !body.nil?
					client.index index: 'carmin_cards', type: 'card', id: card['short_id'], body: body
				end
			end
		end

		private

		def create_body(card)
			retval = {}
			retval[:id] = card['short_id']
			retval[:name] = card['name']
			retval[:source] = card['desc']['source']
			retval[:channel] = card['desc']['channel']
			retval[:list_name] = card['desc']['list_name']
			begin
				retval[:created_date] = get_created_date(card).iso8601
			rescue
				return nil
			end
			retval[:url] = card['url']
			retval[:language] = "#{get_label_name(card['card_labels'], "red")}"
			retval[:medium] = "#{get_label_name(card['card_labels'], "orange")}"
			retval[:scope] = "#{get_label_name(card['card_labels'], "green")}"
			retval[:description] = card['desc']['description']
			tags_array = card['card_labels'].select{|label| label['color'] == "purple"}.map{ |label| label['name']}.to_a
			retval[:tags] = tags_array
			retval[:tags_count] = tags_array.length

			retval
		end

		def get_created_date(card)
			if card['desc']['created'].nil?
				card['last_activity_date'].to_time
			else
				Time.parse(card['desc']['created'])
			end
		end

		def get_label_name(labels, color)
			if labels.any?{ |label| label['color'] == color } 
				labels.find{ |label| label['color'] == color }['name']
			else
				"empty"
			end
		end
	end
end	
 