module Carmin
    class MongoHelper
        def initialize(config_hash)
            @connect = create_connection(config_hash['mongo_user'], config_hash['mongo_password'])
        end

    	def cards_collection
            @connect["cards"]
    	end

        def recipients_collection
            @connect["recipients"]
        end

        private

        def create_connection(mongo_user, mongo_password)
            Mongo::Client.new("mongodb://#{mongo_user}:#{mongo_password}@ds037015.mongolab.com:37015/heroku_srlwwqms", :database => 'heroku_srlwwqms')
        end
    end
end