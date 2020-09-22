let s:cpo_save = &cpo
set cpo&vim

function! finn#config#enable_bullet_mappings() abort
  return get(g:, 'finn_enable_bullet_mappings', 1)
endfunction

let &cpo = s:cpo_save
unlet! s:cpo_save

" vim: set filetype=vim foldmethod=marker foldlevel=0 nowrap:
