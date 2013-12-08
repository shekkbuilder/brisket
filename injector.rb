#!/usr/bin/env ruby
$LOAD_PATH << '/home/scanner/brisket/lib'
require 'messages'
require 'archive'
require 'naming'
require 'date'
require 'directories'
require 'net/scp'
require 'net/ssh'
require 'aws-sdk'

ec2 = AWS::EC2.new(
		    :access_key_id => '', # => Enter your own EC2 Access Key ID
		    :secret_access_key => '') # => Enter your own EC2 Secret Access Key

master_instance = "i-f3367794"
brisket_mother = ec2.instances[master_instance]

f = File.open(Directories.brisket_log, 'a+')

if brisket_mother.status == "stopped"
	f.puts Messages.brisket_start
  	brisket_mother.start
  	f.puts Messages.brisket_started
elsif brisket_mother.status == "running"
	f.puts Messages.brisket_started
else f.puts "[+] Error, please check Brisket Mothership logs..."
end

puts Archive.prep
f.puts Messages.syslog_stamp+Archive.prep

Archive.tar

puts Archive.copyfile
f.puts Messages.syslog_stamp+Archive.copyfile

Archive.scp

puts Archive.cleanup
f.puts Messages.syslog_stamp+Archive.cleanup

Archive.cleanup_zip

puts Archive.cleanup_done
f.puts Messages.syslog_stamp+Archive.cleanup_done

f.close