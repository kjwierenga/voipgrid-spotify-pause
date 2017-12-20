require 'dotenv/load'
require 'faye/websocket'
require 'eventmachine'

class Spotify::Client

  PING_INTERVAL = 1.freeze
  MAX_RETRIES   = 7.freeze

  def initialize
    @ws = nil
    @retries = 0
    em_run
  end

  def applescript(script)
    system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
  end

  def connect
    p [:connect]
    @ws = Faye::WebSocket::Client.new(ENV.fetch('WEBSOCKET'), nil, ping: PING_INTERVAL)

    @ws.on :any do |event|
      p event
    end

    @ws.on :open do |event|
      p [:open]
      @retries = 0
    end

    # EM.add_periodic_timer(PING_INTERVAL) do
    #   @ws.ping do
    #     p [:pong]
    #   end
    # end

    @ws.on :message do |event|
      p [:message, event.data]
      if 'close' == event.data
        @ws.close
      else
        run_applescript(event.data)
      end
    end

    @ws.on :error do |event|
      p [:error, event.message]
    end

    @ws.on :close do |event|
      p [:close, event.code, event.reason]
      @ws = nil
      reconnect
    end
  end

  def reconnect
    if @retries < MAX_RETRIES
      @retries += 1
      p [:reconnect, @retries]
      EM.add_timer(2 ** @retries) do
        connect
      end
    else
      raise "Timeout after #{@retries} retries."
    end
  end

  def run_applescript(command)
    applescript <<-END
      tell application "Spotify"
        #{command}
      end tell
    END
  end

  def em_run
    EM.run { connect }
  end
end

Spotify::Client.new
