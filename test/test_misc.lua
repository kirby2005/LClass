local LClass = dofile "../LClass.lua"

local C1 = LClass("C1")
print("Class C1", C1)
C1.a = 100
C1.static.sa = 200

local O1 = C1()
print("Object O1", O1)
print("O1.a:", O1.a)


local C2 = LClass("C2", C1)
print("Class C2", C2)
local O2 = C2()
print("Object O2", O2)
print("O2.a:", O2.a)


local C3 = LClass("C3", C2)
print("Class C3", C3)
local O3 = C3()
print("Object O3", O3)
print("O3.a:", O3.a)
