package Konami::Games::PopnMusic;
use 5.010;
use strict;
use warnings;

use Konami::EaGate;
use Konami::Games::PopnMusic::PopTomo;

use HTML::TreeBuilder;
use Carp;

use Exporter;

our @ISA        = qw/Exporter/;
our @EXPORT_OK  = qw/poptomo_list is_poptomo_registered/;

our $VERSION = "SunnyPark-0.1";


sub POPN_SP_URL_BASE() { EA_FULL_HOST."/game/popn/21/p" }
sub POPN_SP_URL() { return 
    {
        
        SELF_STATUS   => POPN_SP_URL_BASE.'/status/index.html',
        SELF_MUSIC    => POPN_SP_URL_BASE.'/status/mu_top.html',
        SELF_BIRTHDAY => POPN_SP_URL_BASE.'/status/birth.html',
        
        #팝토모
        POPTOMO_LIST => POPN_SP_URL_BASE.'/p_friend/index.html',
        POPTOMO_ADD  => POPN_SP_URL_BASE.'/p_friend/index.html?add=true', #POST : {gpmid => 팝토모 번호},
        POPTOMO_DEL  => POPN_SP_URL_BASE.'/p_friend/clear.html', #GET: {no : 팝토모}
       
        #팝토모 정보
        POPTOMO_INFO => POPN_SP_URL_BASE.'/p_friend/p_data.html', #GET : {no : 6} #팝토모 목록의 그 번호
        POPTOMO_VS   => POPN_SP_URL_BASE.'/p_friend/vs.html', #ALL : {page: 0, version: 0, search: 1 (default?) , id: 팝토모 번호}
    }
}

# 자기 자신의 정보 #


# 팝토모 관련 #

sub poptomo_list {
    
    # 팝토모 목록을 반환합니다.
    
    my $eagate = shift;
    my @poptomo_list;
    
    my @tr = _fetch_poptomo_list($eagate);
    
    for (@tr) {
        my @td;
        push @td, $_->as_text for $_->find('td');
        
        
        if (my $poptomo = Konami::Games::PopnMusic::PopTomo->new_from_td(\@td)) {
            push @poptomo_list, $poptomo;
        }
    }
    
    return @poptomo_list;
}

sub is_poptomo_registered {
    
    # 팝토모 등록 여부를 확인합니다.
    # 등록되어 있을 경우 그 index를 반환합니다.
    # 등록되어 있지 않으면 undef를 반환합니다.
    
    my ($eagate, $id) = @_;
    
    my @poptomo = map { $_->id } poptomo_list($eagate);
    return grep { $poptomo[$_] eq $id } 0..$#poptomo;
    
}

sub add_poptomo {

    # 현재 계정에 팝토모를 추가합니다.
    
    my ($eagate, $poptomo) = @_;
    
    
    
}

sub remove_poptomo {
    
    # 팝토모를 제거합니다.
    
}



sub _fetch_poptomo_list {
    my $eagate = shift;
    
    my $res  = $eagate->_UA->get(POPN_SP_URL->{POPTOMO_LIST});
    croak "팝토모 목록을 받아올 수 없었습니다." unless $res->is_success;
    
    my $tree = HTML::TreeBuilder->new_from_content($res->decoded_content);
    my @tr   = $tree->look_down(
        _tag => 'table',
        id   => 'po_list_table'
    )->look_down(
        _tag => 'tr',
        
        #테이블 헤더(th 태그)를 무시합니다.
        sub { !$_[0]->find('th') },
    );
    
    return @tr;
}


"ミミ＆ニャミ「オッケー!」";