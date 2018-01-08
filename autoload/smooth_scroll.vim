" ==============================================================================
" Author: Chad Skeeters/Terry Ma
" Description: Scroll the screen smoothly to retain better context. Useful for
" replacing Vim's default scrolling behavior with CTRL-D, CTRL-U, CTRL-B, and
" CTRL-F, zz, zt, zb
" ==============================================================================

let s:save_cpo = &cpo
set cpo&vim

" ==============================================================================
" Global Functions
" ==============================================================================

" Scroll the screen up
function! smooth_scroll#up(dist)
  let move_only = max([0, &scrolloff - (line('w$') - line("."))])
  call s:smooth_scroll('u', a:dist - l:move_only, 1)
endfunction

" Scroll the screen down
function! smooth_scroll#down(dist)
  let move_only = max([0, &scrolloff - (line(".") - line('w0'))])
  call s:smooth_scroll('d', a:dist - l:move_only, 1)
endfunction

" Scroll to the center
function! smooth_scroll#center(visual)
  if a:visual
    normal! gv
  endif
  let saved_mode=mode()

  let half_win = (winheight(0) + 1) / 2
  let cur_center = line('w0') + l:half_win - 1
  let target_center = line('.')
  let num_down = l:target_center - l:cur_center
  if l:num_down > 0
    call s:smooth_scroll('d', l:num_down, 0)
  else
    call s:smooth_scroll('u', -l:num_down, 0)
  endif

  " Restore visual mode
  if l:saved_mode == "v" || l:saved_mode == "V"
    normal gv
  endif
endfunction

" Scroll to the top
function! smooth_scroll#top(visual)
  if a:visual
    normal! gv
  endif
  let saved_mode=mode()

  let cur_top = line('w0') + &scrolloff
  let target_top = line('.')
  let num_down =  l:target_top - l:cur_top
  if l:num_down > 0
    call s:smooth_scroll('d', l:num_down, 0)
  endif

  " Restore visual mode
  if l:saved_mode == "v" || l:saved_mode == "V"
    normal gv
  endif
endfunction

" Scroll to the bottom
function! smooth_scroll#bottom(visual)
  if a:visual
    normal! gv
  endif
  let saved_mode=mode()

  let cur_bottom = line('w0') + winheight(0) - &scrolloff - 1
  let target_bottom = line('.')
  let num_up = l:cur_bottom - l:target_bottom
  if l:num_up > 0
    call s:smooth_scroll('u', l:num_up, 0)
  endif

  " Restore visual mode
  if l:saved_mode == "v" || l:saved_mode == "V"
    normal gv
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

  let last_snooze=0

  if a:dir ==# 'd'
    let direction_mult=1
  else
    let direction_mult=-1
  endif

  let current_line=line(".")
  let target_line=l:current_line + a:dist * l:direction_mult

  if a:move == 1
    " Set bounds for target_line to file start and end
    let l:target_line = max([1, l:target_line])
    let l:target_line = min([line("$"), l:target_line])
  endif

  " Attempt a little bit faster each time in case we have a slow run
  let l:scroll_lines_per_draw = 1

  " This will work no matter which direction we are going
  while l:current_line != l:target_line
    let start = reltime()
    " Moving the cursor first and then scrolling the window results in cursor
    " showing up in the correct position upon redraw.  Not sure why
    exec "normal! ".l:scroll_lines_per_draw.l:move_cmd
    if a:move == 0 || line(".") - line('w0') >= &scrolloff
        if a:dir ==# 'd'
            exec "normal! ".l:scroll_lines_per_draw."\<C-e>"
        else
            exec "normal! ".l:scroll_lines_per_draw."\<C-y>"
        endif
    endif
    let current_line+=l:scroll_lines_per_draw * l:direction_mult

    redraw

    let elapsed = s:get_ms_since(start)


    let scroll_frame_duration = l:scroll_lines_per_draw * g:ms_per_line
    let snooze = l:scroll_frame_duration-l:elapsed
    if l:snooze > 0
      exec "sleep ".snooze."m"
    endif

    if l:scroll_frame_duration > l:elapsed*1.1 && l:scroll_lines_per_draw > 1
      " We can go faster
      let l:scroll_lines_per_draw = max([1, l:scroll_lines_per_draw-1])
    elseif l:scroll_frame_duration < l:elapsed*0.9
      " We need to go slower
      let l:scroll_lines_per_draw += 1
    endif

    if l:scroll_lines_per_draw > abs(l:current_line - l:target_line)
      let l:scroll_lines_per_draw = abs(l:current_line - l:target_line)
    endif
  endwhile

endfunction

function! s:get_ms_since(time)
  let cost = split(reltimestr(reltime(a:time)), '\.')
  return str2nr(cost[0])*1000 + str2nr(cost[1])/1000
endfunction

let &cpo = s:save_cpo
