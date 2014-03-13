package Konami::Games::PopnMusic::PopTomo;

use utf8;

use 5.010;
use strict;
use warnings;

sub new {
    my ($soul, %args) = @_;
    my $body = {
        # 그냥 %args 그대로 넣어버리면 좋겠지만 왠지 위험해 보여..
        name   => $args{name},
        id     => $args{id},
        active => $args{active},
    };
    
    # 뭔가 프로그램으로 인체연성 하는 것 같은 느낌이야(
    my $self = bless $body, $soul;
    
    return $self;
}

sub new_from_td {
    my $class = shift;
    my @td    = @{(shift)}; 
    
    return undef if $td[1] eq "未設定";
    
    my $body = {
        name   => $td[1],
        id     => $td[2],
        active => ( $td[3] eq "ACTIVE" ) ? 1 : 0, 
    };
    
    my $self = bless $body, $class;
    
    return $self;
}

sub name {
    my $self = shift;
    return $self->{name};
}

sub id {
    my $self = shift;
    return $self->{id};
}

sub active {
    my $self = shift;
    return $self->{active};
}

1;