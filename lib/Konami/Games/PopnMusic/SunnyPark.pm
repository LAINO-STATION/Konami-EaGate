package Konami::Games::PopnMusic::SunnyPark;
use 5.010;
use strict;
use warnings;

use Konami::EaGate;
use HTML::TreeBuilder;
use Carp;

use Exporter;

our @ISA    = qw/Exporter/;
our @EXPORT = qw/POPN_SP_URL/;

sub POPN_SP_URL() { return 
    {
        POPTOMO_LIST => 'http://p.eagate.573.jp/game/popn/21/p/p_friend/index.html',
        POPTOMO_ADD  => 'http://p.eagate.573.jp/game/popn/21/p/p_friend/index.html?add=true', #POST : {gpmid => 팝토모 번호},
        POPTOMO_DEL  => 'http://p.eagate.573.jp/game/popn/21/p/p_friend/clear.html', #GET: {no : 팝토모}
       
        #팝토모 정보
        POPTOMO_INFO => 'http://p.eagate.573.jp/game/popn/21/p/p_friend/p_data.html', #GET : {no : 6} #팝토모 목록의 그 번호
        POPTOMO_VS   => 'http://p.eagate.573.jp/game/popn/21/p/p_friend/vs.html', #ALL : {page: 0, version: 0, search: 1 (default?) , id: 팝토모 번호}
    }
}


"ミミ＆ニャミ「オッケー!」";
