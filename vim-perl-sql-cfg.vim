map <F7> <Esc>:perl execute_here(5)<CR>
map <F8> <Esc>:perl tt_untemplate()<CR>
map <F9> <Esc>:perl execute_here()<CR>

perl << EOSVIM
# following lines will be inserted when executing on an empty line:
$vim::initial_lines = << 'EOS'
{{{
}}}\
EOS
some handy lines:

undef $::dbh
$vim::width = 160
$vim::untemplatep = 0
$vim::anchorp = 1
EISVIM

