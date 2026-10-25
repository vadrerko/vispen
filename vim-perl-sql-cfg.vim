map <F7> <Esc>:perl execute_here(5)<CR>
map <F8> <Esc>:perl tt_untemplate()<CR>
map <F9> <Esc>:perl execute_here()<CR>

perl << EOSVIM
# following lines will be inserted when executing on an empty line:
$spen::initial_lines = << 'EOS';
{{{
}}}\
some handy lines:

use DBI; $::dbh = DBI->connect("dbi:SQLite:dbname=try-1.sqlite","","");

$spen::width = 160
$spen::untemplatep = 0
$spen::anchorp = 1
EOS
EOSVIM

