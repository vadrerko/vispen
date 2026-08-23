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
*   **Multiple Output Formats:** Render query results on the fly as ASCII tables, HTML, `summary` (row count only), or **ready-to-paste Jira markup** (`||3||str||`).
*   **Out-of-the-box Folding:** Results and code blocks automatically group into clean, native Vim folds (`|-`) to keep your screen clutter-free.
*   **Persistent Database Clients:** Define your `$::dbh` once via DBI, and seamlessly query MariaDB, Oracle, PostgreSQL, or any other enterprise DB.

---

## 💡 Why vispen? (The Philosophy)

Most modern notebook environments suffer from the "hidden state" problem or require complex infrastructure. `vispen` embraces the Unix philosophy:
1. It uses what's already inside your editor (`+perl`).
2. It treats files as plain text (`.sess.in` is completely Git-friendly, unlike `.ipynb` JSON bloat).
3. It automates tedious corporate workflows (generating tables and code snippets explicitly formatted for Jira/Confluence).

---

## 📄 License

MIT / Same as Vim.


Installation
------------

### Requirements

| Runtime | Version | Perl   |
|---------|---------|--------|
| Vim     | 8.0     | 5.006  |
| Neovim  | NOT supported (yet) | - |

#### Supported Vim Versions

Vim must have a [working Perl5](#supported-perl-runtime).

#### Supported Perl runtime

Vim must be compiled with perl. You can check if this is working with 
`:perl use Text::Template; print $Text::Template::VERSION`. It should say something like `1.59`.

The `Text::Template` modules is required, you can either install it from CPAN or another preferred way.
`Path::Class` needed if you will use 'untemplate' macrocommand, otherwise it is not necessary.

`cpan i Text::Template`
`cpan i Path::Class`

For SQL functionality, you need proper DBD module, for our minimal cale `DBD::SQLite`. 

## copy plugin itself

Copy vispen plugin file to some folder from where you will activate it and map it
to some key in `$HOME/_vimrc` or `$VIMHOME/_vimrc` file:

```viml
map <F11> :source c:\VimScripts\vim-perl-sql.vim<CR>
```

vispen comes with sane defaults for its options, however you probably will want
to override your initial template, etc.
So you could create your config file and include it into the chain too:

```viml
map <F11> :source c:\VimScripts\vim-perl-sql.vim<bar>:source c:\VimScripts\vim-perl-cfg.vim<CR>
```

You may take the one from the repository and edit it as you see fit.

## inctall Perl and Vim (if not done yet)

### Linux

For Ubuntu:

```
apt install vim-nox libtext-template-perl
apt install libpath-class-perl
apt install libdbi-perl
apt install libdbd-sqlite3-perl
```

### Windows

Download [Vim][] from official site, and install corresponding strawberry perl.

Make sure you have a supported Vim version with Perl support. You
can check the version and which Perl is supported by typing `:version` inside
Vim. Look at the features included: `+perl/dyn` for Perl.
Take note of the Vim architecture, i.e. 32 or
64-bit. It will be important when choosing the Perl installer. We recommend
using a 64-bit client. [Daily updated installers of 32-bit and 64-bit Vim with
Perl support][vim-win-download] are available.

Download and install [Perl][perl-win-download]. Be sure to pick the version
  corresponding to your Vim architecture. It is _Windows x86_ for a 32-bit Vim
  and _Windows x86-64_ for a 64-bit Vim.
  Additionally, the version of Perl you install must match up exactly with
  the version of Perl that Vim is looking for. Type `:version` and look at the
  bottom of the page at the list of compiler flags. Look for flags that look
  similar to `-DDYNAMIC_PERL_DLL=\"perl532.dll\"`. This indicates
  that Vim is looking for Perl 5.32. You'll need one or the other installed,
  matching the version number exactly.

Quick Feature Summary
-----

* perl-execution of current line or =Perl/=Cut block
* SQL-execution of current line or =SQL/=Cut block

Here's a quick demo:

TODO

User Guide
----------

### General Usage

Pressing `F9` on empty line will insert some predefined lines of text, which then
could be nicely edited and used for initialisation of the `$::dbh` variable, and also
some example lines. (those are from `$vim::initial_lines`, change it in your config
for your purposes)

2 keys are assigned by this plugin - `F7` key and `F9` key. `F7` if for Perl execution,
`F9` is for SQL execution.

After the `F7` or `F9` key is pressed, in case when `$vim::untemplatep` is true,
then all lines before the cuurent line are untemplated with the `tt_untemplate` function.
However these lines keep unchanged, so only side-effect makes sence. This could
be useful to initialize `$::dbh` or `$::dbh1` variables.

For the `F7` key, current line is executed as perl code, after that result of this
execution will be appended after the current line.

For the `F9` key, following considerations happens:

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
* `h` - HTML table
* `j` - JIRA syntax
* `x` - line-by-line format
* `o` - outwiker wiki format
* `O` - verbose outwiker wiki format
* `t` - coma-separated list prefixed with `--`
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
is unvisible.

Default: `0`

### `$vim::html_save_to`

File name where html will be saved for SQL results in HTML format.

Default: `tab.html`

### `$vim::ignore_cols`

Columns to skip for SQL requests, coma separated list

Default: ``

### `$vim::initial_lines`

Specifies initial lines which will be inserted on pressing `F9` key on empty line.

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

[vundle]: https://github.com/VundleVim/Vundle.vim#about
[vimrc]: https://vimhelp.appspot.com/starting.txt.html#vimrc
[vim]: https://www.vim.org/
[tracker]: https://github.com/vadrer/vispen/issues?state=open
[vim-win-download]: https://github.com/vim/vim-win32-installer/releases
[perl-win-download]: https://www.strawberryperl.com/windows/
