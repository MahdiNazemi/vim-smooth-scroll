" ==============================================================================
" Author: Chad Skeeters/Terry Ma
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
function! smooth_scroll#up(dist)
  call s:smooth_scroll('u', a:dist, get(g:, 'scroll_follow', 0))
endfunction

" Scroll the screen down
function! smooth_scroll#down(dist)
  call s:smooth_scroll('d', a:dist, get(g:, 'scroll_follow', 0))
endfunction

" Scroll to the center
function! smooth_scroll#center()
  let half_win = (winheight(0) + 1) / 2
  let cur_center = line('w0') + l:half_win - 1
  let target_center = line('.')
  let num_down = l:target_center - l:cur_center
  if l:num_down > 0
    call s:smooth_scroll('d', l:num_down, 0)
  else
    call s:smooth_scroll('u', -l:num_down, 0)
  endif
endfunction

" Scroll to the top
function! smooth_scroll#top()
  let cur_top = line('w0') + &scrolloff
  let target_top = line('.')
  let num_down =  l:target_top - l:cur_top
  if l:num_down > 0
    call s:smooth_scroll('d', l:num_down, 0)
  endif
endfunction

" Scroll to the bottom
function! smooth_scroll#bottom()
  let cur_bottom = line('w0') + winheight(0) - &scrolloff
  let target_bottom = line('.')
  let num_up = l:cur_bottom - l:target_bottom
  if l:num_up > 0
    call s:smooth_scroll('u', l:num_up, 0)
  endif
endfunction

" ==============================================================================
" Functions
" ==============================================================================

" Scroll the window smoothly
" dir: Direction of the scroll. 'd' is downwards, 'u' is upwards
" dist: Distance, or the total number of lines to scroll
" move: when 1, move the cursor too
function! s:smooth_scroll(dir, dist, move)
  let move_cmd=''
  if a:move == 1
    if a:dir ==# 'd'
      let move_cmd='j'
    else
      let move_cmd='k'
    endif
  endif

  for i in range(a:dist/g:scroll_lines_per_draw)
    let start = reltime()
    " Moving the cursor first and then scrolling the window results in cursor
    " showing up in the correct position upon redraw.  Not sure why
    exec "normal! ".g:scroll_lines_per_draw.l:move_cmd
    if a:dir ==# 'd'
      exec "normal! ".g:scroll_lines_per_draw."\<C-e>"
    else
      exec "normal! ".g:scroll_lines_per_draw."\<C-y>"
    endif
    redraw
    let elapsed = s:get_ms_since(start)
    let snooze = g:scroll_frame_duration-l:elapsed
    if snooze > 0
      exec "sleep ".snooze."m"
    endif
  endfor

  " Make sure we move exactly a:dist when g:scroll_lines_per_draw is not 1
  let extra_lines=a:dist % g:scroll_lines_per_draw
  if l:extra_lines != 0
    if a:dir ==# 'd'
      exec "normal! ".l:extra_lines."\<C-e>".l:extra_lines.l:move_cmd
    else
      exec "normal! ".l:extra_lines."\<C-y>".l:extra_lines.l:move_cmd
    endif
  endif
endfunction

function! s:get_ms_since(time)
  let cost = split(reltimestr(reltime(a:time)), '\.')
  return str2nr(cost[0])*1000 + str2nr(cost[1])/1000
endfunction

