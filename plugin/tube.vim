" ============================================================================
" File: plugin/tube.vim
" Description: MacVim and terminal interaction made easy
" Mantainer: Giacomo Comitti (https://github.com/gcmt)
" Url: https://github.com/gcmt/tube.vim
" License: MIT
" Version: 0.3.1
" Last Changed: 2 Feb 2013
" ============================================================================

" Init {{{

if exists('g:tube_disable')
    let s:disable = g:tube_disable
else
    let s:disable = 0
endif

if s:disable || exists("g:tube_loaded") || &cp
    finish
endif

if !has('python')
    echohl WarningMsg | echom "Tube requires vim to be compiled with Python 2.6+" | echohl None
    finish
endif

if v:version < 703
    echohl WarningMsg | echom "Tube requires vim 7.3+" | echohl None
    finish
endif

python << END
import vim, sys

if sys.version_info[:2] < (2, 6):
    vim.command('let s:unsupported_python = 1')
END

if exists('s:unsupported_python')
    echohl WarningMsg | echom "Tube requires vim to be compiled with Python 2.6+" | echohl None
    finish
endif

let g:tube_loaded = 1

" }}}

" Commands {{{

command! -nargs=1 -range TubeAlias call tube#Alias(<line1>, <line2>, <q-args>)
command! -nargs=1 -range TubeAliasClear call tube#AliasClear(<line1>, <line2>, <q-args>)

command! -nargs=* -range Tube call tube#RunCommand(<line1>, <line2>, <q-args>)
command! -nargs=* -range TubeClear call tube#RunCommandClear(<line1>, <line2>, <q-args>)
command! TubeLastCommand call tube#RunLastCommand()
command! TubeInterruptCommand call tube#InterruptRunningCommand()
command! TubeCd call tube#CdIntoVimCwd()
command! TubeClose call tube#CloseTerminalWindow()

command! -nargs=1 TubeRemoveAlias call tube#RemoveAlias(<q-args>)
command! -nargs=+ TubeAddAlias call tube#AddAlias(<q-args>)
command! TubeReloadAliases call tube#ReloadAliases()
command! TubeAliases call tube#ShowAliases()
command! TubeRemoveAllAliases call tube#RemoveAllAliases()
command! TubeShowAliases call tube#ShowAliases()

command! TubeToggleClearScreen call tube#ToggleClearScreen()
command! TubeToggleRunBackground call tube#ToggleRunBackground()
command! TubeToggleBufnameExp call tube#ToggleBufnameExp()
command! TubeToggleFunctionExp call tube#ToggleFunctionExp()
command! TubeToggleSelectionExp call tube#ToggleSelectionExp()

if exists('g:tube_enable_shortcuts') && g:tube_enable_shortcuts

    command! -nargs=* -range T call tube#RunCommand(<line1>, <line2>, <q-args>)
    command! -nargs=* -range Tc call tube#RunCommandClear(<line1>, <line2>, <q-args>)
    command! Tl call tube#RunLastCommand()
    command! Ti call tube#InterruptRunningCommand()
    command! Tcd call tube#CdIntoVimCwd()
    command! -nargs=1 -range Ta call tube#Alias(<line1>, <line2>, <q-args>)
    command! -nargs=1 -range Tac call tube#AliasClear(<line1>, <line2>, <q-args>)

endif

" }}}
