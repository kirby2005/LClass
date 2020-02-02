local LClass = {}

local aClassMeta =
{
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
            local super = rawget(aClass, "super")
            while super do
                if rawget(super, key) then
                    return rawget(super, key)
                end
                super = super.super
            end
        end
    end,
}

aClassMeta.__tostring = function(aClass)
    local temp = aClassMeta.__tostring
    aClassMeta.__tostring = nil
    local addr = tostring(aClass)
    aClassMeta.__tostring = temp

    return "CLASS: " .. aClass.name .. " " .. addr
end


local function _createClass(name, super)
    local aClass = {}
    aClass.__index = aClass
    aClass.__tostring = function(self)
        local temp = aClass.__tostring
        aClass.__tostring = nil
        local addr = tostring(self)
        aClass.__tostring = temp
        return "Instance of class " .. name .. " " .. addr
    end

    aClass.name = name
    aClass.static = {}  -- static can be inherited
    aClass.static.__index = aClass.static
    if super then
        aClass.super = super
        setmetatable(aClass.static, super.static)
    end

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