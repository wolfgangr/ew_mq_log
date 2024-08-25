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
my $station = 1;
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
  debug_print(4, Dumper($hr)); 
  # log_ecowitt($hr);
  my $auxs = parse_aux($hr);
  debug_print(3, Dumper($auxs));
  for my $sn (0 .. $#$auxs) {
    printf ("dummy do sensor number %d -> %s \n", $sn, 
	( (defined($$auxs[$sn])) ? scalar(%$auxs[$sn]) : -1 ) ); 
  }
  exit;
}


sub parse_ecowitt {
    my ($topic, $message) = @_;
    debug_print(4, "ecowitt data: \n $message\n");

    my $hashref = $json->decode( $message );
    return $hashref;
    # print Dumper($hashref);	
}

# \@sensors =  parse_aux($json_hashref)
sub parse_aux {
  my $data = pop @_;
  my @sensors = ();
  foreach my $key (keys %$data) {
    next unless ( $key =~  /^((?:temp)|(?:humidity)|(?:batt))((?:\d)|(?:in))$/ ) ;
    # print ($key, " - ");
    if ($1 and $2) {
      my $ix = ($2 eq 'in') ? 0 : $2 ;
      # $sensors[$ix] = {} unless $sensors[$ix];
      $sensors[$ix]{$1} = $data->{$key} ;
    }
  }
  # print "\n";
  # print (Dumper(\@sensors));
  return \@sensors;
}

sub log_ecowitt {
  my $sql = build_ew_SQL(@_[0]);
  debug_print(3, $sql);

  # execute sql statement
  my $affected = $dbh->do($sql);
  debug_print (2, "\t$affected Datasets updated\n");
}

sub build_ew_SQL {
#  my $timestamp = strftime "%Y-%m-%d %H:%M:%S", gmtime;
  my $data = pop @_;

  my $sql = "INSERT INTO `raw` SET";
#  $sql .= sprintf (" \n `idx`        = '%s'   ", $timestamp); 
  $sql .= sprintf (" \n `idx`        = '%s'   ", $data->{'dateutc'});
  $sql .= sprintf (",\n `station`    = '%3d'  ", $station);
  $sql .= sprintf (",\n `hum_out`    = '%s'  ", $data->{'humidity'});
  $sql .= sprintf (",\n `temp_out`   = '%s' ", $data->{'temp'});
  $sql .= sprintf (",\n `dewpoint`   = '%s' ", $data->{'dewpoint'});
  $sql .= sprintf (",\n `hum_abs`    = '%s' ", $data->{'humidityabs'});
  $sql .= sprintf (",\n `wind_ave`   = '%s' ", $data->{'windspeed'});
  $sql .= sprintf (",\n `wind_gust`  = '%s' ", $data->{'windgust'});
  $sql .= sprintf (",\n `wind_dir`   = '%s'  ", $data->{'winddir'});
  $sql .= sprintf (",\n `rain_count` = '%s' ", $data->{'dailyrain'});
  $sql .= sprintf (",\n `baro_abs`   = '%s' ", $data->{'baromabs'});
  $sql .= sprintf (",\n `sol_rad`    = '%s' ", $data->{'solarradiation'});
  $sql .= sprintf (",\n `uv_rad`     = '%s'  ", $data->{'uv'});
  $sql .= sprintf (",\n `batt`       = '%s'  ", $data->{'wh65batt'}); 
  $sql .= " ;\n" ;
  # debug_print(3, $sql);
  return $sql
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



