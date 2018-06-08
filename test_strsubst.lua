
local strsubst = dofile "strsubst.lua"

strsubst.FOO = "foo"
strsubst.FOOfoo = "fofu"

local testunit

function x(str, expect)
  str=testunit..": "..str
  print("in:", str)
  local ret = strsubst(str)
  print("out:", ret)
  if expect then
    expect = testunit..": "..expect
    assert(ret == expect, ret .."  ~=  ".. expect)
    print("ok")
  end
  print("\n")
end


testunit="nosubst"
x("TEST", "TEST")
x("$FOO", "$FOO")
x("FOO{FOO}", "FOOFOO")
x("f$o{ob}ar", "f$oobar")
x("\\\\\\}\\{", "\\}{")

testunit="meta"
x("{meta={``{$FOO}}} {$meta} {$$meta}", "{$FOO} {$FOO} foo")

testunit="literals"
x("{`literal}", "literal")
x("{`li$teral}", "li$teral")
x("{`\\`literal}", "`literal")

x("{`literal{`literal}}", "literalliteral")

x("{`li\\{$\\}teral}", "li{$}teral")
x("{``li{t{e}r}al}", "li{t{e}r}al")
x("``{``li{t{e}r}al}", "``li{t{e}r}al")


testunit="nesting"
x("'5{4{3{1}3{2}3}\\$4}5'", "'5431323$45'")

testunit="escapes"
x("FOO\\{FOO\\}", "FOO{FOO}")
x("\\{$FOO\\} $FOO", "{$FOO} $FOO")


testunit="variables"
x("{$FOO}", "foo")
x("{$F{O}O}", "foo")
x("{fo$obar}", "fo")  -- undefined var $obar

x("{FOO$FOO$FOO}", "FOOfoofoo")

x("{FOO$}", "FOO")
x("{FOO$FOO}", "FOOfoo")
x("{$FOO$FOO}", "foofoo")

testunit="assign"
x("{foo=bar}", "bar")
x("{foo=bar~~}", "")
x("{foo=bar~~}foo={$foo}", "foo=bar")

x("{bar={$FOO{$FOO}}~~}{$bar}", "fofu")

testunit="ifelse"
x("{?true:false}", "false")
x("{T?true:false}", "true")
x("{?true:false}", "false")

x("{{$bar}?true:false}", "true")
x("{$bar?true:false}", "true")

x("{bar=}{$bar}", "")

x("{{$bar}?true:false}", "false")
x("{$bar?true:false}", "false")

-- does it skip over unused parts
x("{T?{true}:{!!!!}}", "true")
x("{?{!!!!}:{false}}", "false")

testunit="substr"
x("{foobar:1}", "foobar")
x("{foobar:3}", "obar")
x("{foobar:{-1}}", "r")
x("{foobar:{-3}}", "bar")

x("{foobar:x}", "foobar")
x("{foobar:xx}", "oobar")
x("{foobar:xfoo}", "bar")

x("{foobar:3:1}", "o")
x("{foobar:2:{-2}}", "ooba")
x("{foobar:{-3}:2}", "ba")

x("{foobar:x:x}", "")
x("{foobar:x:xf}", "f")

x("{foobar:x:xfoo}", "foo")
x("{foobar:xfoo:xbar}", "bar")

x("{foobar:Rfo}", "ar")
x("{foobar:rfo}", "obar")
x("{foobar:R}", "foobar")
x("{foobar:Rfoob}", "obar")

x("{foobar:Rfo:xx}", "a")
x("{foobar:rfo:xx}", "o")
x("{foobar:R:xx}", "f")
x("{foobar:Rfoob:xx}", "o")

testunit="length"
x("{#foobar}", "6")
x("{#{}}", "0")
x("{xxx#foobar}", "xxx6")
x("{xxx#foobar#foo}", "xxx63")

testunit="repeat"
x("{foo##3}", "foofoofoo")
x("{x##n{1234567890}}", "xxxxxxxxxx")

testunit="substitutions"
x("{foobar/o/x}", "fxobar")
x("{foobar//o/x}", "fxxbar")

x("{foobar/bar/baz}", "foobaz")
x("{foobarfoobar//bar/baz}", "foobazfoobaz")

x("{foobar/{[oa]+}/xx}", "fxxbar")

x("{foobar//{[oa]+}/xx}", "fxxbxxr")


testunit="case conversion"
x("{^^fooBAR123}", "FOOBAR123")
x("{,,fooBAR123}", "foobar123")


testunit="comparasions"
x("{a==b}", "")
x("{a==a}", "true")
x("{{10.0}#=={10}}", "true")

x("{a!=b}", "true")
x("{a!=a}", "")
x("{{10.0}#!={10}}", "")


testunit="arithmetic"
x("{1#+2}", "3")
x("{#+2}", "nan")
x("{1#+}", "nan")
x("{-2#+}", "nan")

x("{2#/0}", "inf")
x("{10#/2}", "5")
x("{10#/foo}", "nan")

testunit="logic"

x("{true1||true2}", "true1")
x("{true1||}", "true1")
x("{||true2}", "true2")
x("{||}", "")

x("{true1&&true2}", "true2")
x("{true1&&}", "")
x("{&&true2}", "")
x("{&&}", "")

x("{!!true1}", "")

x("{!!}", "true")


-- yes I test the examples from the documentation
testunit="documentation examples"
-- generate with:  sed 's/--:.*strsubst\.subst(\(".*"\)) == \(".*"\)/x(\1, \2)/p; d' <strsubst.lua
os.execute(
  [[
    sed 's/--: *strsubst \(".*"\) == \(".*"\)/x(\1, \2)/p; d' <strsubst.lua >gentest.lua
  ]]
)

dofile('gentest.lua')


