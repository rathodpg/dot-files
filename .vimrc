"Pretty basic ones
set nocompatible
set expandtab
set number
syntax on
set autoindent shiftwidth=4
set smartindent
set tabstop=4
set softtabstop=4
set showmode
set showcmd
set smartcase
colorscheme elflord
set incsearch
set hlsearch
set pastetoggle=<F2>
set cursorline

filetype plugin on
let g:pydiction_location = '/usr/share/pydiction/complete-dict'
"Shows function, class names shortcut
let mapleader = ","
"au VimEnter * TagbarToggle
nmap <leader>sd :TagbarToggle<cr>
nmap <leader>st :NerdTreeToggle<cr>
nmap <leader>mh :vertical res +5<cr>
nmap <leader>mv :res +5<cr>
inoremap <F3> <c-o>:w<cr>
"nmap <leader>mh :res +5<cr>

"autocmd vimenter * NERDTree
"Shows tabs all the time
set showtabline=2
au BufWritePost * if getline(1) =~ "^#!" | if getline(1) =~ "/bin/" | silent execute "!chmod a+x <afile>" | endif | endif
" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo
function! ResCur()
    if line("'\"") <= line("$")
	normal! g`"
	return 1
	endif
	endfunction

	augroup resCur
	autocmd!
autocmd BufWinEnter * call ResCur()
	augroup END
let g:pydoc_cmd = "/usr/bin/pydoc"
" Rope AutoComplete
let ropevim_vim_completion = 1
let ropevim_extended_complete = 1
"let g:ropevim_autoimport_modules = ["os.*","traceback","django.*", "xml.etree"]
"imap <c-space> <C-R>=RopeCodeAssistInsertMode()<CR>"
"mouse completion
"set mouse=a

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    "echo 'Highlight current word: ON'
    return 1
  endif
endfunction
call AutoHighlightToggle()
"Call pathogen that manages all runtime paths.
call pathogen#infect()
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <down> <nop>
set cursorline
