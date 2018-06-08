-- This file was automatically generated for the LuaDist project.

package = "strsubst"
version = "0.4-1"
-- LuaDist source
source = {
  tag = "0.4-1",
  url = "git://github.com/LuaDist-testing/strsubst.git"
}
-- Original source
-- source = {
--    url = "git://git.pipapo.org/luastrsubst",
--    tag = "v0.4"
-- }
description = {
   summary = "String substitution engine",
   detailed = [[
            Replacing expressions within strings. An expression is defined as possibly nested
            sequence of text, operators and subexpressions in braces.
]],
   homepage = "http://git.pipapo.org/?p=luastrsubst",
   license = "GPL2+"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      strsubst = "strsubst.lua"
   }
}