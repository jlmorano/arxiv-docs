#!/usr/bin/perl

use strict;
use warnings;

use constant BASEURL => 'https://arxiv.org/sword-app';

use LWP::UserAgent;
use Getopt::Long;
use File::MimeInfo::Magic;

my @required = qw(username password filename collection);
my @optional = qw(onbehalf mimetype md5 packaging verbose noop);

my %opt;
GetOptions (
	    'username=s'   => \$opt{username},
	    'password=s'   => \$opt{password},
	    'filename=s'   => \$opt{filename},
	    'collection=s' => \$opt{collection},
	    'onbehalf=s'   => \$opt{onbehalf},
	    'mimetype=s'   => \$opt{mimetype},
	    'packaging=s'  => \$opt{packaging},
	    'verbose'      => \$opt{verbose},
	    'md5'          => \$opt{md5},
	    'noop'         => \$opt{noop},
	   ) || die 'failed to process commandline options';


if (!defined $opt{username}) {
  print 'Enter username for "SWORD@arXiv": ';
  $opt{username} = <>;
  chomp $opt{username};
  defined $opt{username} || die "no user name specified\n";
}
if (!defined $opt{password}) {
  print "Password for $opt{username}: ";
  system('stty -echo');
  $opt{password} = <>;
  system('stty echo');
  print "\n\n";
  chomp $opt{password};
  defined $opt{password} || die "no password specified\n";
}

foreach (@required) {
  if (!defined $opt{$_}) {
    die "'$_' is required! Please specify --$_=... . Aborting.\n";
  }
}

# We strongly advise to always provide a meaningful User-Agent string and a
# contact email address in case of problems. Please customize/adapt the example
# below to your specifications.

my $ua = LWP::UserAgent->new;
$ua->agent('arXiv SWORD demo 1.1');
$ua->from('developer@example.com');

my $req = HTTP::Request->new(POST => BASEURL . "/$opt{collection}-collection");
$req->authorization_basic($opt{username}, $opt{password});

my $data;
open(my $FILE, '<', $opt{filename}) || die "couln't open '$opt{filename}' for reading: $!";
{
  local $/ = undef;
  $data = <$FILE>;
}
close $FILE || warn "couldn't close handle on '$opt{filename}' after reading: $!";
$req->content($data);

$opt{mimetype} ||= (mimetype($opt{filename}) || 'application/octet-stream');
$req->header('Content-Type' => $opt{mimetype});

if ($opt{verbose}) {
  $req->header('X-Verbose' => 'True');
}
if ($opt{noop}) {
  $req->header('X-No-Op' => 'True');
}
if ($opt{md5}) {
  require Digest::MD5;
  $req->header('Content-MD5' => Digest::MD5::md5_base64($data) . q{==});
}
if ($opt{onbehalf}) {
  $req->header('X-On-Behalf-Of' => $opt{onbehalf});
}
if ($opt{packaging}) {
  $req->header('X-Packaging' => $opt{packaging});
}

my $response = $ua->request($req);
if ($response->is_success()) {
  print "\nDeposit of '$opt{filename}' to arXiv was successful.\n",
    "The returned HTTP status and Location:\n\n",
      "Status:\t\t", $response->status_line(), "\n",
      "Location:\t", $response->header('Location'), "\n", q{-}x80, "\n\n";
  parse_response($response->content());
  if ($opt{verbose}) {
    print {*STDERR} "\n", q{*}x30, 'HEADERS', q{*}x30, "\n\n", $response->headers->as_string(), "\n",
      q{*}x30, 'CONTENT', q{*}x30,  "\n\n", $response->content(), "\n", q{*}x80, "\n\n";
  }
} else {
  print {*STDERR} "Deposit of '$opt{filename}' to arXiv encountered a problem.\n",
    'The returned status is: ', $response->status_line(), "\n\n";
  if ($opt{verbose}) {
    print {*STDERR} "\n", q{*}x30, 'HEADERS', q{*}x30, "\n\n", $response->headers->as_string(), "\n",
      q{*}x30, 'CONTENT', q{*}x30,  "\n\n", $response->content(), "\n", q{*}x80, "\n\n";
  }
  exit 1;
}

sub parse_response {
  my $xml = shift;
  require XML::Atom::Atompub;
  my $entry = XML::Atom::Entry->new(\$xml);

  print "The deposited media resource should be referenced as:\n\t",
    $entry->edit_media_link(),
      "\n\n";
  # for arXiv/SWORD this should be identical to $entry->content->src()
  return;
}

__END__

=head1 NAME

media-deposit.pl

=head1 SYNOPSIS

./sword-deposit.pl --filename=... --collection=... [--username=...] [--password=...] [optional arguments]

=head1 REQUIRED ARGUMENTS

There are 4 mandatory arguments for a media deposit to arXiv:

=over 5

=item --username=E<lt>...E<gt>  and  --password=E<lt>...E<gt>

Sword deposit requires B<username> and B<password> of a registered user with
submission privileges. If user credential are not supplied on the
commandline, they will be prompted for.

=item --collection=E<lt>...E<gt>

The B<collection> to which the deposit is being made must be specified. It
must be chosen from the list of collections in the servicedocument for the
user performing the deposit.

=item --filename=E<lt>...E<gt>

The name of the file to be deposited. The file must have one of the accepted
mime types listed in the servicedocument.

=back

=head1 OPTIONAL ARGUMENTS

Sword deposit accepts the following optional arguments:

=over 5

=item --onbehalf=E<lt>...E<gt>

The media deposit can be made B<on-behalf-of> another person, presumably the
author. The supplid string should contain the full name and email address of
the person in who's name the deposit is being made. In the common use case
this will be the corresponding author.

=item --mimetype=E<lt>...E<gt>

The mime type of the file which is deposited can be explicitly specified. It
must be from the list of accepted mime types.

=item --packaging=E<lt>...E<gt>

URI identifying a packaging format from the registered SWORD TYPES

=item --md5=E<lt>md5sumE<gt>

The B<base64 encoded MD5 sum> of the payload, i.e. the file to be deposited.

=item --noop

Specify B<noop> if you want to test a deposit but do not want to initiate any
further action on the SWORD server.

=item --verbose

Specify B<verbose> for verbose output of returned information, mostly for
debugging purposes.

=back

=head1 DEPENDENCIES

This script used B<LWP::UserAgent> for the HTTP(S) protocol interaction. It
requires B<File::MimeInfo::Magic> to determine the mime type of the media to
deposit, unless explicitly specified, and it uses B<Getopt::Long> for command
line option processing. The response to a media deposit is parsed with
B<XML::Atom::Atompub>, which itself relies on B<XML::LibXML> or
B<XML::XPath>.

=head1 CHOICE of XML PARSER

All response content is in the form of a B<Atom Entry> document. Thus most
Atom aware tools should be able to process the respoonse. Clearly it is also
well formed XML. Client Implementers are free to use XML Parsers of their
choice. In the subroutine B<parse_response> we demonstrate the use of the
Perl Module XML::Atom::Atompub, which internally uses XML::LibXML or
XML::XPath depending on availability, for extraction of link information.

=head1 BUGS AND LIMITATIONS

This script is intended as demo code, it should not be used for production
purposes. Note for example that exception handling is rudimentary.

=head1 SEE ALSO

L<http://arxiv.org/help/submit_sword>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 arXiv.org E<lt>www-admin@arxiv.orgE<gt>

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
