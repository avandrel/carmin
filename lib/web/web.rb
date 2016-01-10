require 'sinatra/base'
require 'sinatra/config_file'
require 'discourse_api'

module Carmin
  class Web < Sinatra::Base
    register Sinatra::ConfigFile

    before do
        headers "Content-Type" => "application/json; charset=utf8"
        @config_hash = Carmin::Config.get_config_hash
    end

    get "/healthcheck" do
      healthcheck = Carmin::HealthCheck.new @config_hash
      healthcheck.check(params)
    end

    get "/dispatch" do 
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


    post "/create" do
      slack_trello = Carmin::SlackTrello.new @config_hash
      slack_trello.respond(params)
    end
  end
end