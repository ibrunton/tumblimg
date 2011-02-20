#!/usr/bin/env perl

use Modern::Perl;
use LWP::UserAgent;
use UI::Dialog::Backend::KDialog;
require HTTP::Request;

my $url = 'http://www.tumblr.com/api/write';

my $filename = shift( @ARGV ) || die();

my %form = ( 'type' => 'photo' );
my $k = new UI::Dialog::Backend::KDialog( backtitle => 'Default', title => 'Tumblr' );

my $rcfile = $ENV{HOME} . "/.tumblrrc";
if ( -s $rcfile ) {
    # get user email and password from rc file
    open( RC, $rcfile ) || die();
    while ( <RC> ) {
	next if ( $_ =~ m/^#/ || $_ =~ m/^$/ );
	if ( $_ =~ m/email=(.+@.+\..{2,4})/ ) { $form{email} = $1; }
	if ( $_ =~ m/password=(.+?)\s/ ) { $form{password} = $1; }
    }
    close( RC );
}
else { # prompt for them
    $form{email} = $k->inputbox( text => 'Enter your email address:' );
    $form{password} = $k->password( text => 'Enter your password' );
}

$form{title} = $k->inputbox( text => "Enter a title for the post:" ) || '';
$form{caption} = $k->inputbox( text => "Enter a caption for the photo:" ) || '';
$form{tags} = $k->inputbox( text => "Comma-separated list of tags:" ) || '';

my $ua = new LWP::UserAgent;
$ua->default_header( 'Content-Type' => 'form-data' );

my $buffer;
open( FILE, $filename ) || die();
binmode FILE;
while ( read( FILE, $buffer, 65536 ) ) {
    $form{data} .= $buffer;
}
close( FILE );

my $response = $ua->post( $url, \%form );

if ( $response->is_success ) {
    $k->msgbox( text => 'Successfully posted to Tumblr!' );
}
else {
    $k->sorry( text => $response->status_line . ':' . $response->content );
}

exit( 0 );

__END__;

=head1 NAME

tumblimg.pl

=head1 VERSION

1.0

=head1 SYNOPSIS

tumblimg.pl FILE

=head1 DESCRIPTION

tumblimg.pl is intended to be called from tumblimg.desktop, i.e., from
    the service menu in KDE's Konqueror or Dolphin file managers. It
    takes a single file name as its only argument, and then prompts
    the user for further information via kdialog.

=head1 DEPENDENCIES

tumblimg.pl requires the following libraries:
    Modern::Perl;
    LWP::UserAgent;
    UI::Dialog::Backend::KDialog;
    HTTP::Request;

=head1 AUTHOR

Written by Ian D. Brunton

=head1 REPORTING BUGS

Report bugs to wolfshift@gmail.com

=head1 COPYRIGHT

Copyright 2011 Ian D. Brunton

This file is part of Log.

Log is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Log is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Log.  If not, see <http://www.gnu.org/licenses/>.

=cut  

