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

      ws.on(:message) do |msg|
        @clients.each { |c| c.send(msg.data) }
      end

      ws.on(:close) do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      ws.rack_response

    else
      @clients.each { |c| c.send(params['splat'].first) }
      erb :index
    end
  end

  post '/play' do
    @clients.each { |c| c.send('play') }
    'OK'
  end

  post '/pause' do
    @clients.each { |c| c.send('pause') }
    'OK'
  end

  post '/notification' do
    p params.inspect
  end
end
