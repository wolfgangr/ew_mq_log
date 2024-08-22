#!/usr/bin/perl

use warnings;
use strict;
use Net::MQTT::Simple;
use JSON;
use Data::Dumper;


my $mqtt_server = "homeserver.rosner.lokal";
my $ew_topic = "wetter/test";

# ======= eo config ============


my $mqtt = Net::MQTT::Simple->new($mqtt_server);
my $json = JSON->new->allow_nonref;


$mqtt->run(
        $ew_topic => \&parse_ecowitt,
        # "#" => \&parse_default,
         "#" => \&noop,

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

    my $hashref = $json->decode( $message );
    print Dumper($hashref);	
 }



