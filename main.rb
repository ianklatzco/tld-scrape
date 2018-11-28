require 'telegram/bot'
require 'open-uri'
require 'net/http'
require 'diffy'

$url = "http://data.iana.org/TLD/tlds-alpha-by-domain.txt"
$stored = nil

class WebhooksController < Telegram::Bot::UpdatesController
  def start!(*)

    respond_with :message, text: 'Hello!'
	response = Net::HTTP.get_response(URI.parse($url)) # => #<Net::HTTPOK 200 OK readbody=true>
	response = response.body
	diff_result = Diffy::Diff.new($stored, response)

	# first run
	if $stored == nil
		$stored = response
		printable = response.slice(0,100)
		respond_with :message, text: "first run, fetched: #{printable}"
		return
	end

	if diff_result != nil
		respond_with :message, text: diff_result
	end
  end
end

fname = "creds.txt"
somefile = File.open(fname, "r")
TOKEN = somefile.read.strip
somefile.close

bot = Telegram::Bot::Client.new(TOKEN)

# poller-mode
require 'logger'
logger = Logger.new(STDOUT)
poller = Telegram::Bot::UpdatesPoller.new(bot, WebhooksController, logger: logger)
poller.start

