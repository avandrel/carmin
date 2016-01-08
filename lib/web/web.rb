require 'sinatra/base'
require 'sinatra/config_file'
require 'discourse_api'

module DiTrello
  class Web < Sinatra::Base
    register Sinatra::ConfigFile

    before do
        headers "Content-Type" => "application/json; charset=utf8"
        @config_hash = DiTrello::Config.get_config_hash
    end

    get "/" do
=begin
      if ENV['RACK_ENV'] != 'production'
        client = DiscourseApi::Client.new(@config_hash['discourse_url'])
        client.api_key = @config_hash['discourse_api_key']
        client.api_username = @config_hash['discourse_api_username']

        messages = client.private_messages(client.api_username)
        puts messages.to_json
        messages.each do |message|
          if !@inbox_list.cards.any? { |card| card.name == message["title"]}
            card = Trello::Card.create({
              #:list_id => @inbox_list.id,
              :name => message["title"]
            })
            card.save
          end
        end
      end
=end

      "ok"
    end

    post "/create" do
      puts params
      slack_trello = DiTrello::SlackTrello.new @config_hash
      slack_trello.respond(params)
    end
  end
end