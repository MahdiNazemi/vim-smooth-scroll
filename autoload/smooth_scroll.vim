" ==============================================================================
" File: smooth_scroll.vim
" Author: Terry Ma
" Description: Scroll the screen smoothly to retain better context. Useful for
" replacing Vim's default scrolling behavior with CTRL-D, CTRL-U, CTRL-B, and
" CTRL-F, zz, zt, zb
" Last Modified: Dec 21st 2016
" ==============================================================================

let s:save_cpo = &cpo
set cpo&vim

" ==============================================================================
" Global Functions
" ==============================================================================

" Scroll the screen up
function! smooth_scroll#up(dist, duration, lines_per_draw)
  call s:smooth_scroll('u', a:dist, a:duration, a:lines_per_draw, 1)
endfunction

" Scroll the screen down
function! smooth_scroll#down(dist, duration, lines_per_draw)
  call s:smooth_scroll('d', a:dist, a:duration, a:lines_per_draw, 1)
endfunction

" Scroll to the center
function! smooth_scroll#center(duration, lines_per_draw)
  let half_win = (winheight(0) + 1) / 2
  let cur_center = line('w0') + l:half_win - 1
  let target_center = line('.')
  let num_down = l:target_center - l:cur_center
  if l:num_down > 0
    call s:smooth_scroll('d', l:num_down, a:duration, a:lines_per_draw, 0)
  else
    call s:smooth_scroll('u', -l:num_down, a:duration, a:lines_per_draw, 0)
  endif
endfunction

" Scroll to the top
function! smooth_scroll#top(duration, lines_per_draw)
  let cur_top = line('w0') + &scrolloff
  let target_top = line('.')
  let num_down =  l:target_top - l:cur_top
  call s:smooth_scroll('d', l:num_down, a:duration, a:lines_per_draw, 0)
endfunction

" Scroll to the bottom
function! smooth_scroll#bottom(duration, lines_per_draw)
  let cur_bottom = line('w$') - &scrolloff
  let target_bottom = line('.')
  let num_up = l:cur_bottom - l:target_bottom
  call s:smooth_scroll('u', l:num_up, a:duration, a:lines_per_draw, 0)
endfunction

" ==============================================================================
" Functions
" ==============================================================================

" Scroll the window smoothly
" dir: Direction of the scroll. 'd' is downwards, 'u' is upwards
" dist: Distance, or the total number of lines to scroll
" duration: How long should each scrolling animation last. Each scrolling
" animation will take at least this long. It could take longer if the scrolling
" itself by Vim takes longer
" lines_per_draw: the number of lines to scroll during each scrolling animation
" move: when 1, move the cursor too
function! s:smooth_scroll(dir, dist, duration, lines_per_draw, move)
  let move_cmd=''
  if a:move == 1
    if a:dir ==# 'd'
      let move_cmd='j'
    else
      let move_cmd='k'
    endif
  endif

  for i in range(a:dist/a:lines_per_draw)
    let start = reltime()
    if a:dir ==# 'd'
      exec "normal! ".a:lines_per_draw."\<C-e>".a:lines_per_draw.l:move_cmd
    else
      exec "normal! ".a:lines_per_draw."\<C-y>".a:lines_per_draw.l:move_cmd
    endif
    redraw
    let elapsed = s:get_ms_since(start)
    let snooze = float2nr(a:duration-elapsed)
    if snooze > 0
      exec "sleep ".snooze."m"
    endif
  endfor

  " Make sure we move exactly a:dist when a:lines_per_draw is not 1
  let extra_lines=a:dist % a:lines_per_draw
  echom "el: ".l:extra_lines
  if a:dir ==# 'd'
    exec "normal! ".l:extra_lines."\<C-e>".l:extra_lines.l:move_cmd
  else
    exec "normal! ".l:extra_lines."\<C-y>".l:extra_lines.l:move_cmd
  endif
endfunction

function! s:get_ms_since(time)
  let cost = split(reltimestr(reltime(a:time)), '\.')
  return str2nr(cost[0])*1000 + str2nr(cost[1])/1000.0
endfunction

