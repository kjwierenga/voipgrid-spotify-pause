# app.rb
# require 'faye/websocket'
#
# Spotify::Server = lambda do |env|
#   if Faye::WebSocket.websocket?(env)
#     ws = Faye::WebSocket.new(env)
#
#     ws.on :message do |event|
#       ws.send(event.data)
#     end
#
#     ws.on :close do |event|
#       p [:close, event.code, event.reason]
#       ws = nil
#     end
#
#     # Return async Rack response
#     ws.rack_response
#
#   else
#     # Normal HTTP request
#     [200, {'Content-Type' => 'text/plain'}, ['Hello']]
#   end
# end

require 'bundler'
Bundler.require

require 'dotenv/load'
require 'faye/websocket'
require 'sinatra/base'

Faye::WebSocket.load_adapter('thin')

KEEPALIVE_TIME = 15

class Spotify::Server < Sinatra::Base
  def initialize
    super
    @clients = []
  end

  get '/*' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env, nil, { ping: KEEPALIVE_TIME })

      ws.on(:open) do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      # ws.on(:message) do |msg|
      #   ws.send(msg.data) # Reverse and reply
      # end

      ws.on(:close) do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      ws.rack_response

    else
      @clients.each { |ws| ws.send(params['splat'].first) }
      erb :index
    end
  end

  get '/play' do
    @clients.each { |ws| ws.send('play') }
    'OK'
  end

  get '/pause' do
    @clients.each { |ws| ws.send('pause') }
    'OK'
  end

  post '/notification' do
    p params.inspect
  end
end
