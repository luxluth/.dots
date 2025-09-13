" Vim syntax file
" Language: Bleep
" Extension: .bp

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "bleep"
let &l:commentstring = '// %s'

" Strings
syntax region bleepString start=/"/ end=/"/ skip=/\\"/
highlight default link bleepString String

" Numbers
syntax match bleepNumber /\<\d\+\>/
syntax match bleepHex /\<0x[0-9a-fA-F]\+\>/
syntax keyword bleepBool true false
highlight default link bleepNumber Number
highlight default link bleepHex Number
highlight default link bleepBool Number

" Keywords
syntax keyword bleepKeyword alias return const if else for while enum struct trait ref own impl let mut static
highlight link bleepKeyword Keyword

" Types (built-in and user-defined)
syntax keyword bleepType s8 s16 s32 s64 void u8 u16 u32 u64 usize str bool
syntax match bleepType /\<\u\w*\>/  " CamelCase types
highlight link bleepType Type

" Constants (enum variants, uppercase)
syntax match bleepConstant /\<\u[A-Z0-9_]+\>/ " Uppercase constants
syntax match bleepConstant /\.\u\w\+/ " .STDOUT
highlight link bleepConstant Constant

" Operators
syntax match bleepOperator /->/
syntax match bleepOperator /as/
syntax match bleepOperator /;/
syntax match bleepOperator /[-+/*%=<>!:\.()\[\]{}&,]/
syntax match bleepOperator /++\|--/
syntax match bleepOperator /==\|!=\|<=\|>=\|&&\|||/
highlight link bleepOperator Operator

" Function names (approximation)
syntax match bleepFunction /\<\w\+\>\ze\s*=\s*(/
highlight link bleepFunction Function

syntax match bleepFuncCall /\<\w\+\>\ze\s*(/
highlight link bleepFuncCall Function

" Preprocessor directives
syntax match bleepPreProcWord /\$\(use\|entry\|primitive\|intrinsic\|embed\|sizeof\|self\|unreachable\|todo\|asm\|target\|extern\)\>/
highlight link bleepPreProcWord PreProc

" Comments
syntax region bleepComment start="//" end="$"
highlight default link bleepComment Comment

