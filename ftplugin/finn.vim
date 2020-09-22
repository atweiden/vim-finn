" Copyright (c) 2019 Junegunn Choi
" Copyright (c) 2020 Andy Weidenbaum
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

setlocal comments=bf:-,bf:*,bf:@,bf:$,bf:o,bf:x,bf:+,bf:=,bf:>,bf:#,bf:::

function! s:hl()
  return map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

function! s:indent()
  let hl = s:hl()
  if empty(hl)
    return -1
  endif
  return max(add(map(filter(hl, "v:val =~ '^indent[0-9]*$'"),
                   \ "str2nr(substitute(v:val, '[^0-9]', '', 'g'))"), 0))
endfunction

function! s:repeatable(function) abort
  let &operatorfunc = a:function
  return 'g@l'
endfunction

function! s:progress(fw, cnt)
  let cnt = a:cnt
  while cnt
    let opos = getpos('.')
    while 1
      let pos = getpos('.')
      call search('^\k', a:fw ? '' : 'b')
      if get(s:hl(), 0, '') == 'topLevel'
        let cnt -= 1
        break
      endif
      if getpos('.') == pos
        call setpos('.', opos)
        return
      endif
    endwhile
  endwhile
endfunction

function! s:progress_fw(ignore)
  call s:progress(1, v:count1)
endfunction

function! s:progress_bw(ignore)
  call s:progress(0, v:count1)
endfunction

function! s:bullets_progress(top, fw, cnt)
  let cnt = a:cnt
  while cnt
    call search(printf('^%s\zs%s',
                    \ a:top ? '' : '\s*',
                    \ finn#_bullets()),
              \ printf('%ssz', a:fw ? '' : 'b'))
    let cnt -= 1
  endwhile
endfunction

function! s:bullets_progress_fw(ignore)
  call s:bullets_progress(0, 1, v:count1)
endfunction

function! s:bullets_progress_bw(ignore)
  call s:bullets_progress(0, 0, v:count1)
endfunction

function! s:bullets_progress_fw_top(ignore)
  call s:bullets_progress(1, 1, v:count1)
endfunction

function! s:bullets_progress_bw_top(ignore)
  call s:bullets_progress(1, 0, v:count1)
endfunction

nnoremap <buffer> <silent> <expr> [[ <sid>repeatable('<sid>progress_bw')
nnoremap <buffer> <silent> <expr> ]] <sid>repeatable('<sid>progress_fw')
xnoremap <buffer> <silent> <expr> [[ '<esc>:<c-u>execute "normal ' . v:count . '[[mzgv`z"<CR>'
xnoremap <buffer> <silent> <expr> ]] '<esc>:<c-u>execute "normal ' . v:count . ']]mzgv`z"<CR>'

nnoremap <buffer> <silent> <expr> ( <sid>repeatable('<sid>bullets_progress_bw')
nnoremap <buffer> <silent> <expr> ) <sid>repeatable('<sid>bullets_progress_fw')
xnoremap <buffer> <silent> <expr> ( '<esc>:<c-u>execute "normal ' . v:count . '(mzgv`z"<CR>'
xnoremap <buffer> <silent> <expr> ) '<esc>:<c-u>execute "normal ' . v:count . ')mzgv`z"<CR>'

nnoremap <buffer> <silent> <expr> [] <sid>repeatable('<sid>bullets_progress_bw_top')
nnoremap <buffer> <silent> <expr> ][ <sid>repeatable('<sid>bullets_progress_fw_top')
xnoremap <buffer> <silent> <expr> [] '<esc>:<c-u>execute "normal ' . v:count . '[]mzgv`z"<CR>'
xnoremap <buffer> <silent> <expr> ][ '<esc>:<c-u>execute "normal ' . v:count . '][mzgv`z"<CR>'

function! s:bullet()
  let line = getline('.')
  let indent = matchstr(line, '^\s*')
  let rest = line[len(indent):]
  let bullet = matchstr(rest, '^'.finn#_bullets().'\+')
  if empty(bullet)
    return "\<cr>"
  elseif bullet =~ '^[0-9]'
    let match = matchlist(bullet, '^\([0-9]\+\)\(.\)')
    let num   = str2nr(match[1])
    let tail  = match[2]
    return "\<cr>".(num + 1).tail." "
  elseif bullet =~ '^\[.\]'
    return "\<cr>".bullet
  endif
  let ret = "\<cr>"
  for _ in range(len(bullet) / &shiftwidth)
    let ret .= "\<bs>"
  endfor
  return ret.bullet
endfunction

if finn#config#enable_bullet_mappings()
  inoremap <buffer> <expr> <esc><cr> <sid>bullet()
  nnoremap <buffer> <expr> <esc><cr> 'A' . <sid>bullet()
endif
