"set visualbell
set nocompatible
set runtimepath=$VIMRUNTIME
set nocp
set ls=2
set tabstop=4
set shiftwidth=4
set expandtab
set ruler
set incsearch
set hlsearch
set number
set ignorecase
set nomodeline
set autoindent
set smartindent
set nobackup
set noignorecase
set noswapfile
set nowrap
set nofixendofline
set hidden
set backspace=indent,eol,start
set background=dark
set colorcolumn=80
set colorcolumn=120
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix
" source them aliases
set shell=bash\ --login
colorscheme desert
filetype on
filetype plugin on
filetype plugin indent on
syntax on
" underline highlight
highlight Search ctermbg=none ctermfg=none cterm=underline,bold
" No netrwhist
:let g:netrw_dirhistmax = 0
if has('mouse')
  set mouse=a
endif

" runtime! autoload/pathogen.vim
" if exists("*pathogen#infect")
"     call pathogen#infect()
" endif
silent! call pathogen#infect()

au BufNewFile,BufRead *.ts set filetype=typescript

function! Tabs()
  setlocal tabstop=2
  setlocal shiftwidth=2
endfunction

function! StripTrailingWhitespace()
  " Don't strip on these filetypes
  if &ft =~ 'md\|markdown\|pug'
    return
  endif
  %s/\s\+$//e
endfunction

autocmd BufWritePre * call StripTrailingWhitespace()

autocmd Filetype java set makeprg=javac\ %

set omnifunc=syntaxcomplete#Complete
set completefunc=javacomplete#Complete
set completeopt=longest,menuone
" Make enter finish the completion popup menu
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Tag lists
nnoremap <F3> :TlistToggle<CR>
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 50

" Jump to same line as when closed
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

"Set the color for the popup menu
:highlight Pmenu ctermbg=blue ctermfg=white
:highlight PmenuSel ctermbg=blue ctermfg=red
:highlight PmenuSbar ctermbg=cyan ctermfg=green
:highlight PmenuThumb ctermbg=white ctermfg=red

" Mappings
map <F11> :call Testfn()<Return>

" Plugins
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = 'node_modules\|.git'

" Commands
:command Gotodefinition <c-]>

" Write as root
" Functions
:function! s:SudoWrite()
:w !sudo tee %
:endfunction
:command! SudoWrite call s:SudoWrite()

"let g:netrw_banner = 0
"let g:netrw_liststyle = 3
"let g:netrw_browse_split = 4
"let g:netrw_altv = 1
"let g:netrw_winsize = 25
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END

map <ESC>[1;6B <C-S-Down>
map <ESC>[1;6A <C-S-Up>
map <ESC>[1;5C <C-Right>
map <ESC>[1;5D <C-Left>
"map! <ESC>[1;6B <C-S-Down>
"map! <ESC>[1;6A <C-S-Up>
"map! <ESC>[1;5C <C-Right>
"map! <ESC>[1;5D <C-Left>

unmap <silent> <C-Left>
unmap <silent> <C-Right>
unmap <silent> <C-S-Down>
unmap <silent> <C-S-Up>
nnoremap <C-S-Down> :m.+1<CR>
nnoremap <C-S-Up> :m.-2<CR>
inoremap <C-S-Down> <Esc>:m.+1<CR>==gi
inoremap <C-S-Up> <Esc>:m.-2<CR>==gi
vnoremap <C-S-Down> :m '>+1<CR>gv=gv
vnoremap <C-S-Up> :m '<-2<CR>gv=gv
nnoremap <C-Right> <S-Right>
nnoremap <C-Left> <S-Left>
inoremap <C-Right> <S-Right>
inoremap <C-Left> <S-Left>
vnoremap <C-Right> <S-Right>
vnoremap <C-Left> <S-Left>

"incremen each sub
":function Increment(s, e, rep, inc)
":let i = a:s | g/a:rep/s//\=i/ | let i = i + a:inc
":endfunction"

"line up columns
":function TabTo(repl)
":s/\((@a:repl)\)/\=submatch(0) . repeat(' ', n - strlen(submatch(0)))
":endfunction

":function Repl(start) range
":let @a=a:start | :'<,'>s/\([0-9]\+\)/\=\1(@a+setreg('a', @a + 1))/g
":endfunction

":function Testfn()
"  let INDENT_FMT       = '\([ ]*\)'
"  let FN_NAME_FMT      = '\(.*\)'
"  let PARAM_NAME_FMT   = '[\*]\+\([a-zA-Z_]\+\)'
"  let PARAM_TYPE_FMT   = '[ ]*\(.*\)[ ]*'
"  let PARAM_FMT        = '\(' . PARAM_TYPE_FMT . PARAM_NAME_FMT . '[,)]\)*'
"  "let CAPTURE_FMT      = '\(' . INDENT_FMT . FN_NAME_FMT . '(' . PARAM_FMT . '[ ]*{.*\)'
"  let CAPTURE_FMT      = '^\(' . INDENT_FMT . FN_NAME_FMT . '(.*)[ ]*{.*\)$'
"
"  let line = search(CAPTURE_FMT, 'p')
"  echom '=> "' . submatch(1) . '"'
"  echom line
"  "let matched = substitute(line, CAPTURE_FMT, line, '')
"  "echom matched
"
"  let i = 0
"  while submatch(i) != ""
"    echom '' . i . submatch(i)
"    let i = i + 1
"  endwhile
"  echo '=>' . submatch(0)
"  let pat = submatch(1)
"  while pat != ""
"    call setline(line('.') + i, matched)
"    let i = i + 1
"    matched = submatch(i)
"  endwhile
" let  = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
" :s/\(\([ ]*\)\(.*\)(\(.*\)).*{.*\)/\1\r\2\ \ Debug.log(DEBUG_DEFAULT, "\3(%d)",\ \4);/
":endfunction

":command InsertDebug :normal oDebug.log(DEBUG_DEFAULT, "");<ESC>

"function AlignAssignments()
"    " Patterns needed to locate assignment operators...
"    let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
"    let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)'
"
"    " Locate block of code to be considered (same indentation, no blanks)
"    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
"    let firstline  = search('^\%('. indent_pat . '\)\@!','bnW') + 1
"    let lastline   = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
"    if lastline < 0
"        let lastline = line('$')
"    endif
"
"    " Find the column at which the operators should be aligned...
"    let max_align_col = 0
"    let max_op_width  = 0
"    for linetext in getline(firstline, lastline)
"        " Does this line have an assignment in it?
"        let left_width = match(linetext, '\s*' . ASSIGN_OP)
"
"        " If so, track the maximal assignment column and operator width...
"        if left_width >= 0
"            let max_align_col = max([max_align_col, left_width])
"
"            let op_width      = strlen(matchstr(linetext, ASSIGN_OP))
"            let max_op_width  = max([max_op_width, op_width+1])
"        endif
"    endfor
"
"    " Code needed to reformat lines so as to align operators...
"    let FORMATTER = '\=printf("%-*s%*s", max_align_col, submatch(1),
"    \                                    max_op_width,  submatch(2))'
"
"    " Reformat lines with operators aligned in the appropriate column...
"    for linenum in range(firstline, lastline)
"        let oldline = getline(linenum)
"        let newline = substitute(oldline, ASSIGN_LINE, FORMATTER, "")
"        call setline(linenum, newline)
"    endfor
"endfunction
