#!/usr/bin/perl

use warnings;
use strict;
use Net::MQTT::Simple;
use JSON;
use Data::Dumper;
use DBD::mysql;	
use POSIX qw(strftime);	# time string formatting


my $mqtt_server = "homeserver.rosner.lokal";
my $ew_topic = "wetter/test";
my $db_creds ="my.cnf";
my $debug = 3;

# ======= eo config ============


my $mqtt = Net::MQTT::Simple->new($mqtt_server);
my $json = JSON->new->allow_nonref;


# open database connection
my $db_driver = "mysql";
my $creds = parse_DB_creds($db_creds);
# exit;

my $user     = $creds->{'user'} ;
my $database = $creds->{'database'} ;
my $DBHost   = $creds->{'host'} ;
my $passwd   = $creds->{'password'} ;

debug_print(1, "\n$0 connecting as user <$user> to database <$database> at host <$DBHost>...\n");
# exit;

my $dsn = "DBI:$db_driver:$database;$DBHost";
my $dbh = DBI->connect($dsn, $user, $passwd) 
	|| die ("Could not connect to database: $DBI::errstr\n");

debug_print(1,  "\t...connected to database \n\n") ;
# exit;

$mqtt->run(
        $ew_topic => \&do_ecowitt,
        # "#" => \&parse_default,
        "#" => \&noop,

    );

#======== subs 

sub noop {}

sub parse_default  {
            my ($topic, $message) = @_;
            print "default: [$topic] $message\n";
        }

sub do_ecowitt {
  my $hr = parse_ecowitt(@_);	
  debug_print(3, Dumper($hr)); 
}


sub parse_ecowitt {
    my ($topic, $message) = @_;
    debug_print(3, "ecowitt data: \n $message\n");

    my $hashref = $json->decode( $message );
    return $hashref;
    # print Dumper($hashref);	
 }


#--- parse db credential file
# https://mariadb.com/kb/en/configuring-mariadb-with-option-files/
# https://mariadb.com/kb/en/mariadb-command-line-client/

sub parse_DB_creds {
  my $opt_file = pop @_;

  my %creds =();

  open my $OF, $opt_file or die "Could not open $opt_file: $!";
  while (<$OF>) {
    next if /^#/;
    next if /\[client\]/;
    if ( /^\s*(\w+)\s*=\s*(\w+)\s*$/ ) {
      $creds{$1} = $2;
      next;
    }
    die("illegal line in config file $opt_file: >|$_|<");

  }
  close ($OF);
  debug_print(3, Dumper(\%creds));
  return \%creds;
}



# debug_print($level, $content)
sub debug_print {
  my $level = shift @_;
  print STDERR @_ if ( $level <= $debug) ;
  # print  @_ if $debug ;
}



