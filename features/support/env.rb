require "tempfile"
require "tmpdir"
require "webrick"

require "hq/log-monitor-client/script"

# web server to recieve events

$web_config = {
	:Port => 10000 + rand(55535),
	:AccessLog => [],
	:Logger => WEBrick::Log::new("/dev/null", 7),
	:DoNotReverseLookup => true,
}

$web_server =
	WEBrick::HTTPServer.new \
		$web_config

$web_server_url =
	"http://localhost:%s/submit-log-event" % [
		$web_config[:Port],
	]

Thread.new do
	$web_server.start
end

at_exit do
	$web_server.shutdown
end

$web_server.mount_proc "/submit-log-event" do
	|request, response|

	event = MultiJson.load request.body

	$events_received << event

end

# set up and tear down

Before do

	$events_received = []

	@old_dir = Dir.pwd
	@temp_dir = Dir.mktmpdir
	Dir.chdir @temp_dir

end

After do

	FileUtils.remove_entry_secure @temp_dir
	Dir.chdir @old_dir

end

def write_file file_name, file_contents

	file_contents.gsub! "${server-url}", $web_server_url

	File.open file_name, "w" do
		|file_io|
		file_io.print file_contents
	end

end
