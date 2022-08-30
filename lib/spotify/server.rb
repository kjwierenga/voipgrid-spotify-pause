require 'bundler'
Bundler.require

require 'dotenv/load'
require 'faye/websocket'
require 'sinatra/base'
require 'json'

Faye::WebSocket.load_adapter('thin')

PING_INTERVAL = 1.freeze

class Spotify::Server < Sinatra::Base
  def initialize
    super
    @clients = []
  end

  get '/*' do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env, nil, ping: PING_INTERVAL)

      ws.on(:open) do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on(:message) do |msg|
        signal(msg.data)
      end

      ws.on(:close) do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
      end

      ws.rack_response

    else
      signal(params['splat'].first)
      erb :index
    end
  end

  post '/notification' do
    request.body.rewind
    notification = JSON.parse request.body.read

    p [:notification, notification]

    # TODO: don't signal pause/play, but pass on notification status to client
    # which will maintain state
    signal('pause') if 'ringing' == notification['status']
    signal('play')  if 'ended'   == notification['status']

    { status: 'OK' }.to_json
  end

  private

    def signal(command)
      @clients.each { |c| c.send(command) }
    end

end
