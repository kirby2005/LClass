local Class = dofile "../LClass.lua"
local C1 = Class("C1")
local C2 = Class("C2", C1)
local C3 = Class("C3", C2)

C1.method().f1 = function(self)
    print("function f1 in class C1")
end

local O1 = C1()
local O2 = C2()
local O3 = C3()
O1:f1()
O2:f1()
O3:f1()