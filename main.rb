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
# re-opens the stored file every time this file is run.
$stored = handle.read
handle.close

class String
# oh this is how you add methods to the string class, that's cool!
	def remove_lines(i)
		split("\n")[i..-1].join("\n")
	end
end

def send_thing()
	response = Net::HTTP.get_response(URI.parse($url))
	response = response.body

	# diff the stored file against the new response
	# (strip the dates)
	stripped_response = response.remove_lines(1)
	stripped_stored   = $stored.remove_lines(1)

	diff_result = Diffy::Diff.new(stripped_stored, stripped_response, :context => 0)

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
	diff_result = send_thing()
	sendend = lambda { |x="hello world"|
		# i feel like i'm writing INCREDIBLY shitty haskell
		if x == '' or nil
			bot.api.send_message(chat_id: my_id, text: "no new TLDs today! have a good night c:")
		else
			bot.api.send_message(chat_id: my_id, text: x)
		end
	}

	sendend.call(diff_result)
end
