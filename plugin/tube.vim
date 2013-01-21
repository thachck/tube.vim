" ============================================================================
" File: tube.vim
" Description: MacVim and terminal interaction made easy
" Mantainer: Giacomo Comitti (https://github.com/gcmt)
" Url: https://github.com/gcmt/tube.vim
" License: MIT
" Version: 0.2.1
" Last Changed: 21 Jan 2013
" ============================================================================
"
" TODO: commands history
"

" Intit -------------------------------------- {{{

if exists("g:tube_loaded") || !has('python')
    finish
endif
let g:tube_loaded = 1


if !exists("g:tube_terminal")
    let g:tube_terminal = "terminal"
endif

if !exists("g:tube_always_clear_screen")
    let g:tube_always_clear_screen = 0
endif

if !exists("g:tube_aliases")
    let g:tube_aliases = {}
endif

if !exists("g:tube_run_command_background")
    let g:tube_run_command_background = 1
endif

if !exists("g:tube_percent_sign_expansion")
    let g:tube_percent_sign_expansion = 1
endif  

if !exists("g:tube_function_expansion")
    let g:tube_function_expansion = 1
endif     

" }}}

python << END

# -*- coding: utf-8 -*-

import vim
import os
import re
from itertools import groupby


class TubeUtils: 

    @staticmethod
    def feedback(msg): # {{{
        """Display a simple feedback to the user via the command line."""
        TubeUtils.echom(u'[tube] ' + msg)
    # }}}

    @staticmethod
    def echom(msg): # {{{
        vim.command(u'echom "{0}"'.format(msg))
    # }}}

    @staticmethod
    def let(name, value): # {{{
        """To set a vim variable to a given value."""
        prefix = u'g:tube_'

        if isinstance(value, basestring):
            val = u"'{0}'".format(value)
        elif isinstance(value, bool):
            val = u"{0}".format(1 if value else 0)
        else:
            val = value # list or number type

        vim.command(u"let {0} = {1}".format(prefix + name, val))
    # }}}

    @staticmethod
    def setting(name, fmt=str): # {{{
        """To get the value of a vim variable."""
        prefix = u'g:tube_'

        raw_val = vim.eval(prefix + unicode(name, 'utf8'))
        if isinstance(raw_val, list):
            return raw_val
        elif fmt is bool:
            return False if raw_val == '0' else True
        elif fmt is str:
            return unicode(raw_val, 'utf8')
        else:
            try:
                return fmt(raw_val)
            except ValueError:
                return None
    # }}}

    @staticmethod
    def expand_percent_sign_with_curr_buffer(raw_str): # {{{
        """Expand the percent sign in a string with the current buffer path.
        
            If two or more consecutive percent signs are found, then they are
            compacted into one percent sign.
        """
        bufname = vim.current.buffer.name

        out = ''
        for char_group in [''.join(g) for k, g in groupby(raw_str)]:
            if char_group == '%':
                if bufname:
                    out += bufname
                else:
                    out += ''
            elif char_group.startswith('%'):
                out += '%'
            else:
                out += char_group

        return out
    # }}}

    @staticmethod
    def expand_functions(s): # {{{
        """Inject the return value of a function in the string where the
           function is specified as #{function_name}.

           The function is a vim function.
        """
        def callf(match):
            fun_name = match.group('fun')
            if fun_name:
                if '1' == vim.eval("exists('*{0}')".format(fun_name)):
                    return vim.eval("call(function('{0}'), [])".format(fun_name))
                else:
                    raise ValueError

        return re.sub('#{(?P<fun>\w*)}', callf, s)   
    # }}}

class Tube:

    def __init__(self): # {{{
        self.PLUGIN_PATH = vim.eval("expand('<sfile>:h')")
        self.BASE_CMD_SCRIPTS = "osascript " + self.PLUGIN_PATH + "/applescript/"
        self.BASE_CMD = 'osascript -e'
        self.aliases = TubeUtils.setting('aliases', fmt=dict)
        self.last_command = ''
    # }}}

    def run(self, command, clear=False): # {{{
        """Send the command to the terminal emulator of choice"""
        term = TubeUtils.setting('terminal').lower()
        if term == 'iterm':
            base = self.BASE_CMD_SCRIPTS + 'execute_iterm.scpt' 
        else:
            base = self.BASE_CMD_SCRIPTS + 'execute_terminal.scpt' 

        clr = 'clear;' if clear else ''
        os.popen("{0} '{1}'".format(base, clr + command.strip()))
    # }}}

    def run_command(self, command, clear=False): # {{{
        """Inject the proper data in the command if required and run the 
        command."""

        if command and TubeUtils.setting('percent_sign_expansion', fmt=bool):
            command = TubeUtils.expand_percent_sign_with_curr_buffer(command)

        if command and TubeUtils.setting('function_expansion', fmt=bool):
            try:
                command = TubeUtils.expand_functions(command)
            except ValueError: # the function does not exist
                TubeUtils.feedback('unknown function found in the command')
                return

        if (not command or clear 
            or TubeUtils.setting('always_clear_screen', fmt=bool)):
            self.run(command, clear=True)
        else:
            self.run(command)

        if not TubeUtils.setting('run_command_background', fmt=bool):
            self.focus_terminal()

        self.last_command = command
    # }}}

    def run_last_command(self): # {{{
        """Execute the last executed command."""
        if self.last_command:
            self.run_command(self.last_command)
        else:
            TubeUtils.feedback('no last command to execute')
    # }}}

    def interrupt_running_command(self): # {{{
        """Interrupt the running command in the terminal window."""
        term = TubeUtils.setting('terminal').lower()
        cmd = """
            tell application "{0}" to activate

            tell application "System Events"
                keystroke "c" using control down
            end tell

            tell application "MacVim" to activate"""

        if term == 'terminal':
            cmd = cmd.format("Terminal")
        else:
            cmd = cmd.format("iTerm")

        os.popen("{0} '{1}'".format(self.BASE_CMD, cmd))
    # }}}

    def cd_into_current_dir(self): # {{{
        """Set the current working directory in the terminal window to the
        current working directory in vim."""
        self.run_command("cd " + vim.eval("getcwd()")) 
    # }}}

    def close(self): # {{{
        """Close the terminal window."""
        term = TubeUtils.setting('terminal').lower()
        if term == 'terminal':
            cmd = 'tell application "Terminal" to quit'
        else:
            cmd = 'tell application "iTerm" to quit'
        
        os.popen("{0} '{1}'".format(self.BASE_CMD, cmd))
    # }}}

    def focus_terminal(self): # {{{
        """Switch focus to the terminal window."""
        term = TubeUtils.setting('terminal').lower()
        if term == 'terminal':
            cmd = 'tell application "Terminal" to activate'
        else:
            cmd = 'tell application "iTerm" to activate'
        
        os.popen("{0} '{1}'".format(self.BASE_CMD, cmd))
    # }}}

    ## ALIASES

    def run_alias(self, alias): # {{{
        """Lookup a command given its alias and execute that command."""
        command = self.aliases.get(alias, None)
        if command:
            self.run_command(command)
            return
    
        TubeUtils.feedback('alias not found')
    # }}}

    def add_alias(self, args): # {{{
        """Add a new alias.
        
           this method accept a string where the first token represent the
           alias name whereas the rest is interpreted as the command.
        """
        try:
            alias, command = args.split(' ', 1)
            self.aliases[alias] = command
        except:
            TubeUtils.feedback('bad argument')
        else:
            TubeUtils.feedback('alias successfully added')
    # }}}
            
    def remove_alias(self, alias): # {{{
        """Remove an alias.
        
           This has a temporary effect if the g:tube_aliases vim variable
           is defined.
        """
        try:
            del self.aliases[alias]
        except:
            TubeUtils.feedback('alias not found')
        else:
            TubeUtils.feedback('alias successfully removed')
    # }}}

    def remove_all_aliases(self): # {{{
        """Remove all defined aliases.
        
           This has a temporary effect if the g:tube_aliases vim variable
           is defined.
        """
        self.aliases.clear()
        TubeUtils.feedback('all aliases successfully removed')
    # }}}

    def show_aliases(self): # {{{
        """Show all defined aliases."""
        if not self.aliases:
            TubeUtils.feedback('nothing found')
            return 
        
        n = len(self.aliases)
        print('+ aliases')
        for i, alias in enumerate(self.aliases):
            if i  == n - 1:
                conn = '└─ '
            else:
                conn = '├─ '
            print(conn + alias + ': ' + self.aliases[alias])
    # }}}

    def reload_aliases(self): # {{{
        """Reload the alias dictionary from the vim variable g:tube_alias.

            This might be needed when the user change the g:tube_aliases 
            variable at run time. 
        """
        self.aliases = TubeUtils.setting('aliases', fmt=dict)
        TubeUtils.feedback('aliases successfully reloaded')
    # }}}

    ## SETTINGS

    def toggle_setting(self, sett): # {{{
        """Toggle the given setting."""
        TubeUtils.let(sett, not TubeUtils.setting(sett, fmt=bool))
        self.echo_setting_state(sett)
    # }}}

    def echo_setting_state(self, sett): # {{{
        """Show the current state of the given setting."""
        sett_state = '{0} = {1}'.format(sett, TubeUtils.setting(sett))       
        TubeUtils.feedback(sett_state)  
    # }}}


tube = Tube()

END

command! -nargs=1 TubeAlias python tube.run_alias(<q-args>)
command! -nargs=1 TubeRemoveAlias python tube.remove_alias(<q-args>)
command! -nargs=+ TubeAddAlias python tube.add_alias(<q-args>)
command! TubeReloadAliases python tube.reload_aliases()
command! TubeAliases python tube.show_aliases()
command! TubeRemoveAllAliases python tube.remove_all_aliases()

command! -nargs=* Tube python tube.run_command(<q-args>)
command! -nargs=* TubeClear python tube.run_command(<q-args>, clear=True)
command! TubeLastCommand python tube.run_last_command()
command! TubeInterruptCommand python tube.interrupt_running_command()
command! TubeCd python tube.cd_into_current_dir()
command! TubeClose python tube.close()

command! TubeToggleClearScreen python tube.toggle_setting('always_clear_screen')
command! TubeToggleRunBackground python tube.toggle_setting('run_command_background')
command! TubeToggleExpandPercent python tube.toggle_setting('percent_sign_expansion')
command! TubeToggleExpandFunction python tube.toggle_setting('function_expansion')
