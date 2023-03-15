" Vim syntax file
" Language:     Rune
" Maintainer:   Patrick Walton <pcwalton@mozilla.com>
" Maintainer:   Ben Blum <bblum@cs.cmu.edu>
" Maintainer:   Chris Morgan <me@chrismorgan.info>
" Last Change:  Feb 24, 2016
" For bugs, patches and license go to https://github.com/rune-lang/rune.vim

if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

" Syntax definitions {{{1
" Basic keywords {{{2
syn keyword   runeConditional match if else
syn keyword   runeRepeat for loop while
syn keyword   runeTypedef type nextgroup=runeIdentifier skipwhite skipempty
syn keyword   runeStructure struct enum nextgroup=runeIdentifier skipwhite skipempty
syn keyword   runeUnion union nextgroup=runeIdentifier skipwhite skipempty contained
syn match runeUnionContextual /\<union\_s\+\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*/ transparent contains=runeUnion
syn keyword   runeOperator    as

syn match     runeAssert      "\<assert\(\w\)*!" contained
syn match     runePanic       "\<panic\(\w\)*!" contained
syn keyword   runeKeyword     break
syn keyword   runeKeyword     box nextgroup=runeBoxPlacement skipwhite skipempty
syn keyword   runeKeyword     continue
syn keyword   runeKeyword     extern nextgroup=runeExternCrate,runeObsoleteExternMod skipwhite skipempty
syn keyword   runeKeyword     fn nextgroup=runeFuncName skipwhite skipempty
syn keyword   runeKeyword     in impl let
syn keyword   runeKeyword     pub nextgroup=runePubScope skipwhite skipempty
syn keyword   runeKeyword     return
syn keyword   runeSuper       super
syn keyword   runeKeyword     unsafe where
syn keyword   runeKeyword     use nextgroup=runeModPath skipwhite skipempty
" FIXME: Scoped impl's name is also fallen in this category
syn keyword   runeKeyword     mod trait nextgroup=runeIdentifier skipwhite skipempty
syn keyword   runeStorage     move mut ref static const
syn match runeDefault /\<default\ze\_s\+\(impl\|fn\|type\|const\)\>/

syn keyword   runeInvalidBareKeyword crate

syn keyword runePubScopeCrate crate contained
syn match runePubScopeDelim /[()]/ contained
syn match runePubScope /([^()]*)/ contained contains=runePubScopeDelim,runePubScopeCrate,runeSuper,runeModPath,runeModPathSep,runeSelf transparent

syn keyword   runeExternCrate crate contained nextgroup=runeIdentifier,runeExternCrateString skipwhite skipempty
" This is to get the `bar` part of `extern crate "foo" as bar;` highlighting.
syn match   runeExternCrateString /".*"\_s*as/ contained nextgroup=runeIdentifier skipwhite transparent skipempty contains=runeString,runeOperator
syn keyword   runeObsoleteExternMod mod contained nextgroup=runeIdentifier skipwhite skipempty

syn match     runeIdentifier  contains=runeIdentifierPrime "\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*" display contained
syn match     runeFuncName    "\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*" display contained

syn region    runeBoxPlacement matchgroup=runeBoxPlacementParens start="(" end=")" contains=TOP contained
" Ideally we'd have syntax rules set up to match arbitrary expressions. Since
" we don't, we'll just define temporary contained rules to handle balancing
" delimiters.
syn region    runeBoxPlacementBalance start="(" end=")" containedin=runeBoxPlacement transparent
syn region    runeBoxPlacementBalance start="\[" end="\]" containedin=runeBoxPlacement transparent
" {} are handled by runeFoldBraces

syn region runeMacroRepeat matchgroup=runeMacroRepeatDelimiters start="$(" end=")" contains=TOP nextgroup=runeMacroRepeatCount
syn match runeMacroRepeatCount ".\?[*+]" contained
syn match runeMacroVariable "$\w\+"

" Reserved (but not yet used) keywords {{{2
syn keyword   runeReservedKeyword alignof become do offsetof priv pure sizeof typeof unsized yield abstract virtual final override macro

" Built-in types {{{2
syn keyword   runeType        isize usize char bool u8 u16 u32 u64 u128 f32
syn keyword   runeType        f64 i8 i16 i32 i64 i128 str Self

" Things from the libstd v1 prelude (src/libstd/prelude/v1.rs) {{{2
" This section is just straight transformation of the contents of the prelude,
" to make it easy to update.

" Reexported core operators {{{3
syn keyword   runeTrait       Copy Send Sized Sync
syn keyword   runeTrait       Drop Fn FnMut FnOnce

" Reexported functions {{{3
" There’s no point in highlighting these; when one writes drop( or drop::< it
" gets the same highlighting anyway, and if someone writes `let drop = …;` we
" don’t really want *that* drop to be highlighted.
"syn keyword runeFunction drop

" Reexported types and traits {{{3
syn keyword runeTrait Box
syn keyword runeTrait ToOwned
syn keyword runeTrait Clone
syn keyword runeTrait PartialEq PartialOrd Eq Ord
syn keyword runeTrait AsRef AsMut Into From
syn keyword runeTrait Default
syn keyword runeTrait Iterator Extend IntoIterator
syn keyword runeTrait DoubleEndedIterator ExactSizeIterator
syn keyword runeEnum Option
syn keyword runeEnumVariant Some None
syn keyword runeEnum Result
syn keyword runeEnumVariant Ok Err
syn keyword runeTrait SliceConcatExt
syn keyword runeTrait String ToString
syn keyword runeTrait Vec

" Other syntax {{{2
syn keyword   runeSelf        self
syn keyword   runeBoolean     true false

" If foo::bar changes to foo.bar, change this ("::" to "\.").
" If foo::bar changes to Foo::bar, change this (first "\w" to "\u").
syn match     runeModPath     "\w\(\w\)*::[^<]"he=e-3,me=e-3
syn match     runeModPathSep  "::"

syn match     runeFuncCall    "\w\(\w\)*("he=e-1,me=e-1
syn match     runeFuncCall    "\w\(\w\)*::<"he=e-3,me=e-3 " foo::<T>();

" This is merely a convention; note also the use of [A-Z], restricting it to
" latin identifiers rather than the full Unicode uppercase. I have not used
" [:upper:] as it depends upon 'noignorecase'
"syn match     runeCapsIdent    display "[A-Z]\w\(\w\)*"

syn match     runeOperator     display "\%(+\|-\|/\|*\|=\|\^\|&\||\|!\|>\|<\|%\)=\?"
" This one isn't *quite* right, as we could have binary-& with a reference
syn match     runeSigil        display /&\s\+[&~@*][^)= \t\r\n]/he=e-1,me=e-1
syn match     runeSigil        display /[&~@*][^)= \t\r\n]/he=e-1,me=e-1
" This isn't actually correct; a closure with no arguments can be `|| { }`.
" Last, because the & in && isn't a sigil
syn match     runeOperator     display "&&\|||"
" This is runeArrowCharacter rather than runeArrow for the sake of matchparen,
" so it skips the ->; see http://stackoverflow.com/a/30309949 for details.
syn match     runeArrowCharacter display "->"
syn match     runeQuestionMark display "?\([a-zA-Z]\+\)\@!"

syn match     runeMacro       '\w\(\w\)*!' contains=runeAssert,runePanic
syn match     runeMacro       '#\w\(\w\)*' contains=runeAssert,runePanic

syn match     runeEscapeError   display contained /\\./
syn match     runeEscape        display contained /\\\([nrt0\\'"]\|x\x\{2}\)/
syn match     runeEscapeUnicode display contained /\\u{\x\{1,6}}/
syn match     runeStringContinuation display contained /\\\n\s*/
syn region    runeString      start=+b"+ skip=+\\\\\|\\"+ end=+"+ contains=runeEscape,runeEscapeError,runeStringContinuation
syn region    runeString      start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=runeEscape,runeEscapeUnicode,runeEscapeError,runeStringContinuation,@Spell
syn region    runeString      start='b\?r\z(#*\)"' end='"\z1' contains=@Spell

syn region    runeAttribute   start="#!\?\[" end="\]" contains=runeString,runeDerive,runeCommentLine,runeCommentBlock,runeCommentLineDocError,runeCommentBlockDocError
syn region    runeDerive      start="derive(" end=")" contained contains=runeDeriveTrait
" This list comes from src/libsyntax/ext/deriving/mod.rs
" Some are deprecated (Encodable, Decodable) or to be removed after a new snapshot (Show).
syn keyword   runeDeriveTrait contained Clone Hash RunecEncodable RunecDecodable Encodable Decodable PartialEq Eq PartialOrd Ord Rand Show Debug Default FromPrimitive Send Sync Copy

" Number literals
syn match     runeDecNumber   display "\<[0-9][0-9_]*\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     runeHexNumber   display "\<0x[a-fA-F0-9_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     runeOctNumber   display "\<0o[0-7_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match     runeBinNumber   display "\<0b[01_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="

" Special case for numbers of the form "1." which are float literals, unless followed by
" an identifier, which makes them integer literals with a method call or field access,
" or by another ".", which makes them integer literals followed by the ".." token.
" (This must go first so the others take precedence.)
syn match     runeFloat       display "\<[0-9][0-9_]*\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\|\.\)\@!"
" To mark a number as a normal float, it must have at least one of the three things integral values don't have:
" a decimal point and more numbers; an exponent; and a type suffix.
syn match     runeFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+-]\=[0-9_]\+\)\=\(f32\|f64\)\="
syn match     runeFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+-]\=[0-9_]\+\)\(f32\|f64\)\="
syn match     runeFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+-]\=[0-9_]\+\)\=\(f32\|f64\)"

" For the benefit of delimitMate
syn region runeLifetimeCandidate display start=/&'\%(\([^'\\]\|\\\(['nrt0\\\"]\|x\x\{2}\|u{\x\{1,6}}\)\)'\)\@!/ end=/[[:cntrl:][:space:][:punct:]]\@=\|$/ contains=runeSigil,runeLifetime
syn region runeGenericRegion display start=/<\%('\|[^[cntrl:][:space:][:punct:]]\)\@=')\S\@=/ end=/>/ contains=runeGenericLifetimeCandidate
syn region runeGenericLifetimeCandidate display start=/\%(<\|,\s*\)\@<='/ end=/[[:cntrl:][:space:][:punct:]]\@=\|$/ contains=runeSigil,runeLifetime

"runeLifetime must appear before runeCharacter, or chars will get the lifetime highlighting
syn match     runeLifetime    display "\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*"
syn match     runeLabel       display "\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*:"
syn match   runeCharacterInvalid   display contained /b\?'\zs[\n\r\t']\ze'/
" The groups negated here add up to 0-255 but nothing else (they do not seem to go beyond ASCII).
syn match   runeCharacterInvalidUnicode   display contained /b'\zs[^[:cntrl:][:graph:][:alnum:][:space:]]\ze'/
syn match   runeCharacter   /b'\([^\\]\|\\\(.\|x\x\{2}\)\)'/ contains=runeEscape,runeEscapeError,runeCharacterInvalid,runeCharacterInvalidUnicode
syn match   runeCharacter   /'\([^\\]\|\\\(.\|x\x\{2}\|u{\x\{1,6}}\)\)'/ contains=runeEscape,runeEscapeUnicode,runeEscapeError,runeCharacterInvalid

syn match runeShebang /\%^#![^[].*/
syn region runeCommentLine                                                  start="//"                      end="$"   contains=runeTodo,@Spell
syn region runeCommentLineDoc                                               start="//\%(//\@!\|!\)"         end="$"   contains=runeTodo,@Spell
syn region runeCommentLineDocError                                          start="//\%(//\@!\|!\)"         end="$"   contains=runeTodo,@Spell contained
syn region runeCommentBlock             matchgroup=runeCommentBlock         start="/\*\%(!\|\*[*/]\@!\)\@!" end="\*/" contains=runeTodo,runeCommentBlockNest,@Spell
syn region runeCommentBlockDoc          matchgroup=runeCommentBlockDoc      start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=runeTodo,runeCommentBlockDocNest,@Spell
syn region runeCommentBlockDocError     matchgroup=runeCommentBlockDocError start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=runeTodo,runeCommentBlockDocNestError,@Spell contained
syn region runeCommentBlockNest         matchgroup=runeCommentBlock         start="/\*"                     end="\*/" contains=runeTodo,runeCommentBlockNest,@Spell contained transparent
syn region runeCommentBlockDocNest      matchgroup=runeCommentBlockDoc      start="/\*"                     end="\*/" contains=runeTodo,runeCommentBlockDocNest,@Spell contained transparent
syn region runeCommentBlockDocNestError matchgroup=runeCommentBlockDocError start="/\*"                     end="\*/" contains=runeTodo,runeCommentBlockDocNestError,@Spell contained transparent
" FIXME: this is a really ugly and not fully correct implementation. Most
" importantly, a case like ``/* */*`` should have the final ``*`` not being in
" a comment, but in practice at present it leaves comments open two levels
" deep. But as long as you stay away from that particular case, I *believe*
" the highlighting is correct. Due to the way Vim's syntax engine works
" (greedy for start matches, unlike Rune's tokeniser which is searching for
" the earliest-starting match, start or end), I believe this cannot be solved.
" Oh you who would fix it, don't bother with things like duplicating the Block
" rules and putting ``\*\@<!`` at the start of them; it makes it worse, as
" then you must deal with cases like ``/*/**/*/``. And don't try making it
" worse with ``\%(/\@<!\*\)\@<!``, either...

syn keyword runeTodo contained TODO FIXME XXX NB NOTE

" Folding rules {{{2
" Trivial folding rules to begin with.
" FIXME: use the AST to make really good folding
syn region runeFoldBraces start="{" end="}" transparent fold

" Default highlighting {{{1
hi def link runeDecNumber       runeNumber
hi def link runeHexNumber       runeNumber
hi def link runeOctNumber       runeNumber
hi def link runeBinNumber       runeNumber
hi def link runeIdentifierPrime runeIdentifier
hi def link runeTrait           runeType
hi def link runeDeriveTrait     runeTrait

hi def link runeMacroRepeatCount   runeMacroRepeatDelimiters
hi def link runeMacroRepeatDelimiters   Macro
hi def link runeMacroVariable Define
hi def link runeSigil         StorageClass
hi def link runeEscape        Special
hi def link runeEscapeUnicode runeEscape
hi def link runeEscapeError   Error
hi def link runeStringContinuation Special
hi def link runeString        String
hi def link runeCharacterInvalid Error
hi def link runeCharacterInvalidUnicode runeCharacterInvalid
hi def link runeCharacter     Character
hi def link runeNumber        Number
hi def link runeBoolean       Boolean
hi def link runeEnum          runeType
hi def link runeEnumVariant   runeConstant
hi def link runeConstant      Constant
hi def link runeSelf          Constant
hi def link runeFloat         Float
hi def link runeArrowCharacter runeOperator
hi def link runeOperator      Operator
hi def link runeKeyword       Keyword
hi def link runeTypedef       Keyword " More precise is Typedef, but it doesn't feel right for Rune
hi def link runeStructure     Keyword " More precise is Structure
hi def link runeUnion         runeStructure
hi def link runePubScopeDelim Delimiter
hi def link runePubScopeCrate runeKeyword
hi def link runeSuper         runeKeyword
hi def link runeReservedKeyword Error
hi def link runeRepeat        Conditional
hi def link runeConditional   Conditional
hi def link runeIdentifier    Identifier
hi def link runeCapsIdent     runeIdentifier
hi def link runeModPath       Include
hi def link runeModPathSep    Delimiter
hi def link runeFunction      Function
hi def link runeFuncName      Function
hi def link runeFuncCall      Function
hi def link runeShebang       Comment
hi def link runeCommentLine   Comment
hi def link runeCommentLineDoc SpecialComment
hi def link runeCommentLineDocError Error
hi def link runeCommentBlock  runeCommentLine
hi def link runeCommentBlockDoc runeCommentLineDoc
hi def link runeCommentBlockDocError Error
hi def link runeAssert        PreCondit
hi def link runePanic         PreCondit
hi def link runeMacro         Macro
hi def link runeType          Type
hi def link runeTodo          Todo
hi def link runeAttribute     PreProc
hi def link runeDerive        PreProc
hi def link runeDefault       StorageClass
hi def link runeStorage       StorageClass
hi def link runeObsoleteStorage Error
hi def link runeLifetime      Special
hi def link runeLabel         Label
hi def link runeInvalidBareKeyword Error
hi def link runeExternCrate   runeKeyword
hi def link runeObsoleteExternMod Error
hi def link runeBoxPlacementParens Delimiter
hi def link runeQuestionMark  Special

" Other Suggestions:
" hi runeAttribute ctermfg=cyan
" hi runeDerive ctermfg=cyan
" hi runeAssert ctermfg=yellow
" hi runePanic ctermfg=red
" hi runeMacro ctermfg=magenta

syn sync minlines=200
syn sync maxlines=500

let b:current_syntax = "rune"
