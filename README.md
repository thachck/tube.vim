## Tube.vim

**v0.3.0**

This plugin provides a tiny interface for sending commands from MacVim to a 
separate iTerm or Terminal window without leaving MacVim.


## Requirements

* Mac OS X 10.6+ (note that this plugin has been tested only on Mac OS X 10.6
  but should work even with successive versions)
* iTerm2 or Terminal installed
* MacVim compiled with python 2.x+


## Installation

Extract the content of the folder into `$HOME/.vim` or use your favourite 
package manager.

To complete the installation you need to set at least the following variable in 
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
               multiple lines the they are passed to the terminal as they are, that is, 
               whitespaces.
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
|:Tube cd #{Foo(1,'@')} && do sth   |          _____ |:Tube cd project_root && do sth   |
--------------|--°-------------------         |      ....................................
              |   \______________________     |                                            
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
              __________________________/ \___________
             /                                        \
   In this example we used the special            As you can see only string arguments require 
   character @ as one of the arguments.           quotes. Also, you do not have to bother about
   Doing so we pass the selection right           escaping yourself the string since it's done    
   into the function as a normal argument         automatically for you. Note however that all    
   argument (note the quotes). This might         arguments are passed to the function as strings.
   be useful if you need to perform some            
   kind of formatting on the selection 
   before sending it to the terminal                 
```

### Aliasing
```                    
                       focus remains here
 MacVim               /                               MacVim (invisible state) 
---------------------°---------------                ....................................
| // a very                         |                . // a very                        .
| // long long                      |                . // long long                     .
| // paragraph                      |                . // paragraph                     .
| // is selected                    | -------------> . // is selected                   .
| ...                               |                . ...                              .
|___________________________________|                ....................................
|:'<,'>TubeAlias cmd                |          _____ |:Tube make etc                    |
---------------|--°------------------         |      ....................................
               |   \_____________________     |                                            
 Your .vimrc   |                         |    |       Terminal                             
---------------|---------------------    |    |      ------------------------------------ 
|                                   |    |    `----> | $ make etc                        | 
| let g:tube_aliases = {            |    |           | ...                               |
|  \'cmd':'#{Format('@')} | do sth' |    |           |                                   |
|  \}                               |    |           |                                   |
|                                   |    |           |                                   |
--------°-----------°----------------    |           ------------------------------------- 
        |            \____________________\
        |                                   Selection, function and buffer injection
      You can define your aliases in        still work with aliasing. 
      your .vimrc file or you can at     
      run time. Note however that in
      the latter case you'll lose those 
      aliases once you quit MacVim.
      (See Aliasing-related commands)
```


## Commands


### Tube
```
arguments: a string of any length
e.g. Tube python % (see below for the special % character)
```

Execute the command in the separate iTerm (or Terminal) window. If the that
window does not exist yet, then it is created. If no command is given the the
window is simply created, or cleared if it already exists.  By default the
window focus remains on MacVim but you can customize this behavior (see the
g:tube_run_command_background setting).

As you see there is no need of quotes around the command, but if you need these
in your command be sure to use double quotes. 

The character `%` has a special meaning: as in the vim command line it is
expanded to the current buffer name. If you need that character in your command
use the `%%` sequence (actually, every sequence made of two or more `%`s will
be reduced to just one `%` character. See the g:tube_percent_sign_expansion 
setting to customize this behavior).


### TubeClear
```
arguments: a string of any length
```
    
As the `Tube` command but force the terminal to clear the screen before
executing the command.


### TubeLastCommand
```
arguments: no
```

Send to the terminal window the last executed command.


### TubeInterruptCommand
```
arguments: no
```

Interrupt the current "running" command in the terminal window via the Ctrl-C command.


### TubeCd
```
arguments: no
```

Set the currrent working directory in the terminal to the current working directory
in MacVim. 


### TubeClose
```
arguments: no
```

Close the terminal window.


### TubeToggleClearScreen
```
arguments: no
```

Toggle the g:tube_always_clear_screen setting.


### TubeToggleRunBackground
```
arguments: no
```

Toggle the g:tube_run_command_background setting.


### TubeToggleExpandPercent
```
arguments: no
```

Toggle the g:tube_percent_sign_expansion setting.


### TubeToggleExpandFunction
```
arguments: no
```

Toggle the g:tube_function_expansion setting. 


## Aliasing-related commands

### TubeAlias
```
arguments: a string of any length (the alias name)
e.g. TubeAlias my_alias
```

### TubeAliasClear
```
arguments: a string of any length (the alias name)
```  

As the `TubeAlias` command but force the terminal to clear the screen before
executing the command associated to the alias.


### TubeRemoveAlias
```
arguments: a string of any length (the alias name)
e.g. TubeRemoveAlias my_alias
```

Remove the command associated with the given alias.


### TubeAddAlias
```
arguments: at least two tokens of any length.  
The first token will be interpreted as the name of the alias whereas the rest (one or more tokens) will be interpreted as the command.
e.g. TubeAddAlias my_alias cd intothat & rm all 
```

Associate the alias name with the given command.

### TubeReloadAliases
```
arguments: no
```

Reload the g:tube_aliases vim variable. This might be needed when the user
change that variable at runtime.


### TubeAliases
```
arguments: no
```

Show all defined aliases.


### TubeRemoveAllAliases 
```
arguments: no
```

Remove all defined aliases. This affect only the current vim session. Any
alias defined in your `.vimrc` (see the g:tube_aliases setting) will be restored 
when MacVim is reopened.



## Settings


### g:tube_terminal
```
values: 'iterm' or 'terminal'
default: 'terminal'
```

Use this setting to specify the terminal emulator of your choice. At the moment
only iTerm and Terminal are supported.


### g:tube_always_clear_screen
```
values: 1 or 0
default: 0
```

Setting this to 0 force the terminal to clear its screen whenever
a command is executed. You can toggle this setting on or off with the
TubeToggleClearScreen command.


### g:tube_run_command_background
```
values: 1 or 0
default: 1
```

Setting this to 1 to mantain the focus on the MacVim window when you execute
commands. You can toggle this setting with the TubeToggleRunBackground command.   


### g:tube_aliases
```
values: a dictionary {'alias': 'command', ...}
default: {}
```

With this dictionary you can set your own aliases for commands. Just use the alias 
name as the dictionary key and the string command as the value. Be sure to have
unique aliases.


### g:tube_percent_sign_expansion
```
values: 0 or 1
default: 1
```

Set this to 1 and every `%` character in your commands will be expanded into
the current buffer path. If you need the just the `%` character use the `%%`
sequence. You can toggle the setting on or off with the TubeToggleExpandPercent
command.

### g:tube_function_expansion
```
values: 0 or 1
default: 1
```

Set this to 1 and every #{FunctionName(..)} string will be expanded with the result of the FunctionName(..) function defined by the user.


## Changelog

### v0.3.0
* new feature: selection injection
* new feature: functions injected into the command can now accept arguments
* bug fixes

### v0.2.1 
* fix plugin feedback

### v0.2.0 
* new feature: the result of a custom vim function can be injected into the command with the special notation #{CustomFunction}.
* minor bug fixes.

### v0.1.0
* first release
