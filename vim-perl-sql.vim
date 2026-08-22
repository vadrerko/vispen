" VIM Perl and SQL support  \t<F6>
" . <<'###'; # vim:syntax=perl

" VIM script file; heavily uses Perl, so VIM must be with +perl; see :ver
"
" TODO
" - use Term::Table for sql formatting in tables
" - syntax for =sql/=cut, =perl/cut
" - when text is selected, execute selected text and show it in echo/VIM::Msg

  amenu Perl&5.-sep2-  :<CR>
  amenu Perl&5.&config.$vim::anchorp.0	:perl $vim::anchorp=0<CR>
  amenu Perl&5.&config.$vim::anchorp.1	:perl $vim::anchorp=1<CR>
  amenu Perl&5.&config.$vim::untemplatep.0	:perl $vim::untemplatep=0<CR>
  amenu Perl&5.&config.$vim::untemplatep.1	:perl $vim::untemplatep=1<CR>
  amenu Perl&5.&config.$vim::width.123	:perl $vim::width=123<CR>
  amenu Perl&5.&config.$vim::width.246	:perl $vim::width=246<CR>
  amenu Perl&5.&config.$vim::title_rows.1	:perl $vim::title_rows=1<CR>
  amenu Perl&5.&config.$vim::title_rows.10	:perl $vim::title_rows=10<CR>
  amenu Perl&5.&config.$vim::title_rows.99	:perl $vim::title_rows=99<CR>
  amenu Perl&5.&config.tell\ method\.\.\..message\ line	:perl set_tell_method(1)<CR>
  amenu Perl&5.&config.tell\ method\.\.\..win32\ msgbox	:perl set_tell_method(2)<CR>
  amenu Perl&5.&config.tell\ method\.\.\..tk\ msgbox	:perl set_tell_method(3)<CR>
  amenu Perl&5.-sep3-   :<CR>
  amenu Perl&5.untemplate<Tab><F8>     :perl tt_untemplate()<CR>
  amenu Perl&5.untemplate\ (1)<Tab>A-y  :perl tt_untemplate(1)<CR>
  amenu Perl&5.-sep4-   :<CR>
  amenu Perl&5.execute_here<Tab>F9      :perl execute_here()<CR>
  amenu Perl&5.execute_here(1)<Tab>S-F9      :perl execute_here(1)<CR>
  tmenu Perl&5.execute_here(1) Executes current line but also reconnects to DB (prepends contents of variable $reset for this (normally it is 'undef $dbh'))
  amenu Perl&5.execute_here(2)<Tab>A-F9      :perl execute_here(2)<CR>
  tmenu Perl&5.execute_here(2) Executes multiline SQL
  amenu Perl&5.execute_here(5)<Tab>F7      :perl execute_here(5)<CR>
  tmenu Perl&5.execute_here(5) Executes current line as perl
  amenu Perl&5.-sep5-   :<CR>
  amenu Perl&5.delete_this_from_r            :perl delete_this_from_r()<CR>
  amenu Perl&5.suggest_columns<Tab>Esc-c            :perl suggest_columns()<CR>

  map <F8> <Esc>:perl tt_untemplate()<CR>
  map <A-y> <Esc>:perl tt_untemplate(1)<CR>
  map <F9> <Esc>:perl execute_here()<CR>
  imap <F7> <Esc>:perl execute_here(5)<CR>
  map <F7> <Esc>:perl execute_here(5)<CR>
  imap <F9> <Esc>:perl execute_here()<CR>
  map <S-F9> <Esc>:perl execute_here(1)<CR>
  imap <S-F9> <Esc>:perl execute_here(1)<CR>
  map <A-F9> <Esc>:perl execute_here(2)<CR>
  imap <A-F9> <Esc>:perl execute_here(2)<CR>
  map <A-c> <Esc>:perl suggest_columns()<CR>
  map <Esc>c <Esc>:perl suggest_columns()<CR>

  perl << EOSVIM
    VIM::Msg("SQL-perl-vim routines loaded");
###
# version 1.8

use strict;
use utf8;
use List::Util();
use Time::HiRes();
use POSIX();
use Text::Template();


my $tell_method=1; sub set_tell_method{$tell_method=shift}

sub xxxxxxxxx {
    my ($row,$col) = $::curwin->Cursor;
    my @text = $::curbuf->Get($row .. $::curbuf->Count());
    for my $i (0 .. $#text) { for ($text[$i]) {
	if (/^something/) {
	}
    } }
    VIM::Msg("qwerty");
}

sub tell_us {
    my $msg = shift;
    if ($tell_method==1) {
	VIM::Msg($msg);
    } elsif ($tell_method==2) {
	require Win32;
	Win32::MsgBox($msg);
    } elsif ($tell_method==3) {
	require Tcl::Tk;
	my $i = new Tcl::Tk;
	$i->tk_messageBox(-message=>"$msg");
    }
    #if ($^O eq 'MSWin32') {
    #}
}

sub tt_untemplate {
    my $pre = shift ? "$::reset":"";
    my $bufname = $::curbuf->Name();
    my $fn0 = $bufname=~/^(.*)\.in$/i ? $1 : "$bufname.untempl";
    _untemplate($bufname, $pre);
    tt_open_or_switchto("$fn0",1);
}

## ------------------------------------------------------- ##
# given file with 'templated' text with Text::Template - 'un'-template it
sub _untemplate {
    my ($fn, $pre) = @_;
    my $fn0 = $fn=~/^(.*)\.in$/i ? $1 : "$fn.untempl";
    $pre //= '';

    require Path::Class;
    my $s = Path::Class::file($fn)->slurp(iomode=>'<:encoding(UTF-8)')  =~
	s/\{:(\w+)\}/\$VAR='$1';\$VAR_$1 = <<'_EOS_$1';\n/gr   =~
	s/\{\/(\w+)\}/\n_EOS_$1\n/gr               =~
	s/\{\*(\w+)(\+*)\}/
	  my $cnt=length($2);
	  ("Text::Template::fill_in_string(" x $cnt ) .
	    "\$VAR_$1" .
	  ")" x $cnt /ger
	=~ s/^=(?:sqlm?|perl)\b.*?(?:(?:^=cut *\n)|\Z)//sigrm
	=~ s/^=(?:ignore_everywhere|ie|sqlm?|Sqlm?|sQlm?|sqLm?|sQLm?|perl|Perl|pErl|PERL)\b.*?(?:(?:^=cut *\n)|\Z)//sgrm
    ;
    my @delims = $s=~/^(\{\{\{?)/ ? (DELIMITERS=>[$1,'}'x length($1)]) : (); # delimiters {{{...}}} or {{...}} or none/default
    if ($pre) {
        if (@delims){$pre="$delims[1]->[0]$pre$delims[1]->[1]"}else {$pre="{$pre}"}
	VIM::Msg("pre=$pre");
    }
    $s = Text::Template->new(
            TYPE   =>'STRING',
            SOURCE => $pre . $s,
            @delims,
        )->fill_in();
    Path::Class::file($fn0)->spew(iomode=>'>:encoding(UTF-8)', $s =~s/^\\\r?\n//grm);

}

## ------------------------------------------------------- ##
# given FN, open it in VIM, but switch to it if its already in tabs
my %syntaxes = qw(c c maclib asm asm asm390 rexx rexx jcl jcl);
sub tt_open_or_switchto {
    my $bufn = shift;
    my $bufn0 = $bufn=~s"#"\\#"rg;
    my $newt = shift;

    my $bcur = $::curbuf;
    VIM::DoCommand("tablast");
    my $blast = $::curbuf;
    VIM::DoCommand("tabfirst");
    my $bfirst = $::curbuf;

    for (;;) {
	my $bcur1 = $::curbuf;
	if ($bcur1->Name eq $bufn) {
	    # ok we're here
	    VIM::DoCommand("checktime");
	    return;
	}
	if ($blast->Name eq $bcur1->Name) {
	    # not found; need to create
	    last;
	}
	VIM::DoCommand("tabnext");
    }
    if ($newt) {
        VIM::DoCommand("tabnew $bufn0");
    } else {
        VIM::DoCommand("open $bufn0");
    }
    # syntax, based on ext
    if (lc($bufn)=~/\.(\w+)$/){if(exists $syntaxes{$1}){VIM::DoCommand("set syn=".$syntaxes{$1})}}
}

sub suggest_columns {
    my ($row,$col) = $::curwin->Cursor;
    my $cline = $::curbuf->Get($row);
    my ($tablename) = substr($cline,$col) =~ /^([\w.]+)/;
    my $base = undef;
    $base = $1 if $tablename=~s/^(\w+)\.//;
    die "what table?" unless $tablename;
    my $sth = $::dbh->column_info(undef, $base, $tablename, "%") or die "can't column_info: " . $::dbh->errstr();
    my $cols = $sth->fetchall_arrayref() or die "can't fetchall - column_info: " . $::dbh->errstr();
    my $res = join ', ', map {$_->[3]} @$cols;
    if ($res) {
        $::curbuf->Append($row, $res);
    } else {
        VIM::Msg("empty column info for table [$tablename] base [".($base//'current')."]", 'error');
    }
}

sub delete_this_from_r {
    my ($row,$col) = $::curwin->Cursor;
    my $cline = $::curbuf->Get($row);
    delete $::r{$cline}
}


sub __vypcol {
    my ($names, $aref) = @_;
    # remove columns listed in $vim::ignore_cols
    for my $vypcol (split /,/, $vim::ignore_cols) {
        my $x = List::Util::first {$names->[$_] eq $vypcol} 0 .. $#$names;
        if (defined $x) {
            splice @$names, $x, 1;
            splice @$_,$x,1 for @$aref;
        }
    }
}

sub __append {
    my ($row,$s) = @_;
    for (split "\n", $s) {
	$::curbuf->Append($row, "$_");
	VIM::DoCommand("normal j");
	$row++;
    }
    return $row;
}

$vim::width //= 123;
$vim::respect_title_width //= 0; # TODO NYI - fit title rows
$vim::title_rows //= 99; # max number of rows in table title

$vim::anchorp //= 0;
$vim::untemplatep //= 1;
$vim::ignore_cols //= '';
$vim::mariadb //= 'MariaDB';
$vim::html_save_to //= 'tab.html';

sub execute_here {
    my $arg = shift || 0;
    # run current line
    my ($row,$col) = $::curwin->Cursor;
    my $row0=$row;

    my $cmd = $::curbuf->Get($row);

    if ($cmd =~ m/^([?c]?)( *)$/) {
	# if empty line - then suggest something to user
	if ($row>0) {$row--}
	if ($1 eq '?') {
	    $row = __append($row, <<'EOS');
# press <F9> on empty line to get predefined lines for $::dbh initialization
# or on a line containing only '?' to get this help
# or on a line containing only 'c' to get config which you could edit
EOS
	} elsif ($1 eq 'c') {
            my $e = '';
	    $row = __append($row, <<"EOS");
$e\$vim::untemplatep  = $vim::untemplatep; # perform in-memory untemplate of lines before cursor?
$e\$vim::width        = $vim::width;  # table width
$e\$vim::anchorp      = $vim::anchorp; # add anchor with elapsed time after each request
$e\$vim::title_rows   = $vim::title_rows; # max number of rows in table title
$e\$vim::ignore_cols  = '$vim::ignore_cols'; # columns to ignore, coma separated list
$e\$vim::html_save_to = '$vim::html_save_to'; # file name where HTML output is to be saved
EOS
	} else {
	    $row = __append($row, $vim::initial_lines || <<'EOS');
{{{ # vi: syn=perl
# here perl code executed each time on executionn for 'untemplate' phase - but
# if $vim::untemplatep glag is ON
unless ($dbh) {
    use DBI;
    # next line will store into $::dbh, because untemplating is no strict,
    $dbh = DBI->connect("dbi:SQLite:dbname=try-1.sqlite","","");
    #... whereas single-line F7 exec is strict, as well as =perl/=Cut, etc., but =PERL/=Cut is again no-strict.
}
''
}}}\
=ie

# for <F7> - perl execution:
undef $::dbh
VIM::Msg('abcd','Comment')
VIM::Msg('efgh','ErrorMsg')

use DBI; $::dbh = DBI->connect("dbi:SQLite:dbname=try-1.sqlite","","");

# config:
$vim::untemplatep = 0
$vim::width = 123;

# for <F9> - SQL execution:
select 1 as n
=cut

select "a" a,"b" as b union all select 'Peter','{{{"a"x1000}}}'

below is 'crazy'-generated SQL:
=Sql g/f=+
{{{join " union all\n", map {"select 'value $_' as v,".++$::cnt } 'a'..'rz'}}}
=Cut

=Sql
WITH RECURSIVE generate_series(value) AS (
    SELECT 1 
    UNION ALL 
    SELECT value + 1 FROM generate_series WHERE value < 100
)
SELECT value FROM generate_series
=Cut

=perl
use Data::Dumper; Dumper \%::r
=Cut
EOS
            VIM::DoCommand("set syn=perl");
	}
	return;
    }

    if ($vim::untemplatep) {
	# get lines before current point to 'untemplate'
	my $pretext = join "\n", $::curbuf->Get(0 .. $row-1);
	$pretext =~ s/^=(?:sqlm?|perl)\b.*?(?:(?:^=cut *\n)|\Z)//sigm; # do not untemplste =sql/=perl ... =cut
	$pretext =~ s/^=(?:ignore_everywhere|ie|sqlm?|Sqlm?|sQlm?|sqLm?|sQLm?|perl|Perl|pErl|PERL)\b.*?(?:(?:^=cut *\n)|\Z)//sgm;
	$Text::Template::ERROR = '';
	my ($del0, $del1, @delims) = ('{','}');   # delimiters {{{...}}} or {{...}} or none/default
	if ($pretext=~/^(\{\{\{?)/) {
	    $del0 = $1;
	    $del1 = '}'x length($1);
	    @delims = (DELIMITERS=>[$del0, $del1]);
	}
	my $dummy_s = Text::Template->new(
	    TYPE   => 'STRING',
	    SOURCE => ($arg==1?"$del0$::reset$del1":($arg==100?"$del0$::super_reset$del1":"")) . $pretext,
	    @delims,
	    BROKEN => sub{die "error in template: [$Text::Template::ERROR] \$@=$@, please recheck!"},
	)->fill_in();
	if ($Text::Template::ERROR) {
	    VIM::Msg("\$Text::Template::ERROR=[$Text::Template::ERROR]","ErrorMsg");
	    return;
	}
    }

    #=sql
    #select {{{1+1}}}
    #=cut
    #{code:sql}
    #select 2
    #{code}
    #||2||
    #|2|

    #=sql name/f=j
    #select {{{1}}}
    # --!!! <-- even not shown in {code:sql}...{code} (super-invisible comments)
    #=cut
    #{code:sql}
    #select 1
    #-- 1
    #{code}
    #||1||
    #|1|

    #=ie
    # ...
    # =ie/=ignore-everywhere will not be shown in the untemplated result
    #=sql name/f=-
    #select {{{1}}} {{{" union all select 2" x 100}}}
    #=Cut
    #{code:sql}
    #select 1  union all select 2 union all select 2.......
    #{code}
    #-- 101 rows
    #...
    #=cut

    my $jira_syntax=0;
    my $x0 = List::Util::first {$::curbuf->Get($_) =~ /^(?:(?: *$)|\}|=)/} reverse 1 .. $row;
    my $x1 = $row;
    my $sqlname = '';
    my ($ifperl, $perlnostrict, $perlshowcode, $perluntemplate) = (($arg==5?1:0),0,0,0);
    my ($ifsqlselect,$ifsql1) = (0,0);
    my ($ifsqlmulty) = (0);
    my $need_remove_old = 1;

    if (defined $x0 && $::curbuf->Get($x0) =~ /^=(sqlm?|Sqlm?|sQlm?|sqLm?|sQLm?|perl|Perl|pErl|PERL)\b\s*(.*?)\s*$/) {
        # sqL, sQL - so to avoid jirasyntax
        # sQl, sQL - $::dbh1
        # pErl - untemplate then perl
        # PERL - same as perl but in 'no strict;' mode
        my $verb=$1;
        $ifperl = lc($verb) eq 'perl' ? 1 : $ifperl;
        $perlshowcode = $verb eq 'Perl' || $verb eq 'pErl';
        $perluntemplate = $verb eq 'pErl';
        $perlnostrict = $verb eq 'PERL';
        if (lc($verb) eq 'sqlm') {$ifsqlmulty=1;$ifsqlselect=1;$verb=substr($verb,0,3);}
        $ifsqlselect = 1 if $verb eq 'Sql';
        $ifsql1 = 1 if ($verb eq 'sQl' or $verb eq 'sQL' );
        $jira_syntax = $ifperl ? 0 : ($verb ne 'sqL' and $verb ne 'sQL');
        $sqlname = $2=~s/\s.*$//r; # after space there could be comment - strip it
        $x1 = List::Util::first {
                $::curbuf->Get($_) =~ /^=cut/i
            } $row+1 .. $::curbuf->Count();
        die "no =cut but =sql!" unless defined $x1;
        $cmd = join("\n",$::curbuf->Get($x0+1 .. $x1-1));

        # remove from $x1+1 until /^\s*$/ or EOF or next =something or '{{{'
        while ($x1+1 <= $::curbuf->Count() && $::curbuf->Get($x1+1) !~ /^(?:(?: *$)|=|\{\{\{)/) {
            $::curbuf->Delete($x1+1);
        }
        $need_remove_old = 0;
    }
    elsif ($arg==2) {
        # $cmd is up to '' down to '' or /^--/
        $x1 = List::Util::first {
                $::curbuf->Get($_) =~ /^(?:\||(?: *$)|=|--|\}|\(:|[┌╞└│])/
            } $row+1 .. $::curbuf->Count();
        $x1 = $::curbuf->Count() unless defined $x1;
        $cmd = join("\n",$::curbuf->Get((defined $x0?$x0+1:$row) .. $x1-1));
        $x1--;
        $row=$x1;
    }
    
    my $lid = $sqlname =~ s/\/lid=(\w+)\b// ? $1 : '';

    $cmd =~ s/^ *--!.*(?:\n|\Z)//mg unless $ifperl; # remove super-invisible-comments

    # remove old 'answer' lines - they-are all prefixed with -- or with MariaDB [...] or /?what else?/
    while ($need_remove_old && $::curbuf->Get($row+1) =~ /^(?:--|\||\(:|MariaDB \[|[┌╞└│])/) { # TODO utf8 for ┌╞└│
        my $r = $::curbuf->Get($row+1);
        $::curbuf->Delete($row+1);
    }

    ## run the task
    my $cmd1 = $ifperl? $perluntemplate ? Text::Template::fill_in_string($cmd, ENCODING=>'UTF8',DELIMITERS=>['{{{','}}}']) : $cmd
                      : $cmd=~/^---#(.*)$/ ? $1 : 
                        Text::Template::fill_in_string($cmd, ENCODING=>'UTF8',DELIMITERS=>['{{{','}}}']);
    my $cmd1_sav = $cmd1;

    my $precmd1 = $sqlname =~ /^#/ ? "$::sqlcnt. ":'';

    # now put several lines prefixing these with ||
    if ($jira_syntax) {
        my $x10=$x1;
        $::curbuf->Append($x1++, "{code:sql|borderColor=#00DD00}");
        for(split(/\n/,$precmd1.$cmd1)){$::curbuf->Append($x1++, $_);}
        $::curbuf->Append($x1++, "{code}");
        VIM::DoCommand("normal ${x10}Gjzf".($x1-$x10-1)."jzok");
    } else {
        if (!$perluntemplate and $cmd1_sav ne $cmd) { # if untemplated has changed
            for(split(/\n/,$precmd1.$cmd1)){$::curbuf->Append($x1++, "---$_");}
        }
    }

    my $t0 = [Time::HiRes::gettimeofday()];
    my $dbh = $ifsql1 ? $::dbh1 : $::dbh;
    my $res='';
    if ($ifperl) {
        $res = ($perlshowcode ? "{code:perl|borderColor=#0000DD}\n".($cmd1=~s/^.*?###.*?(?:\n|\Z)//grm=~s/^\{code[^{}]*\} *\n//grm=~s/\n+$//r)."\n{code}\n{code:none}\n": '') .
            (eval ''.($perlnostrict ? "no strict;" : "") . $cmd1) .
            ($perlshowcode ? "{code}\n": '');
        if ($@) {$res.="ERROR: [$@]\n"}
        my $elapsed = Time::HiRes::tv_interval($t0, [Time::HiRes::gettimeofday()]);
        $res .= "{anchor:perl_xxx_$elapsed}\n" if $vim::anchorp;
    } elsif (substr($cmd1,0,1) eq '#') {
	# do nothing. TODO: document this!
    } elsif ($ifsqlselect || $cmd1=~/^(?:explain\s*)?(select|show|with|values)/i) {
        my $fe_cmd=$1;
        if ($sqlname eq '' and $cmd1=~/^select\s*\/\*([\w\-!\/\=+]+)\*\//i) {$sqlname=$1}
        my $format = ($jira_syntax || $fe_cmd eq 'Select' || $fe_cmd eq 'Show') ? 'j'
            : $fe_cmd eq 'sElect' ? 'T' : $fe_cmd eq 'seLect' ? 't' : $fe_cmd eq 'selEct' ? 'h'
            : $fe_cmd eq 'seleCt' ? 'x' : '+';
        if ($sqlname =~ s/\/f=([\w+\-])$//) {$format=$1}
        my $fv = {
                h=>["<table><tr><th>",'</th><th>','</th></tr>','<tr><td valign="top">','</td><td valign="top">','</td></tr>',"</table>\n"],
                O=>["(:table border=\"1\":)\n(:row:)(:hcell:)",'(:hcell:)','','(:row:)(:cell align=left:)','(:cell align=left:)','',"\n(:tableend:)"],
                o=>['||','||','||','||','||','||',''],
                j=>['||','||','||','|','|','|',''],
                t=>['-- ',',','','--',',','',''],
                T=>['-- ',"\t",'','--',"\t",'',''],
            } -> {$format};

        my @cmd2 =  ($ifsqlmulty ? split("/\\*\\*/\n",$cmd1) : ($cmd1));
        for my $cmd2 (@cmd2) {
            my $sth = $dbh->prepare($cmd2) or die "can't prepare [$cmd2]: " . $dbh->errstr();
            $sth->execute() or die "can't execute [$cmd2]: " . $sth->errstr();
            my @names = @{$sth->{NAME} || []};
            my $aref = ($dbh->errstr?[]:$sth->fetchall_arrayref()) or die "can't fetchall [$cmd2]: " . $sth->errstr();
            __vypcol(\@names,$aref) if $vim::ignore_cols;
            if ($format eq '+') {
		# TODO: use Term::Table
                my @w = map {
                        my $c=$_;
                        List::Util::max 1+0*length($names[$c]), map {length($aref->[$_]->[$c])} 0 .. $#$aref
                    } 0 .. $#names;
                my @w0 = @w;
                my $tot = $#w+1 + List::Util::sum @w;
                if ($tot > $vim::width and !$vim::ignore_cols) {
                    __vypcol(\@names,$aref); # тогда выпиливаем даже если был флаг не выпиливать
                    # ...и пересчитать ширину
                    @w = map {
                            my $c=$_;
                            List::Util::max 1+0*length($names[$c]), map {length($aref->[$_]->[$c])} 0 .. $#$aref
                        } 0 .. $#names;
                    $tot = $#w+1 + List::Util::sum @w;
                    my $wrap_factor = $tot/($vim::width-$#w+2);
                    @w0 = map { POSIX::floor($_/$wrap_factor) || 1} @w;
                }
                my $tot0 = $#w+1 + List::Util::sum @w0;
                my $cap = "+".(join "+", map {'-'x $w0[$_]} 0 .. $#w) . "+\n";
                #┌─┐
                #├─┤
                #└─┘
                my $captop = $cap =~ tr{-+}{─┬}r =~ s/^┬/┌/r =~ s/┬$/┐/r;
                my $capm   = $captop =~ tr{┌┬┐─}{╞╪╡═}r;
                my $capb   = $captop =~ tr{┌┬┐}{└┴┘}r;
                my $bar = "│"; #"|";
                # formatting char-table
                # my $titlerows = 1+List::Util::max map {int(length($names[$_])/$w0[$_])} 0 .. $#$aref; # TODO
                $res .=
                    $captop .  #┌─┐
                    (   # field names in title, with line wrapping
                        join "", map {
                            my $line = $_;
                            $bar . (join $bar, map {
                                # line № $line in title row
                                sprintf "%$w0[$_].$w0[$_]s", substr($names[$_],$line*$w0[$_])
                            } 0 .. $#w) . "$bar\n"
                        } 0 .. List::Util::min List::Util::max (0, map {int(length($names[$_]) / $w0[$_])-1} 0 .. $#w), $vim::title_rows
                    ) .
                    $capm .    #├─┤
                    # lines themselves, with wrapping
                    join ("", map {
                      my $a=$_;
                      if ($tot > $vim::width) {
                          # wraping factor
                          # ideally we should consider field types, should allocate some space to numbers and remaining
			  # should be spread proportionally
                          # here - simplified way
                          # distribute proportionally to maximal width to the width $vim::width-$#w+2
                          #
                          my @writeto;
                          # write string $str width $width into scalar $writeto starting from $pos
                          for (my $i=0; $i<=$#w; $i++) {
                              my ($str,$width,$totwidth) = ($a->[$i]=~y{\n}{ }r, $w0[$i], $tot);
                              my $curpos = 0;
                              my $curline = 0;
                              my $pos = $i+List::Util::sum0 @w0[0 .. $i-1];
                              while ($curpos < length($str)) {
                                  push @writeto, (' ' x ($tot0+1)) . "\n" if $curline > $#writeto;
                                  substr($writeto[$curline],$pos,$width+2) = sprintf " %${width}.${width}s ", substr($str,$curpos);
                                  $curpos += $width;
                                  $curline++;
                              }
                          }
                          for (@writeto) {my $curpos=0;for my $colw (@w0){substr($_,$curpos+=$colw+1,1)=$bar}substr($_,0,1)=$bar}
                          join "", @writeto
                      } else {
                          $bar.(join $bar, map {sprintf "%$w[$_]s",$a->[$_]} 0 .. $#w)."$bar\n"
                      }
                    } @$aref) .
                    $capb;     #└─┘
            } elsif ($format eq 'x') {
                $res .= "{code:none}\n" . join("", map {
                          my $cnt=0;
                          my $x = join "\n", map{$names[$cnt++] . " : " .s/\n/\\n/gr=~s/^$/ /r} @$_;
                          $x  . "\n";
                      } @$aref)
                      . "{code}\n";
            } else {
                $res .= ( $format eq '-' ? "-- ".($#$aref+1)." rows" :
                  (
                    # formatting requested format
                  $fv->[0] . join($fv->[1],@names) . "$fv->[2]\n" .
                  join("", map {
                          my $x = join $fv->[4], map{s/\n/\\n/gr=~s/^$/ /r} @$_;
                          $fv->[3] . $x  . $fv->[5] ."\n"
                      } @$aref) .$fv->[6]
                  )
                );
            }
            $res .= "\$DBI::errstr=$DBI::errstr" if $DBI::errstr;
            if ($format eq 'h' and $vim::html_save_to) {open my $fh,">$vim::html_save_to";print $fh $res}
            if ($sqlname) {
                $sqlname = "#$::sqlcnt" if $sqlname eq '#';
                $::res{$sqlname} = $res;
                $::r{$sqlname} = $aref;
                $::colnames{$sqlname} = \@names;
            } else {
                # name not specified - then generate name, so to allow for easier navigation (TODO - document this technique)
                $sqlname = ($ifsql1 ? '17' : 't') . '_' . join('_',@names) =~s/\W+//gr;
                my $elapsed = Time::HiRes::tv_interval($t0, [Time::HiRes::gettimeofday()]);
                $res .= "{anchor:${sqlname}_$elapsed}\n" if $vim::anchorp; # - for jira. TODO for other formats
                $::r{$sqlname} = 1; # TODO - cleanup
            }
        }
    } else {
        my $sql = $cmd1; # otherwise we should do ENCODING=>'UTF8' on Text::Template
        my $ret = "$vim::mariadb [".$dbh->do($sql) .
		($lid ? " id=".($::id{$lid} = $dbh->last_insert_id(undef,undef,undef,undef)):"")."]> _" .
                ($DBI::errstr ? "\$DBI::errstr=$DBI::errstr": "");
        $res = ($jira_syntax?"{code:none}\n":"") . $ret . ($jira_syntax?"\n{code}":"");
    }
    my $dr=0;
    $vim::elapsed = Time::HiRes::tv_interval($t0, [Time::HiRes::gettimeofday()]);
    for (split /\n/, $res) { # appends a line(s)
        $::curbuf->Append($x1+$dr++, $_);
    }
    if ($dr > 0) {
        $::curwin->Cursor($x1,1);
        VIM::DoCommand("normal jzf".($dr-1)."jzok") if $dr>1;
    }
    $::curwin->Cursor($row0,$col);

    #VIM::DoCommand("redraw");
    VIM::Msg("done ($vim::elapsed) $cmd1", "Comment");
}


__END__
EOSVIM

