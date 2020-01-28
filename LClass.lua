local LClass = {}

local aClassMeta =
{
    __tostring = function(aClass)
        return "CLASS: " .. aClass.name
    end,

    __call = function(aClass)
        local aInstance = {}
        setmetatable(aInstance, aClass)

        return aInstance
    end,

    __newindex = function(aClass, key, value)
        rawset(aClass, key, value)
    end,

    __index = function(aClass, key)
        if rawget(aClass, key) then
            return rawget(aClass, key)
        else
            return aClass.super and rawget(aClass.super, key) or nil
        end
    end,
}
local function _createClass(name, super)
    local aClass = {}
    aClass.__index = aClass
    aClass.__tostring = function(self) return "Instance of class " .. name end
    aClass.name = name
    aClass.super = super

    setmetatable(aClass, aClassMeta)

    return aClass
end

local meta =
{
    __call = function(aClass, name, super)
        -- assert
        return _createClass(name, super)
    end,
}
setmetatable(LClass, meta)

return LClass