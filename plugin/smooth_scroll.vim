if get(g:,'loaded_smooth_scroll', 0) == 1
    finish
endif
let g:loaded_smooth_scroll = 1

if !has("reltime")
    echom "vim-smooth-scroll requires +reltime feature"
    finish
endif

" This controls how fast the window scrolls.
if !exists("g:ms_per_line")
    let g:ms_per_line=8
endif

" Replace scroll keys
if get(g:, "scroll_disable_mapping", 0) != 1
    nnoremap <silent> <c-u> :call smooth_scroll#up(  &scroll)<CR>
    nnoremap <silent> <c-d> :call smooth_scroll#down(&scroll)<CR>
    nnoremap <silent> <c-b> :call smooth_scroll#up(  &scroll*2)<CR>
    nnoremap <silent> <c-f> :call smooth_scroll#down(&scroll*2)<CR>
    nnoremap <silent> zz :call smooth_scroll#center(0)<CR>
    nnoremap <silent> zt :call smooth_scroll#top(0)<CR>
    nnoremap <silent> zb :call smooth_scroll#bottom(0)<CR>
    vnoremap <silent> zz :<c-u>call smooth_scroll#center(1)<CR>
    vnoremap <silent> zt :<c-u>call smooth_scroll#top(1)<CR>
    vnoremap <silent> zb :<c-u>call smooth_scroll#bottom(1)<CR>
endif
