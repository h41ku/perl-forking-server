use strict;
use warnings;
use IO::Socket;
#use Socket qw(:all);
use Time::HiRes qw(time); # this is used for generation of ETag

$| = 1; # turn off buffering

#
# set up handlers for system signals
#

use POSIX qw(:sys_wait_h);

$SIG{CHLD} = 'IGNORE'; # ignore SIGCHLD

#
# set up the socket SERVER, bind and listen ...
#

my $port = 5000;
socket(SERVER, PF_INET, SOCK_STREAM, getprotobyname('tcp'))
    or die "Can't create server socket: $!\n";
setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, 1);
my $paddr = sockaddr_in($port, INADDR_ANY);
bind(SERVER, $paddr)
    or die "Can't bind to port: $!\n";
listen(SERVER, SOMAXCONN);
#setsockopt(SERVER, IPPROTO_TCP, TCP_NODELAY, 1); # to send buffer writes to the kernel as soon as an event occurs

#
# main loop
#

#while (1) {

my $num_req = 0; # counter for requests
print "$$ >> master\r\n";

my $pid;
my $hisaddr;
while ($hisaddr = accept(CLIENT, SERVER)) { # wait for connections
    # forking for each accepted connection
    next if $pid = fork; # is parent
    die "fork: $!" unless defined $pid; # fail to fork
    # otherwise is child
    close(SERVER); # it not used by child

    my $etag = sprintf('idx.%.09lf', time());
        # in a case of this script this form of ETag is not weak,
        # because the response fully depends of this value

    my $data;
    my $count = sysread(CLIENT, $data, 1024);
    print "$$ >> recv $count bytes\n";
    #print $data;
    my $response = "HTTP/1.1 200 OK\r\n"
        . "Host: 127.0.0.1:$port\r\n"
        . "Content-Type: text/plain; charset=utf-8\r\n"
        . "Etag: \"$etag\"\r\n" # strong ETag
        #. "Connection: close\r\n"
        . "\r\n"
        . "Powered by Perl!\r\n"
        . "Digest: $etag\r\n"
    ;
    $count = syswrite(CLIENT, $response);
    print "$$ >> sent $count bytes\n";
    #print $response;

    #print "$$ >> close\r\n";
    exit; # child leaves
    #print "$$ >> child fail\n";
} continue { 
    print "$$ >> close\r\n";
    close(CLIENT); # is not used by parent any more
    $num_req ++; # increase number of requests
    print "$$ >> handled: $num_req requests\r\n";
}

#   print "$$ >> Unexpected error: $!\n";
#   print "$$ >> \$hisaddr: ", (! defined $hisaddr ? 'undef' : $hisaddr), "\n";
#}
