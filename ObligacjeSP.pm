#    Copyright (C) 1998, Dj Padzensky <djpadz@padz.net>
#    Copyright (C) 1998, 1999 Linas Vepstas <linas@linas.org>
#    Copyright (C) 2000, Yannick LE NY <y-le-ny@ifrance.com>
#    Copyright (C) 2000, Paul Fenwick <pjf@cpan.org>
#    Copyright (C) 2000, Brent Neal <brentn@users.sourceforge.net>
#    Copyright (C) 2000, Keith Refson <Keith.Refson@earth.ox.ac.uk>
#    Copyright (C) 2003, Tomas Carlsson <tc@tompa.nu>
#    Copytight (C) 2022-2024 Kaligula <kaligula.dev@gmail.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
#    02111-1307, USA
#
#
# This code was derived from the work on the packages Finance::Yahoo::*
# This code was derived from the work on the packages Finance::SEB
# This code was derived from the work on the packages Finance::Stooq
#
package Finance::Quote::ObligacjeSP;
require 5.004;

use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use vars qw($VERSION $NN_OFE_URL);
use utf8;
use DateTime;

$VERSION = '0.10';

sub methods { return (obligacje_sp => \&obligacje_sp); }

{
  my @labels = qw/date isodate method source name currency last price/;
	
  sub labels { return (obligacje_sp => \@labels); }
}

sub obligacje_sp {
  my $quoter  = shift;
  my @symbols = @_;

  return unless @symbols;
  my %stocks;
  my %duration = ( #in years
	'OTS' => 0.25,
	'ROR' => 1,
	'DOR' => 2,
	'TOS' => 3,
	'COI' => 4,
	'EDO' => 10,
	'ROS' => 6,
	'ROD' => 12
  );
  # TODO: Wywal błąd jeśli nie ma takiego symbolu

	my $debug = '';

  #
  # get CPI from API
  #
  
  #find year of the oldest inflation rated bond
  my $CPIYearStart = 9999;
  my $CPIMonthStart = 12;
  foreach my $symbol (@symbols) {
	my ($type, $seriesMonth, $seriesYearTo, $seriesDay, $rateFirstYear, $rateNextYears) = ($symbol =~ /([A-Z]{3})(\d{2})(\d{2})-d(\d{2})-p(\d+\.\d+)(?:-i(\d+\.\d+))/);
	$seriesYearTo += 2000;
	my $seriesYearFrom = $seriesYearTo - $duration{$type};
	if ($type eq "COI" || $type eq "EDO" || $type eq "ROS" || $type eq "ROD" ) { #indeksowane inflacją
		if ($seriesYearFrom <= $CPIYearStart) {
			$CPIYearStart = $seriesYearFrom;
			if ($seriesMonth < $CPIMonthStart) { $CPIMonthStart = $seriesMonth; }
		}
	}
  }
  
  my ($nowDay, $nowMonth, $nowYear) = (localtime())[3,4,5];
	$nowMonth++;
	$nowYear += 1900;
	
  # CPI ogłaszana w m-cu ($seriesMonth-1) czyli de facto za m-c ($seriesMonth-2)
  # https://stooq.pl/q/d/l/?s=cpiypl.m&d1=20220901&d2=20220931&i=m&o=0101000&c=1
  my %CPIHash;
  #HTTP request
  unless ($CPIYearStart == 9999) {

	# pobierz ze Stooq, odfiltruj i zapisz

	my $ua = $quoter->user_agent;
    my $url = 'https://stooq.pl/q/d/l/?s=cpiypl.m&d1='.$CPIYearStart.sprintf("%02d",$CPIMonthStart).'01&d2='.$nowYear.sprintf("%02d",$nowMonth).'31&i=m&o=0101000&c=1';
	$debug = "$debug\nurl: $url";
    my $reply = $ua->request(GET $url);
    unless ($reply->is_success) {
	  foreach my $symbol (@symbols) {
		$stocks{$symbol, "success"}  = 0;
		$stocks{$symbol, "errormsg"} = "HTTP failure";
		return wantarray ? %stocks : \%stocks;
	  }
    }

    #my ($line) = split(/\n/, $reply->content, 1);
    my @lines = split(/\n/, $reply->content);
	
	foreach my $line (@lines) {
		#chomp($line);
	
		# Format:
		# Date;Open;High;Low;Close
		# 2022-09-30;17.2;17.2;17.2;17.2
		my ($date, $open, $high, $low, $last) = split ';', $line;
		unless ($date eq 'Data') { #unless 1st line
			my @dateArr = split '-', $date;
			my $dateShort = $dateArr[0].$dateArr[1];
			$CPIHash{$dateShort} = $last/100;
		}
	}
  }

  foreach my $symbol (@symbols) {
	$debug = "$debug\n$symbol";
	my ($type, $seriesMonth, $seriesYearTo, $seriesDay, $rateFirstYear, $rateNextYears) = ($symbol =~ /([A-Z]{3})(\d{2})(\d{2})-d(\d{2})-p(\d+\.\d+)(?:-i(\d+\.\d+))/);
	$rateFirstYear = $rateFirstYear / 100;
	$rateNextYears = $rateNextYears / 100;
	my $series = $type.$seriesMonth.$seriesYearTo; #e.g. 'EDO1131'
	$seriesYearTo += 2000; #e.g. '2031'
	my $seriesYearFrom = $seriesYearTo - $duration{$type};
#	my $dateTo = $year.$month.$day;
#	($day, $month, $year) = (localtime(time()-7*24*3600))[3,4,5];
#		$month++;
#		$year += 1900;
#	my $dateFrom = $year.$month.$day;
	my $yearsPassed = $nowYear - $seriesYearFrom; #how many full years have passed since series start
	if ( ($nowMonth < $seriesMonth) || ($nowMonth == $seriesMonth && $nowDay < $seriesDay) ) {
		$yearsPassed--;
	}

	my $dt1 = DateTime->new(year => $seriesYearFrom+$yearsPassed, month => $seriesMonth, day => $seriesDay); #series start
	my $dt2 = DateTime->new(year => $nowYear, month => $nowMonth, day => $nowDay); #today
	my $dt3 = DateTime->new(year => $seriesYearFrom+$yearsPassed+1, month => $seriesMonth, day => $seriesDay); #series 1st year end
	my $daysPassed = $dt2->delta_days($dt1)->delta_days(); #days passed until today
	my $daysInYear = $dt3->delta_days($dt1)->delta_days(); #days in the first year

	$debug = "$debug\nrates: $rateFirstYear / infl+$rateNextYears";
	$debug = "$debug\nyearsPassed: $yearsPassed";

	my $ileTeraz = 1;
	if ($yearsPassed == 0) {
		
		$ileTeraz = 1 + $rateFirstYear*($daysPassed/$daysInYear);
		
	} else {
		
		# TODO: domyślnie dolicza inflację, ale nie wszystkie bondy są inflacyjne!
		
		my $CPIJanFebCorrectionY = 0;
		my $CPIJanFebCorrectionM = 0;
		if ($seriesMonth < 3) { # dla obligacji ze stycznia/lutego odczyt CPI jest z poprz. roku
			$CPIJanFebCorrectionY = -1;
			$CPIJanFebCorrectionM = 12;
		}
		
		# w TOS/EDO/ROS/ROD odsetki co rok są kapitalizowane, a w in. nie! (są wypłacane)
		if ($type eq "TOS" || $type eq "EDO" || $type eq "ROS" || $type eq "ROD" ) {
			
			$ileTeraz = 1 + $rateFirstYear; #after 1 year
			$debug = "$debug\nilepo1: $ileTeraz";
			
			for (2..$yearsPassed) { #after next years
				$ileTeraz = $ileTeraz * (1 + $CPIHash{($seriesYearFrom+$_-1+$CPIJanFebCorrectionY).(sprintf("%02d",$seriesMonth-2+$CPIJanFebCorrectionM))}+$rateNextYears);
				$debug = "$debug\nCPIHash: ".($seriesYearFrom+$_-1+$CPIJanFebCorrectionY).(sprintf("%02d",$seriesMonth-2+$CPIJanFebCorrectionM));
				$debug = "$debug\nCPI: ".$CPIHash{($seriesYearFrom+$_-1+$CPIJanFebCorrectionY).(sprintf("%02d",$seriesMonth-2+$CPIJanFebCorrectionM))};
				$debug = "$debug\nilepo$_: $ileTeraz";
			}
		}

		# odsetki naliczone w bieżącym roku odsetkowym
		$ileTeraz = $ileTeraz * (1 + ($CPIHash{($seriesYearFrom+$yearsPassed+$CPIJanFebCorrectionY).(sprintf("%02d",$seriesMonth-2+$CPIJanFebCorrectionM))}+$rateNextYears)*($daysPassed/$daysInYear) );
		$debug = "$debug\nCPIHash: ".($seriesYearFrom+$yearsPassed+$CPIJanFebCorrectionY).(sprintf("%02d",$seriesMonth-2+$CPIJanFebCorrectionM));
		$debug = "$debug\nCPI: ".$CPIHash{($seriesYearFrom+$yearsPassed+$CPIJanFebCorrectionY).(sprintf("%02d",$seriesMonth-2+$CPIJanFebCorrectionM))};
		$debug = "$debug\nileTeraz: $ileTeraz";
		$debug = "$debug\ndaysPasseddaysInYear: ".($daysPassed/$daysInYear);
	}
	$ileTeraz = sprintf("%.2f", 100 * $ileTeraz ); #round to 2 decimal points
	
	$debug = "$debug\nileTeraz: $ileTeraz";

    # Format:
	$stocks{$symbol, 'symbol'}   = $symbol;
#	$quoter->store_date(\%stocks, $symbol, { isodate => $date });
	$quoter->store_date(\%stocks, $symbol, { today => 1 });
	$stocks{$symbol, 'method'}   = 'obligacje_sp';
	$stocks{$symbol, 'source'}   = 'Finance::Quote::ObligacjeSP';
	$stocks{$symbol, 'name'}     = $type.$seriesMonth.($seriesYearTo-2000);
	$stocks{$symbol, 'currency'} = 'PLN';
	$stocks{$symbol, 'last'}     = $ileTeraz;
	$stocks{$symbol, 'price'}    = $ileTeraz;
	$stocks{$symbol, 'debug'}    = $debug;
	$stocks{$symbol, 'success'}  = 1;
  }

  # Check for undefined symbols
  foreach my $symbol (@symbols) {
    unless ($stocks{$symbol, 'success'}) {
      $stocks{$symbol, "success"}  = 0;
      $stocks{$symbol, "errormsg"} = "Stock name not found";
    }
  }

  return %stocks if wantarray;
  return \%stocks;
}

1;

=head1 NAME

Finance::Quote::ObligacjeSP - Obtain prices of gov bonds

=head1 SYNOPSIS

    use Finance::Quote;

    $q = Finance::Quote->new;

    %stockinfo = $q->fetch("obligacje_sp","EDO0831-04"); # the letter ticker

=head1 DESCRIPTION

[todo]

=head1 BOND NAMES

[todo]

=head1 LABELS RETURNED

[todo]
date method source name currency price last

=head1 SEE ALSO

Gov Bonds website - https://www.obligacjeskarbowe.pl/
STOOQ website - https://stooq.com/ or https://stooq.pl/

=cut
