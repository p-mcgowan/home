if ! [ -f $HOME/.vimrc ] || ! $(grep -q '"CUSTOMVIMRC' $HOME/.vimrc); then
  cat > $HOME/.vimrc <<ENDVIMRC
"CUSTOMVIMRC  - keep this line to prevent duplication
set nocompatible
set runtimepath=\$VIMRUNTIME
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
set runtimepath^=~/.vim/bundle/ctrlp.vim
ENDVIMRC
else
  echo vimrc appears to be up-to-date
fi

if ! [ -f $HOME/.bashrc ] || ! $(grep -q '#CUSTOMBASHRC' $HOME/.bashrc); then
  cat >> $HOME/.bashrc <<ENDBASHRC
#CUSTOMBASHRC - keep this line to prevent duplication

cdl() { cd "\$@" && ls --color=auto; }
alias ls="ls --color=auto"
alias ll="ls -l"
alias lr="ls -R"
alias la="ls -a"
alias l="ls -CF"
ctrlpvim() {
  if [ ! -d \$HOME/.vim/bundle ]; then
    mkdir -p \$HOME/.vim/bundle && \
    git clone https://github.com/kien/ctrlp.vim.git \$HOME/.vim/bundle/ctrlp.vim && \
    echo "set runtimepath^=~/.vim/bundle/ctrlp.vim" >>\$HOME/.vimrc
  fi
}
alias ..="cd .. && ls --color=auto"
alias ...="cd ../.. && ls --color=auto"
alias ....="cd ../../.. && ls --color=auto"
alias tmux="LC_CTYPE=C.UTF-8 tmux"
export PS1='\\[\\e]0;\\u@\\h: \\w\\a\\]\${debian_chroot:+(\$debian_chroot)}\\[\\033[01;32m\\]\$(whoami)@\$(uname -n)\\[\\033[00m\\] \\[\\033[01;36m\\]\\w\\[\\033[00m\\]\\\$ '
export LS_COLORS='rs=0:di=01;36:ln=01;96:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
# for docker images without locale set
alias tmux="LC_CTYPE=C.UTF-8 tmux"
ENDBASHRC
  source $HOME/.bashrc
else
  echo bashrc appears to be up-to-date
fi

packager=
if $(command -v apt-get &>/dev/null); then
  packager="apt-get"
elif $(command -v apt &>/dev/null); then
  packager="apt"
elif $(command -v yum &>/dev/null); then
  packager="yum"
elif $(command -v apk &>/dev/null); then
  packager="apk"
else
  echo unknown installer - do git vim tmux manually
fi
if [ -n "$packager" ]; then
  $packager install -y git vim tmux
fi
