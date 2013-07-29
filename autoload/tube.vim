" ============================================================================
" File: autoload/tube.vim
" Description: MacVim and terminal interaction made easy
" Mantainer: Giacomo Comitti - https://github.com/gcmt
" Url: https://github.com/gcmt/tube.vim
" License: MIT
" Version: 0.4.0
" Last Changed: 29 Jul 2013
" ============================================================================

fu! tube#Init()
    let py_module = fnameescape(globpath(&rtp, 'autoload/tube.py'))
    exe 'pyfile ' . py_module
    py tube_plugin = Tube()
endfu

call tube#Init()


function! tube#RunCommand(start, end, args)
    py tube_plugin.RunCommand(int(vim.eval('a:start')), int(vim.eval('a:end')), vim.eval('a:args'))
endfunction

function! tube#RunCommandClear(start, end, args)
    py tube_plugin.RunCommand(int(vim.eval('a:start')), int(vim.eval('a:end')), vim.eval('a:args'), clear=True)
endfunction

function! tube#RunLastCommand()
    py tube_plugin.RunLastCommand()
endfunction

function! tube#InterruptRunningCommand()
    py tube_plugin.InterruptRunningCommand()
endfunction

function! tube#CdIntoVimCwd()
    py tube_plugin.CdIntoVimCwd()
endfunction

function! tube#CloseTerminalWindow()
    py tube_plugin.CloseTerminalWindow()
endfunction


function! tube#Alias(start, end, args)
    py tube_plugin.RunAlias(int(vim.eval('a:start')), int(vim.eval('a:end')), vim.eval('a:args'))
endfunction

function! tube#AliasClear(start, end, args)
    py tube_plugin.RunAlias(int(vim.eval('a:start')), int(vim.eval('a:end')), vim.eval('a:args'), clear=True)
endfunction

function! tube#ShowAliases()
    py tube_plugin.ShowAliases()
endfunction


function! tube#ToggleClearScreen()
    py tube_plugin.toggle_setting('always_clear_screen')
endfunction

function! tube#ToggleRunBackground()
    py tube_plugin.toggle_setting('run_command_background')
endfunction
