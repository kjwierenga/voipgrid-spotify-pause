require 'dotenv/load'
require 'faye/websocket'
require 'eventmachine'

def applescript(script)
  system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
end

EM.run {
  ws = Faye::WebSocket::Client.new(ENV.fetch('WEBSOCKET'))

  ws.on :open do |event|
    p [:open]
    # ws.send('play')
    # ws.send('pause')
  end

  ws.on :message do |event|
    p [:message, event.data]

    applescript <<-END
      tell application "Spotify"
        #{event.data}
      end tell
    END
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
