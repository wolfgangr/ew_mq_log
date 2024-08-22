#!/usr/bin/perl

use warnings;
use strict;
use Net::MQTT::Simple;

my $mqtt_server = "homeserver.rosner.lokal";
my $ew_topic = "wetter/test";



# sub parse_ecowitt {
#      my ($topic, $message) = @_;
#      print "ecowitt data: \n $message\n";
#  }

my $mqtt = Net::MQTT::Simple->new($mqtt_server);

$mqtt->run(
        $ew_topic => \&parse_ecowitt,
        # "#" => \&parse_default,
         "#" => \&noop,

        # "#" => sub {
        #     my ($topic, $message) = @_;
        #     print "[$topic] $message\n";
        # },
	# $ew_topic => parse_ecowitt
    );

#======== subs 

sub noop {}

sub parse_default  {
            my ($topic, $message) = @_;
            print "default: [$topic] $message\n";
        }


sub parse_ecowitt {
     my ($topic, $message) = @_;
     print "ecowitt data: \n $message\n";
 }



