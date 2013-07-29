## Tube.vim

**v0.4.0**

This plugin provides a tiny interface for sending commands from MacVim to a
separate iTerm or Terminal window without leaving MacVim.


## Requirements

* Mac OS X 10.6+
* iTerm2 or Terminal already installed
* MacVim compiled with python 2.6+


## Installation

Extract the plugin folder to `~/.vim` or use a plugin manager such as
[Vundle](https://github.com/gmarik/vundle), [Pathogen](https://github.com/tpope/vim-pathogen)
or [Neobundle](https://github.com/Shougo/neobundle.vim).

To complete the installation you need to set the following variable in
your `.vimrc` file:

```
let g:tube_terminal = 'iterm'      " if you use iTerm.app
```

or

```
let g:tube_terminal = 'terminal'   " if you use Terminal.app
```


## Visual tour

### A simple example
```
                 focus remains here
 MacVim         /                                     Terminal
---------------°---------------------                -------------------------------------
| # hello_world.py                  |                | ...                               |
|                                   |                | $ ls                              |
| print "Hello World!"              |                | hello_world.py                    |
|                                   |        ------> | $ python hello_world.py           |
|                                   |       |        | Hello World!                      |
|___________________________________|       |        |                                   |
|:Tube python %                     |-------'        |                                   |
--------------°----------------------                -------------------------------------
               \
                The % character stands for the current buffer name. If you want
                no expansion at all, just escape it with another % character (%%).
                Note the absence of quotes around the command.
```

### Selection injection
```
                 focus remains here
 MacVim         /                                     Terminal
---------------°---------------------                -------------------------------------
| # hello_world.py                  |                | ...                               |
|                                   |                | $ python                          |
| print "this is a selected line"   |        ------> | >>> print "this is a selected.. " |
|                                   |       |        | this is a selected line           |
|                                   |       |        |                                   |
|___________________________________|       |        |                                   |
|:'<,'>Tube @                       |-------'        |                                   |
-------------°-----------------------                -------------------------------------
              \
               The @ character stand for the current selection. If you just happen to be
               on a line in normal mode then the @ character stands for the current
               line (in this case you'll use the plain :Tube @). If the selection spans
               multiple lines they are passed to the terminal as they are, that is,
               whitespaces are preserved.
```

### Function injection
```
                       focus remains here
 MacVim               /                               MacVim (invisible state)
---------------------°---------------                ....................................
|                                   |                .                                  .
|                                   |                .                                  .
| // beautifully crafted code       |                . // beautifully crafted code      .
|                                   | -------------> .                                  .
|                                   |                .                                  .
|___________________________________|                ....................................
|:Tube cd #{Foo(1^^'@')} && do sth  |          _____ |:Tube cd project_root && do sth   |
--------------|---°------------------         |      ....................................
              |    \_____________________     |
 Your .vimrc  |                          |    |       Terminal
--------------|----------------------    |    |      ------------------------------------
|                                   |    |    `----> | $ cd project_root && do sth      |
| fu! Foo(arg1, arg2)               |    |           | ...                              |
|  // really heavy computation      |    |           |                                  |
|  return "project_root"            |    |           |                                  |
| endfu                             |    |           |                                  |
|                                   |    |           |                                  |
-------------------------------------    |           ------------------------------------
                                         |
              __________________________/ \__________________________
             /                                                       \
   In this example we used the special            As you can see only string arguments require
   character @ as one of the arguments.           quotes. Also, you do not have to bother about
   Doing so we pass the selection right           escaping yourself the string since it's done
   into the function as a normal argument         automatically for you. 
   (note the quotes). This might be useful        
   if you need to perform some kind of            Note the awkward ^^ arguments separator. Since            
   formatting on the selection before             you are not required to escape yourself the
   passing it to the function.                    arguments (since they might come from an arbitrary
                                                  selection and injected via the @ character) there
                                                  is no way to determine where an arguments start or 
                                                  end. Commas just don't fit as separator since they
                                                  are so common, so I picked up a sequence of characters
                                                  scarcely used (at least by the author). You can change 
                                                  the separator sequence via the g:tube_funargs_separator
                                                  setting.
```


### Aliasing
```
                       focus remains here
 MacVim               /                               MacVim (invisible state)
---------------------°---------------                ....................................
|                                   |                .                                  .
| // a very                         |                . // a very                       .
| // long long                      |                . // long long                    .
| // paragraph                      | -------------> . // paragraph                    .
|                                   |                .                                 .
|___________________________________|                ....................................
|:TubeAlias cmd                     |          _____ |:Tube do something                |
---------------|--°------------------         |      ....................................
               |   \_____________________     |
 Your .vimrc   |                         |    |       Terminal
---------------|---------------------    |    |      ------------------------------------
|                                   |    |    `----> | $ do something                    |
| let g:tube_aliases = {            |    |           | ...                               |
|  \ 'cmd':'do something'           |    |           |                                   |
|  \ }                              |    |           |                                   |
|                                   |    |           |                                   |
--------°-----------°----------------    |           -------------------------------------
        |            \____________________\
        |                                   Selection, function and buffer injection
      You can define aliases in your        still work with aliasing.                
      .vimrc file or at runtime. Keep        
      in mind that in the latter case
      you'll lose those aliases once 
      you quit MacVim.
```


## Commands

### Tube

Execute the command in the separate iTerm (or Terminal) window. If the that
window does not exist yet, then it is created. If no command is given the
window is simply created, or cleared if it already exists.  By default the
window focus remains on MacVim but you can customize this behavior with
the `g:tube_run_command_background` setting. Note that you do'nt have to wrap
the command into quotes.

Some character as a special meaning inside the command. Those chracters are
`%`, `#{..}`, `@` and inform **Tube** that it has to inject some kind of
information into the command:

* `%`: inject the current buffer name
* `@`: inject the current selection or the current line if there is no selected
  text. Note that block selection is not supported.
* `#{FunctionName(arg1, .., argn)}`: inject the return value of the user function
  named FunctionName. String arguments need to be wrapped with single or double
  quotes but you don't need to bother about escaping quotes in your string:
  it's done automatically for you. Another nicety is that you can use the special 
  characters `%` and `@` even as arguments of the function. Just remember to
  wrap the with quotes too.

  **NOTE**: if you need a plain `%` or `@` character in your command just append
  the same character twice, respectively `%%` and `@@`


### TubeClr

As the `Tube` command but force the terminal to clear its screen before
executing the command. Under the hood it appends a `clear` command before
the main command.


### TubeLastCmd

Execute the last executed command.


### TubeInterrupt

Interrupt the current running command in the terminal window. Under the hood this sends
the Ctrl-C command.


### TubeCd

Execute a `cd 'vim current working directory'` command in the terminal window.


### TubeClose

Close the terminal window.


### TubeAlias

Execute the command associated with the given alias name. The alias might be
defined in the `.vimrc` file via the `g:tube_aliases` setting or at run time
via the `TubeAddAlias` command.


### TubeAliasClr

As the `TubeAlias` command but force the terminal to clear its screen before
executing the command associated with the alias.


### TubeAliases

Show all defined aliases.


### TubeToggleClearScreen

Toggle the `g:tube_always_clear_screen` setting.


### TubeToggleRunBackground

Toggle the `g:tube_run_command_background` setting.


## Settings

### g:tube\_terminal
Use this setting to set the terminal emulator of your choice. At the moment
only iTerm and Terminal are supported.

Default value: `terminal`


### g:tube\_always\_clear\_screen
Setting this to 0 forces the terminal to clear its screen whenever
a command is executed. You can toggle this setting on or off with the
TubeToggleClearScreen command.

Default value: `0`


### g:tube\_run\_command\_background
Set this variable to 1 to mantain the focus on the MacVim window whenever a
command is executed. You can toggle this setting on or off with the
TubeToggleRunBackground command.

Default value: `1`


### g:tube\_aliases
With this dictionary you can set your own aliases for commands. Just use the alias
name as the dictionary key and the string command as the value. Be sure to have
unique aliases. Special characters (`%`, `@` and `#{..}`) are supported.
  
Default value: `{}` 
  
Example: 
```vim
let g:tube_aliases = {'alias': 'cd $HOME/dev'}
```


### g:tube\_bufname\_expansion
Set this variable to 1 and every `%` character in your commands will be replaced with
the current buffer name (its absolute path). If you need the just the `%`
character use the `%%` sequence. You can toggle the setting on or off with the
TubeToggleBufnameExp command.

Default value: `1` 


### g:tube\_function\_expansion
Set this variable to 1 to enable function expansion. Every `#{FunctionName(arg1, .., argn)}`
string inside commands will be replaced with the return value of `FunctionName(arg1, .., argn)`
function defined by the user.

Default value: `1` 


### g:tube\_selection\_expansion
Set this variable to 1 to enable selection expansion. Every `@` character inside
commands will be replaced with the current selection. In order to get the
current selection you must use a Tube command the way you usually do with vim
commands: `:'<,'>;Tube command`. If no selection is found, then the current 
line is taken.

Default value: `1` 


### g:tube\_enable\_shortcuts
Set this variable to 1 to to enable shortcuts for the most important commands:

* `T`: Tube
* `Tc`: TubeClr
* `Tl`: TubeLastCmd
* `Ti`: TubeInterrupt
* `Tcd`: TubeCd
* `Ta`: TubeAlias
* `Tac`: TubeAliasClr

Default value: `0` 


### g:tube\_funargs\_separator
This variable let you define your own preferred characters sequence to 
separate arguments of injected function. The default string has been selected
because of its rare usage by the plugin author. You can change that as long as
you don't use your separator sequence in arguments.

Default value: `^^`
