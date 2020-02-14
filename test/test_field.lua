local LClass = dofile "../LClass.lua"

local C1 = LClass("C1")
C1.field("number").m_number1 = 1
C1.field("number").m_number2 = 2
C1.field("string").m_string1 = "str1"
C1.field("string").m_string2 = "str2"
-- C1.field("table").m_table1 = nil
-- C1.field("table").m_table2 = {table2 = "table2"}
-- C1.field("userdata").m_userdata1 = nil
-- C1.field("userdata").m_userdata2 = nil
-- C1.field("function").m_function1 = nil
-- C1.field("function").m_function2 = nil

local C2 = LClass("C2", C1)
local C3 = LClass("C3", C2)


local O1 = C1()
local O2 = C2()
local O3 = C3()

assert(O1.m_number1 == 1)
print(O1.m_number1)
print(O1.m_number2)
-- print(O2.m_number1)
