" File: pudb.vim
" Author: Christophe Simonis
" Description: Manage pudb breakpoints directly into vim
" Last Modified: December 03, 2012
"

if exists('g:loaded_pudb_plugin') || &cp
    finish
endif
let g:loaded_pudb_plugin = 1

if !has("python")
    echo "Error: Required vim compiled with +python"
    finish
endif

sign define PudbBreakPoint text=Ø) texthl=error

let s:first_sign_id = 10000
let s:next_sign_id = s:first_sign_id

let s:plugin_dir = expand("<sfile>:p:h")

let g:loaded_pudb_check = 0

augroup pudb
    "autocmd VimEnter * call s:CheckPudb()
    autocmd BufReadPost *.py call s:UpdateBreakPoints()
    autocmd BufReadPost *.py command! TogglePudbBreakPoint call s:ToggleBreakPoint()
    autocmd BufReadPost *.py command! ClearPudbBreakPoints call s:ClearPudbBreakPoints()
augroup end

"command! TogglePudbBreakPoint call s:ToggleBreakPoint()
"command! ClearPudbBreakPoints call s:ClearPudbBreakPoints()

function! s:CheckPudb()
"if !exists("g:loaded_pudb_check")
    if executable('pudb')
       if $VIRTUAL_ENV == ""
           echo "vim-pudb will be functionnal"
           echo "but pudb must be installed in your virtual environnement to work properly"
        endif
    else
        echo "You need to install pudb to be able to use vim-pudb plugin. If you use a virtual environment, pudb must be installed in it." 
        return 1
        "finish 
    endif
    "let g:loaded_pudb_check = 1
"endif
endfunction

function! s:UpdateBreakPoints()
"if s:CheckPudb() == 1 | return
" first remove existing signs
if !exists("b:pudb_sign_ids")
    let b:pudb_sign_ids = []
endif

for i in b:pudb_sign_ids
    exec "sign unplace " . i
endfor
let b:pudb_sign_ids = []


python << EOF
import vim
import os
import subprocess

filename = vim.eval('expand("%:p")')

scriptname = os.path.join(vim.eval('s:plugin_dir'), 'load_breakpoints.py')
bps = subprocess.Popen(['python', scriptname, filename], stdout=subprocess.PIPE)

for bp in bps.stdout:
    bp = int(bp.strip())

    sign_id = vim.eval("s:next_sign_id")
    vim.command("sign place %s line=%s name=PudbBreakPoint file=%s" % (sign_id, bp, filename))
    vim.eval("add(b:pudb_sign_ids, s:next_sign_id)")
    vim.command("let s:next_sign_id += 1")
EOF

endfunction

function! s:ToggleBreakPoint()
"if g:loaded_pudb_check == 1 | return
python << EOF
import vim
import os
import subprocess

filename = vim.eval('expand("%:p")')
row, col = vim.current.window.cursor

scriptname = os.path.join(vim.eval('s:plugin_dir'), 'set_breakpoint.py')
proc = subprocess.Popen(['python', scriptname, filename, str(row)])
proc.wait()

vim.command('call s:UpdateBreakPoints()')
EOF
endfunction

function! s:ClearPudbBreakPoints()
"if g:loaded_pudb_check == 1 | return
python << EOF
import vim

scriptname = os.path.join(vim.eval('s:plugin_dir'), 'clear_breakpoints.py')
proc = subprocess.Popen(['python', scriptname])             
proc.wait()

vim.command('call s:UpdateBreakPoints()')
EOF

endfunction
