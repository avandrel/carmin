require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'

module Carmin
  class Web < Sinatra::Base
    register Sinatra::ConfigFile

    before do
        @config_hash = Carmin::Config.get_config_hash
    end

    get "/add" do
      card_helper = Carmin::CardHelper.new @config_hash
      @list_names = card_helper.get_list_names
      haml :add_recipient
    end

    get "/healthcheck" do
      healthcheck = Carmin::HealthCheck.new @config_hash
      healthcheck.check(params)
    end

    get "/dispatch" do 
      response['Content-Type']= 'text/plain'
      dispatcher = Carmin::Dispatcher.new @config_hash
      dispatcher.dispatch(params)
    end
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
    post "/add_recipient" do
      recipient_creator = Carmin::RecipientCreator.new @config_hash
      recipient_creator.create(params)
    end


    post "/create" do
      slack_trello = Carmin::SlackTrello.new @config_hash
      slack_trello.respond(params)
    end
  end
end