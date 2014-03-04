#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Term::ReadKey;
use Konami::EaGate;


my $eagate = Konami::EaGate->new;

if (test_login()) {
    check_course();
}


sub test_login {
    my $id = prompt("e-AMUSEMENT Username"); 
    my $password = prompt("e-AMUSEMENT Password", 1);


    say "Performing login..";
    if ($eagate->login($id, $password)) {
        say "Login Success!";
        return 1;
    } else {
        say "Failed to Login :(";
        return;
    }
}

sub check_course {
    if ($eagate->check_is_basic) {
        say "You are subscribed to e-AMUSEMENT Basic Course. :)";
    } else {
        say "You are not subscribed to e-AMUSEMENT Basic Course.";
    }
}

sub prompt {
    my ($message, $is_password) = @_;
    
    ReadMode 2 if $is_password;
    printf ("%s : ", $message);

    my $input = <STDIN>;
    chomp $input;
        
    ReadMode 0;
    print "\n" if $is_password;

    return $input;
}
