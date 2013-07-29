# -*- coding: utf-8 -*-
"""
tube.py
~~~~~~~

This module defines the Tube class. This class provides the
main functionality for the Tube plugin,
"""

import os
import vim
import sys

# avoid deprecation warnings to be displayed to the user
import warnings
warnings.simplefilter("ignore", DeprecationWarning)

sys.path.insert(0, os.path.dirname(
    vim.eval('globpath(&rtp, "autoload/tube.py")')))

import tube.utils.settings
import tube.utils.misc


class Tube:

    def __init__(self):
        self.settings = tube.utils.settings
        self.misc = tube.utils.misc
        self.alias_manager = tube.aliasmanager.AliasManager()
        self.last_command = ''

        path = os.path.dirname(vim.eval('globpath(&rtp, "autoload/tube.py")'))
        self.SCRIPTS_LOC = "osascript " + path + "/applescript/"
        self.BASE_CMD = 'osascript -e'

    def RunCommand(self, start, end, cmd, clear=False, parse=True):
        """Inject the proper data in the command if required and run the
        command."""

        if parse:

            if cmd and self.settings.get('bufname_expansion', bool):
                cmd = self.misc.expand_chars(
                        cmd, '%', vim.current.buffer.name)

            if cmd and self.settings.get('selection_expansion', bool):
                cmd = self.misc.expand_chars(
                        cmd, '@', '\r'.join(vim.current.buffer[start-1:end]))

            if cmd and self.settings.get('function_expansion', bool):
                try:
                    cmd = self.misc.expand_functions(cmd)
                except NameError:  # the function does not exist
                    self.misc.echo('unknown function')
                    return
                except ValueError:  # bad arguments
                    self.misc.echo('bad arguments')
                    return

        if (not cmd or clear
            or self.settings.get('always_clear_screen', bool)):
            self.run(cmd, clear=True)
        else:
            self.run(cmd)

        if not self.settings.get('run_command_background', bool):
            self.focus_terminal()

        self.last_command = cmd

    def RunAlias(self, start, end, alias, clear=False):
        """Lookup a command given its alias and execute that command."""
        aliases = self.settings.get('aliases')
        command = aliases.get(alias)
        if command:
            self.RunCommand(start, end, command, clear)
        else:
            self.misc.echo('alias not found')

    def RunLastCommand(self):
        """Execute the last executed command."""
        if self.last_command:
            self.RunCommand(1, 1, self.last_command, parse=False)
        else:
            self.misc.echo('no last command to execute')

    def InterruptRunningCommand(self):
        """Interrupt the running command in the terminal window."""
        term = self.settings.get('terminal').lower()
        cmd = """
            tell application "{0}" to activate

            tell application "System Events"
                keystroke "c" using control down
            end tell

            tell application "MacVim" to activate"""

        cmd = cmd.format("Terminal" if term == "terminal" else "iTerm")
        os.popen("{0} '{1}'".format(self.BASE_CMD, cmd))

    def CdIntoVimCwd(self):
        """Send the terminal window a cd command with the vim current working
        directory."""
        self.RunCommand(1, 1, "cd {0}".format(vim.eval("getcwd()")))

    def CloseTerminalWindow(self):
        """Close the terminal window."""
        term = self.settings.get('terminal').lower()
        if term == 'terminal':
            cmd = 'tell application "Terminal" to quit'
        else:
            cmd = 'tell application "iTerm" to quit'

        os.popen("{0} '{1}'".format(self.BASE_CMD, cmd))

    def ShowAliases(self):
        """To show all defined aliases."""
        aliases = self.settings.get('aliases')
        if not aliases:
            self.misc.echo('no aliases found')
            return

        n = len(aliases)
        print('+ aliases')
        for i, alias in enumerate(aliases):
            if i == (n - 1):
                conn = '└─ '
            else:
                conn = '├─ '
            print(conn + alias + ': ' + aliases[alias])

    def run(self, cmd, clear=False):
        """Send the command to the terminal emulator of choice"""
        term = self.settings.get('terminal').lower()
        if term == 'iterm':
            base = self.SCRIPTS_LOC + 'iterm.scpt'
        else:
            base = self.SCRIPTS_LOC + 'terminal.scpt'

        clr = 'clear;' if clear else ''
        cmd = cmd.replace('\\', '\\\\')
        cmd = cmd.replace('"', '\\"')
        cmd = cmd.replace('$', '\$')
        os.popen('{0} "{1}"'.format(base, clr + cmd.strip()))

    def focus_terminal(self):
        """Switch focus to the terminal window."""
        term = self.settings.get('terminal').lower()
        if term == 'terminal':
            cmd = 'tell application "Terminal" to activate'
        else:
            cmd = 'tell application "iTerm" to activate'

        os.popen("{0} '{1}'".format(self.BASE_CMD, cmd))

    def toggle_setting(self, sett):
        """Toggle the given setting."""
        self.settings.set(sett, not self.settings.get(sett, bool))
        self.echo_setting_state(sett)

    def echo_setting_state(self, sett):
        """Show the current state of the given setting."""
        sett_state = '{0} = {1}'.format(sett, self.settings.get(sett))
        self.misc.echo(sett_state)
