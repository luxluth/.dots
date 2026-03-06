; ============================
; plain block text tags (one tag per line)
; Highlight entire lines that are just <lua> or </lua>
; ============================
((html_block) @flm.tag.open
  (#match? @flm.tag.open "^\\s*<lua>\\s*$"))

((html_block) @flm.tag.close
  (#match? @flm.tag.close "^\\s*</lua>\\s*$"))

; (Optional) If you also want to tint single-line inline tags,
; uncomment below, but note it will color the whole inline node.
; ((inline) @flm.tag.inline
;   (#match? @flm.tag.inline "<lua>|</lua>"))
