local LClass = {}

local aClassMeta =
{
    __tostring = function(aClass)
        return "CLASS: " .. aClass.name
    end,
}
local function _createClass(name, super)
    local aClass = {}
    setmetatable(aClass, aClassMeta)
    aClass.name = name

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