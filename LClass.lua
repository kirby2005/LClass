local LClass = {}
local ClassSet = {}
local checkType = true
local classMark = {}
local function isClass(class)
    return type(class) == "table" and class.mark == classMark
end

local function deepCopy(value)
    local ret
    if type(value) == "table" then
        ret = {}
        for k, v in pairs(value) do
            ret[k] = deepCopy(v)
        end

        setmetatable(ret, getmetatable(tbl))
    else
        ret = value
    end
    return ret
end

local tempType
local aClassMeta =
{
    __call = function(aClass)
        local aInstance = {}
        aInstance.instanceField = {}
        local instanceMeta =
        {
            __index = function(instance, key)
                local memberType = aClass.memberInfo[key]
                if not memberType then
                    local super = aClass.super
                    while(super) do
                        memberType = super.memberInfo[key]
                        if memberType then
                            break
                        else
                            super = super.super
                        end
                    end
                end

                if not memberType then
                    error(string.format("Member info not found in class %s, member name: %s", aClass.name, key), 1)
                elseif memberType == "field" then
                    local fieldMeta = aClass.field[key]
                    if not fieldMeta then
                        error(string.format("Instance field not found when access, field: %s", key), 1)
                    end
                    -- table is reference type, change element of a table field will change the template table field in class, so, deep copy a new table to resolve this problem.
                    if fieldMeta.type == "table" and not instance.instanceField[key] then
                        local tableField = deepCopy(fieldMeta.defaultValue)
                        instance.instanceField[key] = tableField
                    end

                    return instance.instanceField[key] or fieldMeta.defaultValue
                elseif memberType == "method" then
                    return aClass.method[key]
                end
            end,

            __newindex = function(instance, key, value)
                local fieldMeta = aClass.field[key]
                if not fieldMeta then
                    error(string.format("Instance field not found when assignment, field: %s", key), 1)
                end

                if checkType and fieldMeta.type ~= type(value) then
                    error(string.format("Instance field type mismatch, need: %s, assignment: %s,", fieldMeta.type, type(value)), 1)
                end

                instance.instanceField[key] = value
            end,
        }
        instanceMeta.__tostring = function(self)
            local temp = instanceMeta.__tostring
            instanceMeta.__tostring = nil
            local addr = tostring(self)
            instanceMeta.__tostring = temp
            return "Instance of class " .. aClass.name .. " " .. addr
        end

        aInstance.is = function(self, class)
            return isClass(class) and aClass.name == class.name
        end

        setmetatable(aInstance, instanceMeta)

        return aInstance
    end,

    -- __newindex = function(aClass, key, value)
    --     -- TO DO: key check(field, static, etc.)
    --     rawset(aClass, key, value)
    -- end,

    -- __index = function(aClass, key)
    --     if rawget(aClass, key) then
    --         return rawget(aClass, key)
    --     else
    --         local super = rawget(aClass, "super")
    --         while super do
    --             if rawget(super, key) then
    --                 return rawget(super, key)
    --             end
    --             super = super.super
    --         end
    --     end
    -- end,

    __index = function(aClass, key)
        print("xxxxxxxxxxxxxx", key)
        if key == "field" then
            tempType = "field"
        elseif key == "method" then
            tempType = "method"
        elseif key == "virtual" then
            tempType = "virtual"
        elseif key == "override" then
            tempType = "override"
        else
            return rawget(aClass, key)
        end
        return aClass.membersInfo
    end,
}

aClassMeta.__tostring = function(aClass)
    local temp = aClassMeta.__tostring
    aClassMeta.__tostring = nil
    local addr = tostring(aClass)
    aClassMeta.__tostring = temp

    return "CLASS: " .. aClass.name .. " " .. addr
end

local membersMeta =
{
    __call = function(self, ...)
        return self
    end,

    __newindex = function(self, key, value)
        if self.members[key] then
            error(string.format("Class member already exists. name: %s", key), 1)
        end

        if tempType == "field" then
            self.members[key] = value
        elseif tempType == "method" then
            if type(value) ~= "function" then
                error(string.format("Class member not match, need method, got: %s", type(value)), 1)
            end
            local memberInfo = {}
            memberInfo.__call = function(self, ...)
                return value(...)
            end

            self.members[key] = memberInfo
        end
    end,
}

local function _createClass(name, super)
    if not ClassSet[name] then
        ClassSet[name] = true
    else
        error(string.format("Class already exists, class name: %s", name), 1)
    end

    local aClass = {}

    aClass.name = name
    aClass.memberInfo = {}
    aClass.membersInfo = {members = {}}
    setmetatable(aClass.membersInfo, membersMeta)

    -- aClass.field = {}
    -- aClass.method = {}
    aClass.mark = classMark

    local tempType
    local fieldMeta =
    {
        __call = function(self, type)
            tempType = type  -- for type check
            return self
        end,

        __index = function(self, key)
            local value = rawget(self, key)
            if not value and super then
                value = super.field[key]
            end

            return value  -- may be nil.
        end,

        __newindex = function(self, key, value)
            if aClass.memberInfo[key] then
                error(string.format("Member already exists, name: %s", key), 1)
            end
            if rawget(self, key) then
                error(string.format("Class field already exist, class: %s, field name: %s", name, key), 1)
            end

            local valueType = type(value)
            if checkType and valueType ~= tempType then
                if valueType == "table" and value.is and value:is(tempType) then
                else
                    local needTypeDesc = isClass(tempType) and "Instance of class " .. tempType.name or type(tempType)
                    local assignmentTypeDesc = tostring(value)
                    error(string.format("Class field type mismatch, class: %s, field: %s, need: %s, assignment: %s", name, key, needTypeDesc, assignmentTypeDesc), 1)
                end
            end

            local metadata = {}
            metadata.type = valueType
            metadata.defaultValue = value
            rawset(self, key, metadata)
            aClass.memberInfo[key] = "field"
        end,
    }
    -- setmetatable(aClass.field, fieldMeta)

    local tempTypeArray = {}
    local methodMeta =
    {
        __call = function(self, ...)
            local typeCount = select("#", ...)
            for i = 1, typeCount do
                tempTypeArray[i] = select(i, ...)
            end

            return aClass.method
        end,

        __index = function(self, key)
            local method = rawget(aClass.method, key)
            if not method then
                local super = aClass.super
                while super do
                    method = super.method[key]
                    if method then
                        break
                    end
                    super = super.super
                end
            end
            return method
        end,

        __newindex = function(self, key, value)
            if aClass.memberInfo[key] then
                error(string.format("Member already exists, name: %s", key), 1)
            end
            if not type(value) == "function" then
                error(string.format("Method value is not a function, name: %s", name), 1)
            end

            rawset(self, key, value)

            aClass.memberInfo[key] = "method"
        end,
    }
    -- setmetatable(aClass.method, methodMeta)

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