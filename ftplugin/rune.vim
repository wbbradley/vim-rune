" Language:     Rune
" Description:  Vim ftplugin for Rune
" Maintainer:   Chris Morgan <me@chrismorgan.info>
" Maintainer:   Kevin Ballard <kevin@sb.org>
" Last Change:  June 08, 2016
" For bugs, patches and license go to https://github.com/rune-lang/rune.vim 

if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

augroup rune.vim
autocmd!

" Variables {{{1

" The rune source code at present seems to typically omit a leader on /*!
" comments, so we'll use that as our default, but make it easy to switch.
" This does not affect indentation at all (I tested it with and without
" leader), merely whether a leader is inserted by default or not.
if exists("g:rune_bang_comment_leader") && g:rune_bang_comment_leader != 0
	" Why is the `,s0:/*,mb:\ ,ex:*/` there, you ask? I don't understand why,
	" but without it, */ gets indented one space even if there were no
	" leaders. I'm fairly sure that's a Vim bug.
	setlocal comments=s1:/*,mb:*,ex:*/,s0:/*,mb:\ ,ex:*/,:///,://!,://
else
	setlocal comments=s0:/*!,m:\ ,ex:*/,s1:/*,mb:*,ex:*/,:///,://!,://
endif
setlocal commentstring=//%s
setlocal formatoptions-=t formatoptions+=croqnl
" j was only added in 7.3.541, so stop complaints about its nonexistence
silent! setlocal formatoptions+=j

" smartindent will be overridden by indentexpr if filetype indent is on, but
" otherwise it's better than nothing.
setlocal smartindent nocindent

if !exists("g:rune_recommended_style") || g:rune_recommended_style != 0
	setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
	setlocal textwidth=99
endif

" This includeexpr isn't perfect, but it's a good start
setlocal includeexpr=substitute(v:fname,'::','/','g')

setlocal suffixesadd=.rs

if exists("g:ftplugin_rune_source_path")
    let &l:path=g:ftplugin_rune_source_path . ',' . &l:path
endif

if exists("g:loaded_delimitMate")
	if exists("b:delimitMate_excluded_regions")
		let b:rune_original_delimitMate_excluded_regions = b:delimitMate_excluded_regions
	endif

	let s:delimitMate_extra_excluded_regions = ',runeLifetimeCandidate,runeGenericLifetimeCandidate'

	" For this buffer, when delimitMate issues the `User delimitMate_map`
	" event in the autocommand system, add the above-defined extra excluded
	" regions to delimitMate's state, if they have not already been added.
	autocmd User <buffer>
		\ if expand('<afile>') ==# 'delimitMate_map' && match(
		\     delimitMate#Get("excluded_regions"),
		\     s:delimitMate_extra_excluded_regions) == -1
		\|  let b:delimitMate_excluded_regions =
		\       delimitMate#Get("excluded_regions")
		\       . s:delimitMate_extra_excluded_regions
		\|endif

	" For this buffer, when delimitMate issues the `User delimitMate_unmap`
	" event in the autocommand system, delete the above-defined extra excluded
	" regions from delimitMate's state (the deletion being idempotent and
	" having no effect if the extra excluded regions are not present in the
	" targeted part of delimitMate's state).
	autocmd User <buffer>
		\ if expand('<afile>') ==# 'delimitMate_unmap'
		\|  let b:delimitMate_excluded_regions = substitute(
		\       delimitMate#Get("excluded_regions"),
		\       '\C\V' . s:delimitMate_extra_excluded_regions,
		\       '', 'g')
		\|endif
endif

if has("folding") && exists('g:rune_fold') && g:rune_fold != 0
	let b:rune_set_foldmethod=1
	setlocal foldmethod=syntax
	if g:rune_fold == 2
		setlocal foldlevel<
	else
		setlocal foldlevel=99
	endif
endif

if has('conceal') && exists('g:rune_conceal') && g:rune_conceal != 0
	let b:rune_set_conceallevel=1
	setlocal conceallevel=2
endif

" Motion Commands {{{1

" Bind motion commands to support hanging indents
nnoremap <silent> <buffer> [[ :call rune#Jump('n', 'Back')<CR>
nnoremap <silent> <buffer> ]] :call rune#Jump('n', 'Forward')<CR>
xnoremap <silent> <buffer> [[ :call rune#Jump('v', 'Back')<CR>
xnoremap <silent> <buffer> ]] :call rune#Jump('v', 'Forward')<CR>
onoremap <silent> <buffer> [[ :call rune#Jump('o', 'Back')<CR>
onoremap <silent> <buffer> ]] :call rune#Jump('o', 'Forward')<CR>

" Commands {{{1

" See |:RuneRun| for docs
command! -nargs=* -complete=file -bang -buffer RuneRun call rune#Run(<bang>0, <q-args>)

" See |:RuneExpand| for docs
command! -nargs=* -complete=customlist,rune#CompleteExpand -bang -buffer RuneExpand call rune#Expand(<bang>0, <q-args>)

" See |:RuneEmitIr| for docs
command! -nargs=* -buffer RuneEmitIr call rune#Emit("llvm-ir", <q-args>)

" See |:RuneEmitAsm| for docs
command! -nargs=* -buffer RuneEmitAsm call rune#Emit("asm", <q-args>)

" See |:RunePlay| for docs
command! -range=% RunePlay :call rune#Play(<count>, <line1>, <line2>, <f-args>)

" See |:RuneFmt| for docs
command! -buffer RuneFmt call runefmt#Format()

" See |:RuneFmtRange| for docs
command! -range -buffer RuneFmtRange call runefmt#FormatRange(<line1>, <line2>)

" Mappings {{{1

" Bind ⌘R in MacVim to :RuneRun
nnoremap <silent> <buffer> <D-r> :RuneRun<CR>
" Bind ⌘⇧R in MacVim to :RuneRun! pre-filled with the last args
nnoremap <buffer> <D-R> :RuneRun! <C-r>=join(b:rune_last_runec_args)<CR><C-\>erune#AppendCmdLine(' -- ' . join(b:rune_last_args))<CR>

if !exists("b:rune_last_runec_args") || !exists("b:rune_last_args")
	let b:rune_last_runec_args = []
	let b:rune_last_args = []
endif

" Cleanup {{{1

let b:undo_ftplugin = "
		\ setlocal formatoptions< comments< commentstring< includeexpr< suffixesadd<
		\|setlocal tabstop< shiftwidth< softtabstop< expandtab< textwidth<
		\|if exists('b:rune_original_delimitMate_excluded_regions')
		  \|let b:delimitMate_excluded_regions = b:rune_original_delimitMate_excluded_regions
		  \|unlet b:rune_original_delimitMate_excluded_regions
		\|else
		  \|unlet! b:delimitMate_excluded_regions
		\|endif
		\|if exists('b:rune_set_foldmethod')
		  \|setlocal foldmethod< foldlevel<
		  \|unlet b:rune_set_foldmethod
		\|endif
		\|if exists('b:rune_set_conceallevel')
		  \|setlocal conceallevel<
		  \|unlet b:rune_set_conceallevel
		\|endif
		\|unlet! b:rune_last_runec_args b:rune_last_args
		\|delcommand RuneRun
		\|delcommand RuneExpand
		\|delcommand RuneEmitIr
		\|delcommand RuneEmitAsm
		\|delcommand RunePlay
		\|nunmap <buffer> <D-r>
		\|nunmap <buffer> <D-R>
		\|nunmap <buffer> [[
		\|nunmap <buffer> ]]
		\|xunmap <buffer> [[
		\|xunmap <buffer> ]]
		\|ounmap <buffer> [[
		\|ounmap <buffer> ]]
		\|set matchpairs-=<:>
		\"

" }}}1

" Code formatting on save
if get(g:, "runefmt_autosave", 0)
	autocmd BufWritePre *.rs silent! call runefmt#Format()
endif

augroup END

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set noet sw=8 ts=8:
