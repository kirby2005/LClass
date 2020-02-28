local LClass = dofile "../LClass.lua"
local FC1 = LClass("FC1")
local FC2 = LClass("FC2")
FC1.field("number").m_a1 = 1000

local C1 = LClass("C1")
C1.field("number").m_number1 = 1
C1.field("number").m_number2 = 2
C1.field("string").m_string1 = "str1"
C1.field("string").m_string2 = "str2"
-- C1.field("table").m_table1 = nil
C1.field("table").m_table2 = {key2 = "key2"}
-- C1.field("userdata").m_userdata1 = nil
-- C1.field("userdata").m_userdata2 = nil
C1.field("function").m_function1 = function(a) print(a) end
C1.field(FC1).m_fc1 = FC1()
-- C1.field("function").m_function2 = nil

local C2 = LClass("C2", C1)
local C3 = LClass("C3", C2)


local O1 = C1()
local O2 = C2()
local O3 = C3()

assert(O1.m_number1 == 1)
print(O1.m_number1)
O1.m_number1 = 2
print("O1.m_number1:", O1.m_number1)
-- O1.m_number1 = "a" -- type error
print(O1.m_number2)
print("O2.m_number1:", O2.m_number1)
print("O3.m_number1:", O3.m_number1)

print("O1.m_string1:", O1.m_string1)
print("O1.m_table2.key2:", O1.m_table2.key2)

-- test table
print([[O1.m_table2.key2 = "aa"]])
O1.m_table2.key2 = "aa"
print("O1.m_table2.key2:", O1.m_table2.key2)
print("O2.m_table2.key2:", O2.m_table2.key2)
print([[O2.m_table2.key2 = "bb"]])
O2.m_table2.key2 = "bb"
print("O2.m_table2.key2:", O2.m_table2.key2)
print("O3.m_table2.key2:", O3.m_table2.key2)

O2.m_table2 = {xx = "xx"}
print([[O2.m_table2 = {xx = "xx"}]])
print("O2.m_table2.key2:", O2.m_table2.xx)
print("O3.m_table2.key2:", O3.m_table2.key2)


-- test function
O1.m_function1("function test")
