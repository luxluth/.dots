" Vim syntax file
" Language: Bleep
" Extension: .bp

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "bleep"

" Strings
syntax region bleepString start=/"/ end=/"/ skip=/\\"/
highlight default link bleepString String

" Numbers
syntax match bleepNumber /\<\d\+\>/
syntax match bleepHex /\<0x[0-9a-fA-F]\+\>/
highlight default link bleepNumber Number
highlight default link bleepHex Number

" Preprocessor directives
syntax keyword bleepPreProcWord use entry primitive embed sizeof self
syntax match bleepPreProc /\$\w\+ / contains=bleepPreProcWord
highlight link bleepPreProc PreProc

" Keywords
syntax keyword bleepKeyword var return const if else for while enum struct
highlight link bleepKeyword Keyword

" Types (built-in and user-defined)
syntax keyword bleepType s8 s16 s32 s64 void
syntax match bleepType /\<\u\w*\>/  " CamelCase types
highlight link bleepType Type

" Constants (enum variants, uppercase)
syntax match bleepConstant /\<\u[A-Z0-9_]+\>/ " Uppercase constants
syntax match bleepConstant /\.\u\w\+/ " .STDOUT
highlight link bleepConstant Constant

" Operators
syntax match bleepOperator /->/
syntax match bleepOperator /[-+/*%=<>!:\.]/
syntax match bleepOperator /++\|--/
syntax match bleepOperator /==\|!=\|<=\|>=\|&&\|||/
highlight link bleepOperator Operator

" Function names (approximation)
syntax match bleepFunction /\<\w\+\>\ze\s*=\s*(/
highlight link bleepFunction Function

" Comments
syntax region bleepComment start="//" end="$"
highlight default link bleepComment Comment

