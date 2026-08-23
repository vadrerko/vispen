vispen: VIm Sql and Perl ENgine
===============================

Contents
--------

- [Intro](#intro)
- [Installation](#installation)
    - [Requirements](#requirements)
- [Quick Feature Summary](#quick-feature-summary)
- [User Guide](#user-guide)
    - [General Usage](#general-usage)
- [Commands](#commands)
- [Options](#options)


Intro
-----

`vispen` (Vim Session Pen) is a lightweight, zero-overhead Literate Programming environment and interactive SQL client built directly into Vim, written entirely in Perl. 

Unlike heavy alternatives (like Emacs Org-mode or Jupyter), `vispen` uses Vim's built-in **`+perl`** interpreter. It keeps your database connections and variables persistent in the editor's memory — **with absolutely no external servers, background processes, or network sockets.**


## 🚀 Quick Demo

[![vispen demo](demo/demo2.svg)](https://asciinema.org/a/bVRMwGnUATW2gt5c)

*In this demo: Writing dynamic SQL with inline Perl templates, executing it instantly, and rendering results directly into auto-folding Jira markup and ASCII tables.*

It can be used as a powered command shell:
[![shell replacement demo](demo/demo3.svg)](https://asciinema.org/a/KErAxIe10dpvcFlr)

## ✨ Key Features

*   **Zero-Socket Architecture:** State and variables persist inside Vim's native `+perl` memory space. No flaky ports, no zombie backend servers.
*   **Polyglot Literate Programming:** Mix documentation, Jira markup, raw Perl logic (`=Perl / =Cut`), and SQL queries (`=sql / =Cut`) in a single `.sess.in` file.
*   **Smart Template Evaluation:** Use `{{{ ... }}}` interpolation via `Text::Template` directly inside your SQL statements.
*   **Multiple Output Formats:** Render query results on the fly as ASCII tables, HTML, `summary` (row count only), or **ready-to-paste Jira markup**.
*   **Out-of-the-box Folding:** Results and code blocks automatically group into clean, native Vim folds (`|-`) to keep your screen clutter-free.
*   **Persistent Database Clients:** Define your `$::dbh` once via DBI, and seamlessly query MariaDB, Oracle, PostgreSQL, or any other enterprise DB.

## Quick Feature Summary

* perl-execution of current line or =Perl/=Cut block
* SQL-execution of current line or =SQL/=Cut block

## 💡 Why vispen? (The Philosophy)

Most modern notebook environments suffer from the "hidden state" problem or require complex infrastructure. `vispen` embraces the Unix philosophy:
1. It uses what's already inside your editor (`+perl`).
2. It treats files as plain text (`.sess.in` is completely Git-friendly, unlike `.ipynb` JSON bloat).
3. It automates tedious corporate workflows (generating tables and code snippets explicitly formatted for Jira/Confluence).

User Guide
----------



Installation
------------

### Requirements

| Runtime | Version | Perl |
| :--- | :--- | :--- |
| **Vim** | 8.0 | 5.006 |
| **Neovim** | NOT supported (yet) | - |

#### Supported Vim Versions

Vim must have a [working Perl5](#supported-perl-runtime).

#### Supported Perl runtime

Vim must be compiled with perl. You can check if this is working with 
`:perl use Text::Template; print $Text::Template::VERSION`. It should say something like `1.59`.

The `Text::Template` modules is required, you can either install it from CPAN or another preferred way.
`Path::Class` needed if you will use 'untemplate' macrocommand, otherwise it is not necessary.

`cpan i Text::Template`
`cpan i Path::Class`

For SQL functionality, you need proper DBD module, for our minimal case `DBD::SQLite`. 

## copy plugin and configure bindings

Copy vispen plugin file to some folder from where you will activate it.
Below is an example to map plugin activation and needed actions
to some keys in some initialization file:


```viml
map <F6> :source c:\VimScripts\vim-perl-sql.vim<bar>
	\source c:\VimScripts\vim-perl-sql-cfg.vim<CR>
```

...and `vim-perl-sql-cfg.vim` having these bindings:
```viml
map <F7> <Esc>:perl execute_here(5)<CR>
map <F8> <Esc>:perl tt_untemplate()<CR>
map <F9> <Esc>:perl execute_here()<CR>
```

You may take the one from the repository and edit it as you see fit.

## install Perl and Vim (if not done yet)

### Linux

For Ubuntu:

```
apt install vim-nox libtext-template-perl
apt install libpath-class-perl
apt install libdbi-perl
apt install libdbd-sqlite3-perl
```
(Of course `libdbd-sqlite3-perl` only for execution with starter text, you probably already
have your SQL perl driver :) )

### Windows

If you build yourself - then you know better :)
Otherwise download [Vim][] from official site, and install corresponding perl.
Check `:ver` - seek for occurence of string like following -
` -DDYNAMIC_PERL -DDYNAMIC_PERL_DLL=\"perl532.dll\" `  - and make sure this perl is available to vim.

Here are the links for your convenience:
- [Daily updated installers of 32-bit and 64-bit Vim with Perl support][vim-win-download].
- [Perl][perl-win-download]. Be sure to pick the matching version by 1. number and 2. 32/64 arch.


### ⚙️ Customization

By default, `vispen` binds functions to `<F7>`, `<F8>`, and `<F9>`. If these keys conflict with your existing setup, you can disable the defaults and map your own preferred keys (e.g., using your `<Leader>` key):

```vim
" Disable default F-key mappings
let g:vispen_no_mappings = 1

" Map vispen functions to custom shortcuts
nmap <Leader>ve <Plug>(VispenExecuteHere)
nmap <Leader>vp <Plug>(VispenExecuteParam)
nmap <Leader>vu <Plug>(VispenUntemplate)
```


### General Usage

There is main "action" (my mapping is `F9`) and secondary "action" (I map it to `F7`).

Executing "action" (`F9`) on empty line will insert some predefined lines of text, which then
could be nicely edited and used for initialisation of the `$::dbh` variable, and also
some example lines. (those are from `$vim::initial_lines`, change it in your config
for your purposes)

Main action (`F9`) is for SQL execution, secondary action (`F7`) is for Perl execution,

After "action"  key is pressed, in case when `$vim::untemplatep` is true,
then all lines before the current line are untemplated with the `tt_untemplate` function.
However these lines keep unchanged, so only side-effect makes sence. This could
be useful to initialize `$::dbh` or `$::dbh1` variables.

For the secondary action, current line is executed as perl code, after that result of this
execution will be appended after the current line.

For the main action, following considerations happens:

* the plugin checks lines before the current line until it seen whitespace line or
line starting with `=` or `}` characters.

* If whitespace line is found sooner than line starting with `=` or `}`, then
single line is to be executed

* otherwise, in case that line starting one of the following ways:
`=sql`, `=Sql`, `sQl`, `sqL`, `sQL`, `perl`, `Perl`, `pErl`, `PERL`
then multiline command is
executed, in this case vispen searches for closing `=cut` (or `=Cut`) and executes
the block.

* for all other cases current single line is executed as `SQL` code.

Interpretation of these block listed below.

#### `=sql/=Cut` block

means general sql query

### `=sqL/=Cut` block

same as `=sql` but table presented in ASCII form instead of JIRA syntax.

#### `=Sql/=Cut` block

SQL query will be interpreted as select request, so output will be represented
as table.

#### `=sQl/=Cut` and `=sQL/=Cut` block

like `=sql/=Cut` but all requests will be performed through `$::dbh1` variable, so
allowing alternate connection to SQL server. Mnemonic: this is a bit twisted
and hidden way (probably to an important server where nothing should be broken)
therefore `=sQl` instead of `=sql` so no one will find this hidden way.

`=sQL` for ASCII table, `=sQl` for JIRA syntax.

#### `=perl/=Cut` block

general perl block of code to be executed, in strict mode.

#### `=PERL/=Cut` block

general perl block of code to be executed, in no strict mode.

#### `=Perl/=Cut` block

Same as `=Perl/=Cut` but there will be `{code:perl}...{code}` inserted just before
the result, and result itself will be in `{code:none}...{code}` so to make
construction of JIRA reports easier.

#### `=pErl/=Cut` block

Same as `=Perl/=Cut` but before execution untemplating will be performed. Do not
use it, try to find another way to find solution to your problem, because
untemplating of perl code itself isn't a good idea (unlike SQL:)), and hence it
is named `=pErl`.

All these blocks accept name, options and comment this way:

```
=sql name/f=format comment
...
=Cut
```

Name is arbitrary name for the given SQL statement, if specified - then special
hash `%::r` will hold result of the query.

Format is:
* `+` - ASCII table
* `-` - only summary, actual output is not shown
* `h` - HTML table
* `j` - JIRA syntax
* `x` - line-by-line format
* `o` - outwiker wiki format
* `O` - verbose outwiker wiki format
* `t` - comma-separated list prefixed with `--`
* `T` - tab-separated list prefixed with `--`


Commands
--------

### The `:perl execute_here` command

For example:

```perl
```

### The `:perl suggest_columns` command

For example:

```perl
```

### The `:perl tt_open_or_switchto` command

For example:

```perl
```

### The `:perl tt_untemplate` command

Performs untemplating of the current file into a new one using the
`Text::Template->fill_in`function. New file name is constructed by removing
`.in` suffix if it exists, or by appending the `.untempl` suffix.
This new file will be opened in a new tab, except if that file was already
opened, then plugin will switch into that tab.

One optional parameter could be used - if true, then contents of the `$::reset`
variable will be prepended at the very beginning. Typically there should be
`undef $dbh` so during untemplating reconnection to database will happen.

Please save the file before executing this.

For example:

```perl
perl tt_untemplate()
perl tt_untemplate(1)
```

Options
-------

These options can be configured in your [vimrc script][vimrc] by including a
line like this:

```perl
perl $vim::anchorp = 1
```

### `$vim::anchorp`

This option, 'anchor predicate', controls whether `{ancrhor:xxx_time}` will be
inserted after execution. This could be considered as marker, which then could
facilitate in searching through your SQL requests. In JIRA reports this marker
is invisible.

Default: `0`

### `$vim::html_save_to`

File name where html will be saved for SQL results in HTML format.

Default: `tab.html`

### `$vim::ignore_cols`

Columns to skip for SQL requests, comma separated list

Default: ``

### `$vim::initial_lines`

Specifies initial lines which will be inserted on pressing main action key on empty line.

Default: - some few lines of text

### `$vim::title_rows`

Specifies max number of rows in table title for SQL results in ASCII format.

Default: `99`

### `$vim::width`

Specifies width of table for SQL results in ASCII format.

Default: `123`

### `$vim::untemplatep`

This option, 'untemplate predicate', controls whether untemplating of lines
before cursor will be performed before execution of single line or =Perl/=Cut
block or =sql/=Cut blocks.

Untemplating in single-line SQL, single-line perl and `=sql/=Cut` block performed
regardless of this option.

Default: `1`


### Best practices

#### simple DOs and DON'Ts

* **File Naming:** Name your templates as `some.name.ext.in`. After untemplating, the `.in` suffix will be stripped, leaving you with a clean, untemplated file named `some.name.ext` in a new tab.
* **Save Before Untemplating:** Always save your changes before running the `untemplate` command, as it reads directly from the disk.
* **Hiding Sections:** The untemplating process discards everything between `=ignore_everywhere/=cut` and `=ie/=cut`. This is why active sections use the uppercase `=Cut` — it allows you to hide multiple `=Perl/=Cut` or `=sql/=Cut` blocks inside a single `=ie/=cut` zone.
* **No Empty Lines:** Avoid placing completely empty lines inside active blocks like `=Sql/=Cut` or `=Perl/=Cut`.
* **Data Loss Warning:** All lines after `=Cut` will be automatically deleted until the first empty line is encountered. Do not place any important text there.
* **Keep It Simple:** Avoid excessive complexity. Be perlish, but not too perlish — keep about 5% of a pythonista mindset.
* **Feedback:** If you run into any difficulties, please let me know by opening an issue in the repository.


#### Perl State Management

When debugging custom Perl functions by executing `=perl/=Cut` blocks, remember that once a module is loaded via `use`, Vim's persistent memory will not reload it on subsequent executions. Changes made to the module file on disk will not take effect.

You can overcome this by manually deleting the corresponding slot from the `%INC` hash. However, a much cleaner and more effective approach is to execute the code in an external Perl process like this:


```perl
=Perl
my $prog = <<'EOS';
    use strict; 
    use Data::Dumper;
    use SomeModuleUnderDevelopment;
    my @res = some_function();
    print Dumper(\@res)
EOS
` perl -we '$prog' 2>&1 `
=Cut
```

*Note: Avoid using unescaped quotes inside the `$prog` string that match your external execution wrapper.*

This approach also makes it possible to display function coverage and trace function execution directly from your Vim session.

#### Issuing Commands

*Section under development. Check the 2nd demo video for visual examples.*


## 📄 License

MIT / Same as Vim.


[vundle]: https://github.com/VundleVim/Vundle.vim#about
[vimrc]: https://vimhelp.appspot.com/starting.txt.html#vimrc
[vim]: https://www.vim.org/
[tracker]: https://github.com/vadrer/vispen/issues?state=open
[vim-win-download]: https://github.com/vim/vim-win32-installer/releases
[perl-win-download]: https://www.strawberryperl.com/windows/
