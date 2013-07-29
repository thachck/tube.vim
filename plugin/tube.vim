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

let disable = get(g:, 'tube_disable', 0)
if disable || exists("g:tube_loaded") || &cp
    finish
endif

if !has('python') || !has('gui_macvim')
    finish
endif

let g:tube_loaded = 1

" Initialize settings {{{
let g:tube_terminal =  get(g:, "tube_terminal", 'terminal')
let g:tube_always_clear_screen = get(g:, "tube_always_clear_screen", 0)
let g:tube_run_command_background = get(g:, "tube_run_command_background", 1)
let g:tube_bufname_expansion = get(g:, "tube_bufname_expansion", 1)
let g:tube_selection_expansion = get(g:, "tube_selection_expansion", 1)
let g:tube_function_expansion = get(g:, "tube_function_expansion", 1)
let g:tube_enable_shortcuts = get(g:, "tube_enable_shortcuts", 0)
let g:tube_funargs_separator = get(g:, "tube_funargs_separator", '^^')
let g:tube_aliases = get(g:, "tube_aliases",  {})
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

if get(g:, 'tube_enable_shortcuts', 0)

    command! -nargs=* -range T call tube#RunCommand(<line1>, <line2>, <q-args>)
    command! -nargs=* -range Tc call tube#RunCommandClear(<line1>, <line2>, <q-args>)
    command! Tl call tube#RunLastCommand()
    command! Ti call tube#InterruptRunningCommand()
    command! Tcd call tube#CdIntoVimCwd()
    command! -nargs=1 -range Ta call tube#Alias(<line1>, <line2>, <q-args>)
    command! -nargs=1 -range Tac call tube#AliasClear(<line1>, <line2>, <q-args>)

endif

" }}}
