# HQ log monitor client

This project provides a client for HQ's log monitor system. This utility,
designed to be run from a cron job, checks for new lines in log files and
submits information about lines which match certain criteria to a server.

Get it from [GitHub](https://github.com/jamespharaoh/hq-log-monitor-client) or
[RubyGems](https://rubygems.org/gems/hq-log-monitor-client). Check the build
status at [Travis](https://travis-ci.org/jamespharaoh/hq-log-monitor-client).

[![Build Status](https://travis-ci.org/jamespharaoh/hq-log-monitor-client.png)](https://travis-ci.org/jamespharaoh/hq-log-monitor-server)

## Usage

If the gem is installed correctly, you should be able to run the command with
the following name:

	hq-log-monitor-client (options...)

If it was installed via bundler, then you will want to use bundler to invoke the
command correctly:

	bundle exec hq-log-monitor-client (options...)

You will also need to provide various options for the script to work correctly.

### General options

	--config FILENAME (required)

Use `--config` to specify the config file to use. This is a required option. See
below for the config file format.

## Configuration

The configuration file is XML and looks like this:

	<log-monitor-client-config>
		<cache path="[str]"/>
		<client class="[str]" host="[str]"/>
		<server url="[str]>"/>
		<service name="[str]">
			<fileset>
				<scan glob="[str]"/>
				...
				<match type="[str]" regex="[str] before="[int]" after="[int]"/>
				...
			</fileset>
			...
		</service>
		...
	</log-monitor-client-config>

### Cache

The cache is used to record information about the log files which have been
scanned previously, ensuring that the same events are not reported twice.
Specify a path where the script will have read and write access.

### Client

Specify global options for the client. The class and host are simply passed onto
the server verbatim and form part of the event source.

The intention is that the hostname be used for `host` and that `class` should
identify a number of hosts with the same characteristics.

### Server

Specify the URL which events will be submitted to. This will normally look
something like this:

	http(s)://hostname:port/submit-log-event

### Service

Specify as many services as you like, each with a unique name. The service
`name` will be sent to the server as part of the event source.

Each service can have multiple filesets. These in turn contiain <scan> elements
which specify which files to scan, and <match> elements, which specify what
regular expressions to match and what `type` to associate with each one.

Typically you would use `warning` and `critical` for type. The `before` and
`after` options specify the number of lines of context to send along with the
event. These are both optional.
