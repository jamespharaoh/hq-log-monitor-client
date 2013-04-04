Given /^(?:I have updated|a) file "(.*?)":$/ do
	|file_name, file_contents|

	write_file file_name, file_contents

end

Given /^I have updated file "(.*?)" without changing the timestamp:$/ do
	|file_name, file_contents|

	file_mtime = File.mtime file_name

	write_file file_name, file_contents

	file_atime = File.atime file_name
	File.utime file_atime, file_mtime, file_name

end

Given /^I have updated file "(.*?)" changing the timestamp:$/ do
	|file_name, file_contents|

	file_mtime = File.mtime file_name

	write_file file_name, file_contents

	file_atime = File.atime file_name
	File.utime file_atime, file_mtime + 1, file_name

end

When /^I have run log\-monitor\-client with config "(.*?)"$/ do
	|config_name|

	script = HQ::LogMonitorClient::Script.new

	script.stdout = File.open "/dev/null", "w"
	script.stderr = File.open "/dev/null", "w"

	script.args = [ "--config", config_name ]
	script.main
		
end

When /^I run log\-monitor\-client with config "(.*?)"$/ do
	|config_name|

	$events_received = []

	@script = HQ::LogMonitorClient::Script.new

	@script.stdout = StringIO.new
	@script.stderr = StringIO.new

	@script.args = [ "--config", config_name ]
	@script.main
		
end

Then /^no events should be submitted$/ do
	$events_received.should == []
end

Then /^the following events should be submitted:$/ do
	|events_str|
	events_expected = YAML.load "[#{events_str}]"
	$events_received.should == events_expected
end

Then /^the script should return (\d+)$/ do
	|expect_str|

	expect = expect_str.to_i

	@script.status.should == expect

end
