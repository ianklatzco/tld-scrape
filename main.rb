# fair warning: this is awful code: i wrote it to learn some ruby.

require 'telegram/bot'
require 'open-uri'
require 'net/http'
require 'diffy'

$url = "http://data.iana.org/TLD/tlds-alpha-by-domain.txt"
$stored = nil

# authenticate
creds_name = "creds.txt"
somefile = File.open(creds_name, "r")
TOKEN = somefile.read.strip
somefile.close

# open the last read
$fname = "last.txt"
handle = File.open($fname, "r")
$stored = handle.read
handle.close

def send_thing()
	response = Net::HTTP.get_response(URI.parse($url))
	response = response.body
	diff_result = Diffy::Diff.new($stored, response, :context => 0)

	# if the file was empty, write the response
	if $stored == ''
		puts "file was empty, writing"
		handle = File.open($fname, "w")
		handle.write(response)
		handle.close
		printable = response.slice(0,1900)
		return printable
	end

	# puts "file was not empty"
	if diff_result.to_s != ''
		puts "diff was different, writing"
		handle = File.open($fname, "w")
		handle.write(response)
		handle.close
		return diff_result.to_s.slice(0,1900)
	end

	return ''
end

require 'logger'
logger = Logger.new(STDOUT)

Telegram::Bot::Client.run(TOKEN) do |bot|
	my_id = 157625604
	foo = send_thing()
	sendend = lambda { |x="hello world"|
		# i feel like i'm writing INCREDIBLY shitty haskell
		if x == '' or nil ; return ; end
		bot.api.send_message(chat_id: my_id, text: x)
	}

	sendend.call(foo)
end
