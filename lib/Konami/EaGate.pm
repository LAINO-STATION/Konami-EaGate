package Konami::EaGate;
use 5.010;
use strict;
use warnings;

use HTTP::Cookies;
use HTML::TreeBuilder;
use LWP::UserAgent;
use Carp;

use Exporter;

our @ISA     = qw/Exporter/;
our @EXPORT  = qw/EA_URL/;

our $VERSION = '0.1';  

sub EA_USER_AGENT () { "Mozilla/5.0 (X11; Linux) Firefox/23.0" }
sub EA_URL        () { return
    {
        HOST  => 'p.eagate.573.jp',
        LOGIN => 'https://p.eagate.573.jp/gate/p/login.html',
        
        #과금 정보
        CHARGE_INFO => 'https://p.eagate.573.jp/payment/mycharge.html',
    } 
}

sub new {
    my $class = shift;
    
    my $body = {
        _UA => LWP::UserAgent->new( 
            agent      => EA_USER_AGENT,
            cookie_jar => HTTP::Cookies->new( hide_cookie2 => 1 ),
        ),
    };
    
    my $self = bless $body, $class;
    
    $self->_UA->default_header( Host => EA_URL->{HOST} );
    
    return $self;
}

sub login {
    my ($self, $id, $password, $otp) = @_;
    
    my $res = $self->_UA->post(EA_URL->{LOGIN}, {
        KID  => $id,
        pass => $password,
        OTP  => $otp,
    });
    
    if ($res->code == 302) {
        while (1) {
            my $next = $res->header('Location');
            
            $res = $self->_UA->get($next);
            if ($res->code != 302) {
                last;
            }
        }
    } else {
        carp "EAGate 로그인에 실패하였습니다. 계정 정보가 올바른지 확인해 주십시오.";
        return;
    }
    
    unless ($self->check_login) {
        croak "알 수 없는 이유로 EAGate 로그인에 실패하였습니다.";
    } else {
        return 1;
    }
}

sub logout {
    
}

sub check_login {
    my $self = shift;
    
    my $res = $self->_UA->get(EA_URL->{CHARGE_INFO});
    if ($res->base =~ /login\.html/) {
        return 0;
    } else {
        return 1;
    }
}

sub check_is_basic {
    #EAGate 베이직 코스 유저인지 확인합니다.
    my $self = shift;
    
    my $res = $self->_UA->get(EA_URL->{CHARGE_INFO});
    croak "e-AMUSEMENT 베이직 코스 가입 여부 확인에 실패하였습니다." unless $res->is_success;
    
    if ($res->decoded_content =~ m/<nocourse>/) {
        #carp "e-AMUSEMENT 베이직 코스에 가입되어 있지 않은 계정입니다.";
        return;
    } else {
        return 1;
    }
    
}

########

sub _UA {
    my $self = shift;
    return $self->{_UA};
}

1;
