; Inject Lua for <script type="lua"> ... </script>
((element
   (start_tag
     (tag_name) @t (#eq? @t "script")
     (attribute
       (attribute_name) @an (#eq? @an "type")
       (quoted_attribute_value (attribute_value) @atype)))
   (text) @injection.content
   (end_tag (tag_name) @t2 (#eq? @t2 "script")))
 (#match? @atype "^(lua|text/lua|application/lua)$")
 (#set! injection.language "lua")
 (#set! injection.combined))
