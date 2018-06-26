syntax on

" Tab系
" Tabキーを押した際にタブ文字の代わりにスペースを入れる
set expandtab
" 自動インデントでずれる幅
set shiftwidth=2
" タブキー押下時に挿入される文字幅を指定
set softtabstop=2
" ファイル内にあるタブ文字の表示幅
set tabstop=2
" ツールバーを非表示にする
set guioptions-=T
" 対応する括弧を強調表示
set showmatch
" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent
" 不可視文字を可視化(タブが「▸-」と表示される)
"set list listchars=tab:\▸\-

" yでコピーした時にクリップボードに入る
set guioptions+=a

set number

" Foldingの無効化
set nofoldenable

" yank to clipboard
if has("clipboard")
  set clipboard=unnamed " copy to the system clipboard

  if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
  endif
endif


" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.vim/bundle/neobundle.vim/

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'joe-skb7/cscope-maps'
NeoBundle 'vim-scripts/taglist.vim'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'rking/ag.vim'
NeoBundle 'vim-utils/vim-man'

NeoBundle 'farmergreg/vim-lastplace'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" 'scrooloose/nerdtree'
function MyNerdTreeToggle()
	if &filetype == 'nerdtree'
		:NERDTreeToggle
	else
		:NERDTreeFind
	endif
endfunction
nnoremap <silent><C-e> :call MyNerdTreeToggle() <CR>

" cscopequickfix
set cscopequickfix=s-,g-,c-,d-,i-,t-,e-
"set cst

augroup myvimrc
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l*    lwindow
augroup END

" Fix E568: duplicate cscope database not added
" http://thoughtsolo.blogspot.com/2014/02/cscope-issue-duplicate-cscope-database.html
set nocscopeverbose 

nnoremap <C-p> <Esc>:set paste! paste?<CR>i

" Binary
"バイナリ編集(xxd)モード（vim -b での起動、または *.bin ファイルを開くと発動）
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre   *.bin let &binary=1
  autocmd BufReadPre   *.img let &binary=1
  autocmd BufReadPost  *     if  &binary   | silent   %!xxd -g 1
  autocmd BufReadPost  *     set ft=xxd    | endif
  autocmd BufWritePre  *     if  &binary   | execute '%!xxd -r' | endif
  autocmd BufWritePost *     if  &binary   | silent   %!xxd -g 1
  autocmd BufWritePost *     set nomod     | endif
augroup END

