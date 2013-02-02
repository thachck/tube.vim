# -*- coding: utf-8 -*-

import vim
import tube.utils.settings


class AliasManager:

    def __init__(self):

        # modules reference shortcuts
        self.settings = tube.utils.settings

        self.aliases = self.settings.get('aliases')

    def init_settings(self):
        sett = {
            'aliases': {}
        }

        for s, val in sett.items():
            if vim.eval("!exists('g:tube_{0}')".format(s)) == '1':
                self.settings.set(s, val)

    def add_alias(self, args):
        """Add a new alias.

           this method accept a string where the first token represent the
           alias name whereas the rest is interpreted as the command.
        """
        try:
            alias, command = args.split(' ', 1)
            self.aliases[alias] = command
        except:
            self.echo.echom('bad argument')
        else:
            self.echo.echom('alias successfully added')

    def remove_alias(self, alias):
        """Remove an alias.

           This has a temporary effect if the g:tube_aliases vim variable
           is defined.
        """
        try:
            del self.aliases[alias]
        except:
            self.echo.echom('alias not found')
        else:
            self.echo.echom('alias successfully removed')

    def remove_all_aliases(self):
        """Remove all defined aliases.

           This has a temporary effect if the g:tube_aliases vim variable
           is defined.
        """
        self.aliases.clear()
        self.echo.echom('all aliases successfully removed')

    def show_aliases(self):
        """Show all defined aliases."""
        if not self.aliases:
            self.echo.echom('nothing found')
            return

        n = len(self.aliases)
        print('+ aliases')
        for i, alias in enumerate(self.aliases):
            if i == (n - 1):
                conn = '└─ '
            else:
                conn = '├─ '
            print(conn + alias + ': ' + self.aliases[alias])

    def reload_aliases(self):
        """Reload the alias dictionary from the vim variable g:tube_alias.

            This might be needed when the user change the g:tube_aliases
            variable at run time.
        """
        self.aliases = self.settings.get('aliases')
        self.echo.echom('aliases successfully reloaded')
