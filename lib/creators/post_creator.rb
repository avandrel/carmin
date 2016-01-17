# encoding UTF-8

require 'discourse_api'

module Carmin
	class PostCreator
		def initialize(config_hash)
			@config_hash = config_hash
			@discourse_client = create_discourse_client()
		end
		
		def create(params)
			token_helper = Carmin::TokenHelper.new @config_hash
			if !token_helper.validate_token('post', params['token'])
				return token_helper.invalid_token
			end

			if params['date'].blank?
				return [400, "Missing date"]
			end

			mongo_helper = Carmin::MongoHelper.new @config_hash
			body_repository = Carmin::BodyRepository.new mongo_helper

			if (body_repository.body_in_repo?(params['date']))
				body = adjust_markdown(body_repository.get_body(params['date'])[:body])
				puts body
				@discourse_client.create_post({topic_id: @config_hash['discourse_publish_topic_id'], raw: body.values.join("\n")})
				#@discourse_client.create_post({topic_id: @config_hash['discourse_publish_topic_id'], raw: body.values[1]})
				return [200, "OK"]
			end

        	[404, "Not found"]
		end

        
        private

        def create_discourse_client()
        	client = DiscourseApi::Client.new(@config_hash['discourse_url'])
        	client.api_key = @config_hash['discourse_api_key']
        	client.api_username = @config_hash['discourse_api_username']
        	client.ssl({ verify: false })
        	client
    	end

    	def adjust_markdown(body)
    		body.each do |key, value|
    			value.gsub!(/^# (.*)$/, '*\1*')
    			value.gsub!(/^\s{2}(.*)(: .*)$/, '*\1*\2')
    			value.gsub!(/^==+ (.*) ==+$/, '##\1')
    			value.gsub!(/^= (.*) =$/, '###\1')
    		end
    	end
	end
end