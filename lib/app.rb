require 'sinatra/base'
require 'sinatra/config_file'
require 'trello'
require 'discourse_api'

module DiTrello
  class Web < Sinatra::Base
    register Sinatra::ConfigFile

    root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    config_file File.join( [root, 'config.yml'] )

    before do
        headers "Content-Type" => "application/json; charset=utf8"
    end

    get "/" do 
      Trello.configure do |config|
        config.developer_public_key = settings.trello_developer_public_key
        config.member_token = settings.trello_member_token
      end

      board = Trello::Board.find(settings.trello_board_id)
      inbox_list =  board.lists.first { |list| list.name = "Inbox"}
      #puts inbox_list.cards.inspect
      

      client = DiscourseApi::Client.new(settings.discourse_url)
      client.api_key = settings.discourse_api_key
      client.api_username = settings.discourse_api_username

      messages = client.private_messages(client.api_username)
      puts messages.to_json
      messages.each do |message|
        if !inbox_list.cards.any? { |card| card.name == message["title"]}
          card = Trello::Card.create({
            :list_id => inbox_list.id,
            :name => message["title"]
          })
          card.save
        end
      end
      "ok"
    end
  end
end