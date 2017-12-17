syntax on

" Tab系
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

set nofoldenable    " disable folding

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

NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'

NeoBundle 'farmergreg/vim-lastplace'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" scrooloose/nerdtree
"nnoremap <silent><C-e> :NERDTreeToggle<CR>
"nnoremap <silent><C-e> :NERDTreeToggle %<CR>
function MyNerdTreeToggle()
	if &filetype == 'nerdtree'
		:NERDTreeToggle
	else
		:NERDTreeFind
	endif
endfunction
nnoremap <silent><C-e> :call MyNerdTreeToggle() <CR>

" for ctags
"nnoremap  <C-]>    g<C-]>
"nnoremap  v<C-]>   :vsp +:exec("tag\ ".expand("<cword>"))<CR>
"set splitright     "新しいウィンドウを右にひらく

function! FollowTag()
  if !exists("w:tagbrowse")
    vsplit
    let w:tagbrowse=1
  endif
  execute "tag " . expand("<cword>")
endfunction

nnoremap <c-]> :call FollowTag()<CR>

au BufRead,BufNewFile *.md set filetype=markdown
let g:previm_open_cmd = 'open -a Google\ Chrome'
