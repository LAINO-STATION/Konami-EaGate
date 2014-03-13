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
our @EXPORT  = qw/EA_PROTO EA_HOST EA_FULL_HOST EA_URL/;

our $VERSION = '0.1';  

sub EA_USER_AGENT () { "Mozilla/5.0 (X11; Linux) Firefox/23.0" }

sub EA_PROTO      () { "https" }
sub EA_HOST       () { "p.eagate.573.jp" }
sub EA_FULL_HOST  () { sprintf("%s://%s", EA_PROTO, EA_HOST) }

sub EA_URL        () { return
    {
        LOGIN       => EA_FULL_HOST.'/gate/p/login.html',
        CHARGE_INFO => EA_FULL_HOST.'/payment/mycharge.html', #과금 정보
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
    
    $self->_UA->default_header( Host => EA_HOST );
    
    return $self;
}

sub login {
    my ($self, $id, $password, $otp) = @_;
    
    chomp $id;
    chomp $password;
    
    my $res = $self->_UA->post(EA_URL->{LOGIN}, {
        KID  => $id,
        pass => $password,
        OTP  => $otp,
    });
    
    if ($res->code == 302) {
        while (1) {
            
            # 로그인 후 302 리다이렉트 반환 -> 
            # 리다이렉트를 200이 나올 때까지 계속 따라갑니다
            # ' ')/~ (접근접근
            
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
    if ($res->base =~ /login\.html/) {#uio
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
        # FIXME : HTML::TreeBuilder로 문서 파싱 후, look_down("_tag", "nocourse")로 찾으면 나오지 않았습니다.
        # 무언가 잘못된 것 같아 임시로 정규 표현식으로 대체하였습니다. 가까운 시일 내 HTML::TreeBuilder를 사용하는 쪽으로 돌리고 싶어요.
        
        #carp "e-AMUSEMENT 베이직 코스에 가입되어 있지 않은 계정입니다.";
        return;
    } else {
        return 1;
    }
    
}


sub get_cards {
    
}

########

sub _UA {
    my $self = shift;
    return $self->{_UA};
}

1;
