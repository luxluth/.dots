; ============================
; plain block text
; (Fallback when html_block is a single text node)
; Inject Lua for the lines between the tags by trimming first/last lines
; ============================
((html_block) @injection.content
  (#match? @injection.content "(?s)^\\s*<lua>\\s*\\n[\\s\\S]*\\n\\s*</lua>\\s*$")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.language "lua")
  (#set! injection.combined))

; ============================
; Inline single-line case: <lua> ... </lua> inside a paragraph
; Inject only the inner content (exclude the tags with fixed offsets)
; ============================
((inline) @injection.content
  (#match? @injection.content "<lua>[^\\n]*</lua>")
  ; start +5 to skip "<lua>", end -6 to skip "</lua>"
  (#offset! @injection.content 0 5 0 -6)
  (#set! injection.language "lua")
  (#set! injection.combined))
