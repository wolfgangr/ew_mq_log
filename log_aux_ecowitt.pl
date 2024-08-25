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

my $aux_topic = "wetter/pleussen/aux";
my $aux_dtime = 600 ; # max time in s between messages if nothing special happens
my $aux_dtemp = 1   ; # temp diff in °C to trigger a message
my $aux_dhum  = 2   ; # humidity diff in % to trigger a message

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

#==============

# __main__ MQTT subscription callback handler 
$mqtt->run(
        $ew_topic => \&do_ecowitt,
        # "#" => \&parse_default,
        "#" => \&noop,

    );

#======== subs 

sub noop {}

# for dbug: we may parse other messages
sub parse_default  {
            my ($topic, $message) = @_;
            print "default: [$topic] $message\n";
        }

# MQTT callback distributor 
sub do_ecowitt {
  my $hr = parse_ecowitt(@_);	
  debug_print(4, Dumper($hr)); 
  # disable for dev of aux sensor stuff
  # log_ecowitt($hr);

  # parse and process aux sensor data
  do_auxs($hr);

}


sub parse_ecowitt {
    my ($topic, $message) = @_;
    debug_print(4, "ecowitt data: \n $message\n");

    my $hashref = $json->decode( $message );
    return $hashref;
}

sub do_auxs {
  my $hr = shift @_;
  my $auxs = parse_aux($hr);
  CORE::state $old_auxs = []; # \() ; # static, ininitialized only once

  debug_print(2, sprintf("aux sensor update at %s\n", $hr->{'dateutc'}));
  debug_print(4, Dumper($auxs));

  for my $sn (0 .. $#$auxs) {
    next unless (defined($$auxs[$sn]));

    debug_print(3, sprintf ("do sensor number %d -> %s \n", $sn,
	         scalar(keys %{$$auxs[$sn]} ) ) ) ;

    # skip update if values haven't changed
    # "     ... checking sensor change .... \n";
    if (defined($$old_auxs[$sn])) {
      next if eq_hashes($$auxs[$sn] , $$old_auxs[$sn]);
    }
    
    debug_print(3, "       ... sensor changed, perform update\n");
    log_aux( $hr->{'dateutc'}, $station, $sn,  $$auxs[$sn]  );

    debug_print(3, "       ... sensor changed, check pub conditions\n"); 
    pub_aux( $hr->{'dateutc'}, $station, $sn,  $$auxs[$sn]  );

  }

  $old_auxs = $auxs ; # hope that assigning ref effectively clones
}


# \@sensors =  parse_aux($json_hashref)
sub parse_aux {
  my $data = pop @_;
  my @sensors = ();
  foreach my $key (keys %$data) {
    next unless ( $key =~  /^((?:temp)|(?:humidity)|(?:batt))((?:\d)|(?:in))$/ ) ;
    if ($1 and $2) {
      my $ix = ($2 eq 'in') ? 0 : $2 ;
      $sensors[$ix]{$1} = $data->{$key} ;
    }
  }
  return \@sensors;
}

# log single aux sensor
# log_aux( idx, station#, sensor#, data-hash)
sub log_aux {
  # print (Dumper (\@_));
  my ($idx, $stat, $sn, $shr) = @_;
  debug_print(4, (Dumper($idx, $stat, $sn, $shr)));

  my $sql = "INSERT INTO `aux_th` SET";
  $sql .= sprintf (" \n `idx`        = '%s'   ", $idx);
  $sql .= sprintf (",\n `station`    = '%3d'  ", $stat);
  $sql .= sprintf (",\n `sensor`     = '%3d'  ", $sn);
  # $sql .= sprintf (",\n `hum_out`    = '%s'  ", $data->{'humidity'});
  # foreach my $k (keys %$shr) {
  while (my ($k, $v) = each %$shr) {
    $sql .= sprintf (",\n `%s`     = '%s'  ", $k, $v);
  }

  $sql .= " ;\n" ;

  debug_print(4, $sql);
  # execute sql statement
  my $affected = $dbh->do($sql);
  debug_print (2, "\t$affected Datasets of sensors updated\n");
 
}

#  pub_aux( $hr->{'dateutc'}, $station, $sn,  $$auxs[$sn]  );
sub pub_aux {
  my ($idx, $stat, $sn, $shr) = @_;
  debug_print(2, sprintf("--- pub_aux - station: %d, sensor: %d, utc-time: %s\n", $stat, $sn, $idx));
  debug_print(3, Dumper($shr));

}

#----------------------

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


# eq_hashes(\%a, \%b)
# returns 1 if they are equal, 0 in not
sub eq_hashes {
  my ($a, $b) = @_;
  # print "enter eq_hashes\n";
  # print Dumper($a, $b);
  # print "eq_hashes dumped\n";

  return 0 unless (ref $a eq ref{} );
  return 0 unless (ref $b eq ref{} );
  # print "eq_hashes after reftest\n";
  return 0 unless (scalar(keys %$a) == scalar(keys %$b));
  # print "eq_hashes after length cmp\n";

  while (my ($k, $v) = each %$a) {
    return 0 unless ($v eq $b->{$k});
  }
  # print "returning 1 \n";
  return 1;
}

# debug_print($level, $content)
sub debug_print {
  my $level = shift @_;
  print STDERR @_ if ( $level <= $debug) ;
  # print  @_ if $debug ;
}



