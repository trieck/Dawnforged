local _Meta = {}

-- Create a new class
function _Meta.Class(name, base)
    local class = {}
    class.__index = class
    class.__name = name

    setmetatable(class, {
        __index = base,
        __call = function(cls, ...)
            local instance = setmetatable({}, cls)
            if instance.init then
                instance:init(...)
            end
            return instance
        end,
    })

    -- syntactic sugar for inheritance
    function class:extends(subclassName)
        return _Meta.Class(subclassName, class)
    end

    -- Dump class contents
    function class:Dump()
        Ext.Dump(self)
    end

    --Run a function on next tick
    function class:OnNextTick(fun)
        if type(fun) ~= "function" then
            _PE(string.format("[%s] OnNextTick expected function, got %s", self.__name, type(fun)))
            return
        end

        Ext.OnNextTick(function()
            local ok, err = xpcall(function()
                -- allow call with self as first arg
                fun(self)
            end, debug.traceback)
            if not ok then
                _PE(string.format("[%s] OnNextTick error: %s", self.__name, err))
            end
        end)
    end
   
    -- Run a function after a number of ticks
    function class:AfterTicks(ticks, fun)
        if type(fun) ~= "function" or type(ticks) ~= "number" or ticks <= 0 then
            _PW(string.format("[%s] AfterTicks expected (number, function), got (%s, %s)", self.__name, type(ticks), type(fun)))
            return
        end

        local ticksPassed = 0
        local eventID
        eventID = Ext.Events.Tick:Subscribe(function()
            ticksPassed = ticksPassed + 1
            if ticksPassed >= ticks then
                local ok, err = xpcall(function() fun(self) end, debug.traceback)
                if not ok then
                    _PE(string.format("[%s] AfterTicks() error: %s", self.__name, err))
                end
                Ext.Events.Tick:Unsubscribe(eventID)
            end
        end)
    end
    
    -- Run a function after time in milliseconds on a tick granularity
    function class:AfterTime(ms, fun)
        if type(fun) ~= "function" or type(ms) ~= "number" or ms <= 0 then
            _PW(string.format("[%s] AfterTime expected (number, function), got (%s, %s)", self.__name, type(ms), type(fun)))
            return
        end

        local startTime = Ext.Utils.MonotonicTime()
        local eventID
        eventID = Ext.Events.Tick:Subscribe(function()
            if Ext.Utils.MonotonicTime() - startTime >= ms then
                local ok, err = xpcall(function() fun(self) end, debug.traceback)
                if not ok then
                    _PE(string.format("[%s] AfterTime() error: %s", self.__name, err))
                end
                Ext.Events.Tick:Unsubscribe(eventID)
            end
        end)
    end

    -- Run a function after time in milliseconds
    function class:AfterTimeReal(ms, fun)
        if type(fun) ~= "function" or type(ms) ~= "number" or ms <= 0 then
            _PW(string.format("[%s] AfterTimeReal expected (number, function), got (%s, %s)", self.__name, type(ms), type(fun)))
            return
        end

        local timer
        timer = Ext.Timer.WaitFor(ms, function()
            local ok, err = xpcall(function() fun(self) end, debug.traceback)
            if not ok then
                _PE(string.format("[%s] AfterTimeReal() error:\n%s", self.__name, err))
            end            
        end)
    end

    -- Add an item to a container (inventory, chest, etc.)
    function class:AddItemToContainer(itemTemplate, containerGuid)
        local item = Osi.CreateAtObject(itemTemplate, containerGuid, 1, 1, "", 1)
        if item then
            Osi.ToInventory(item, containerGuid, 1)
        else
            _PE(string.format("[%s] Failed to create %s at %s.", self.__name, itemTemplate, containerGuid))
        end
    end

    return class
end

Meta = _Meta
