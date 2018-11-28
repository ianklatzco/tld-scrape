# url = 'http://data.iana.org/TLD/tlds-alpha-by-domain.txt'
require 'telegram/bot'

class WebhooksController < Telegram::Bot::UpdatesController
  def start!(*)
    respond_with :message, text: 'Hello!'
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

