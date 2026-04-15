" --- General Settings ---
syntax on                   " Enable syntax highlighting
set encoding=utf-8          " Set internal encoding to UTF-8
set backspace=indent,eol,start " Fix backspace behavior

" --- 42 Norm & Indentation ---
set tabstop=4
set shiftwidth=4
set noexpandtab
set softtabstop=0
set autoindent
set smartindent

set number
set relativenumber

" --- 42 C-File Specifics ---
" Ensures that .c and .h files strictly adhere to these rules
autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4 noexpandtab

" --- Search & Visuals ---
set hlsearch                " Highlight search results
set incsearch               " Search as you type
set ignorecase              " Ignore case in search...
set smartcase               " ...unless there is a capital letter

" --- Manual Clipboard Sync ---
function! SyncToSystemClipboard()
    " Join the yanked lines into a single string
    let l:text = join(v:event.regcontents, "\n")

    " Try Wayland first (wl-clipboard)
    if executable('wl-copy')
        call system('wl-copy', l:text)
    " Fallback to X11 (xclip)
    elseif executable('xclip')
        call system('xclip -selection clipboard', l:text)
    endif
endfunction

if has('unnamedplus')
    set clipboard=unnamedplus
endif

if !has('unnamedplus')
    augroup ManualClipboard
        autocmd!
        " Trigger the sync only when an actual 'yank' (y) happens
        " This avoids cluttering clipboard during deletes (d)
        autocmd TextYankPost * if v:event.operator ==# 'y' | call SyncToSystemClipboard() | endif
    augroup END
endif


