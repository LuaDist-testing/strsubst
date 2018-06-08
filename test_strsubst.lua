
local strsubst = dofile "strsubst.lua"

strsubst.FOO = "foo"
strsubst.FOOfoo = "fofu"

local testunit

function x(str, expect)
  str=testunit..(testunit ~= "" and ": " or "")..str
  print("in:", str)
  local ret = strsubst(str)
  print("out:", ret)
  if expect then
    expect = testunit..(testunit ~= "" and ": " or "")..expect
    assert(ret == expect, ret.."  ~=  "..expect)
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
x("{\\$}", "$")
x("{$}", "$")
x("{${}}", "")

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
x("{foo=baz}", "baz")

x("{bar={$FOO{$FOO}}~~}{$bar}", "fofu")

testunit="meta"
x("{meta={``{$FOO}}} {$meta} {$$meta}", "{$FOO} {$FOO} foo")
x("{_test:=1}{meta:={``{$_test}}}{$_test} {$$meta} {$_test}", "1 1 1")
x("{_test:=1}{meta:={``{{$_test} $_test}}}{$_test} {$$meta} {$_test}", "1 1 1 1")
x("{_test:=1}{meta:={``{{$_test}{_test:=2} $_test}}}{$_test} {$$meta} {$_test}", "1 1 2 1")

x("{meta1={``{$_$FOO}}}", "{$_$FOO}")
x("{foo$$meta1}", "foofoo")
x("{$_$$meta1}", "foo")
x("{meta2={``{$_$$meta1}}}", "{$_$$meta1}")
x("{bar$$meta2}", "barfoo")


x("{inner:={``{$_}}}{in$$inner}", "in")
x("{outer:={``{$_}{in$$inner}}}{out$$outer}", "outin")


testunit="ifelse"
x("{?true:false}", "false")
x("{T?true:false}", "true")
x("{?true:false}", "false")

x("{{$bar}?true:false}", "true")
x("{$bar?true:false}", "true")

x("{bar=}{$bar}", "")

x("{{$bar}?true:false}", "false")
x("{$bar?true:false}", "false")


testunit="linebreaks"
x([[{
?true:false
}]], "false")

x([[
yes
{
{
yes
}
}]], "yes\nyes")


x([[
{
{$condition}
?{this}
:{that}
}]], "that")

x([[
{condition:=true}{
{$condition}
?{this}
:{that}
}]], "this")


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


testunit="string match"
x("{a=~b}", "")
x("{=~}", "true")
x("{=~none}", "")
x("{none=~{^$}}", "")

testunit="comparsions"
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

strsubst.__EXPLICIT = "true"
testunit=""
x("{explicit mode\\: {foo=bar}}", "explicit mode: bar")
x("explicit mode: {foo=bar}", "explicit mode: {foo=bar}")
strsubst.__EXPLICIT = ""


testunit="partial evaluation"
strsubst.__PARTIAL = "true"


strsubst.foo = nil
strsubst.bar = nil
x("{$foo}", "{$foo}")
x("{foo:=bar}{$foo}", "bar")
strsubst.foo = nil
strsubst.bar = nil
x("{{$bar}}", "{{$bar}}")
x("{x{$bar}y}z", "{x{$bar}y}z")
x("{$foo{$bar}}", "{$foo{$bar}}")
x("{bar:=baz}{$foo{$bar}}", "{$foobaz}")
x("{foobaz:=fb}{bar:=baz}{$foo{$bar}}", "fb")
strsubst.foo = nil
strsubst.bar = nil

x("\\{$foo\\}", "\\{$foo\\}")
x("{rabarber/{$foo}/baz}", "{rabarber/{$foo}/baz}")
x("{foo:=bar}{rabarber/{$foo}/baz}", "rabazber")
strsubst.foo = nil
strsubst.bar = nil

x("{$foo?yes:no}", "{$foo?yes:no}")
x("{foo:=true}{$foo?yes:no}", "yes")
x("{foo:=}{$foo?yes:no}", "no")
strsubst.foo = nil
strsubst.bar = nil

x("{{$foo}:f:fooo}", "{{$foo}:f:fooo}")
x("{$foo:f:fooo}", "{$foo:f:fooo}")
strsubst.foo = nil
strsubst.bar = nil

x("{{$foo}||true}", "{{$foo}||true}")
x("{{$foo}&&true}", "{{$foo}&&true}")
x("{$foo||true}", "{$foo||true}")
x("{$foo&&true}", "{$foo&&true}")
strsubst.foo = nil
strsubst.bar = nil

strsubst.__PARTIAL = ""


testunit="recursion"
x("{foo:={``{$$foo}}}{$$foo}")

-- yes I test the examples from the documentation
testunit="documentation examples"
-- generate with:  sed 's/--:.*strsubst\.subst(\(".*"\)) == \(".*"\)/x(\1, \2)/p; d' <strsubst.lua
os.execute(
  [[
    sed 's/--: *strsubst \(".*"\) == \(".*"\)/x(\1, \2)/p; d' <strsubst.lua >gentest.lua
  ]]
)

dofile('gentest.lua')




-- api tests
