EventDispatcher = {}
EventDispatcher.__index = EventDispatcher

function EventDispatcher:new()
    local self = setmetatable({}, EventDispatcher)
    self.listeners = {}
    return self
end

function EventDispatcher:addEventListener(eventType, listener)
    if not self.listeners[eventType] then
        self.listeners[eventType] = {}
    end
    table.insert(self.listeners[eventType], listener)
end

function EventDispatcher:removeEventListener(eventType, listener)
    if not self.listeners[eventType] then return end
    for i, l in ipairs(self.listeners[eventType]) do
        if l == listener then
            table.remove(self.listeners[eventType], i)
            break
        end
    end
end

function EventDispatcher:dispatchEvent(event)
    local eventType = event.type
    if not self.listeners[eventType] then return end
    for _, listener in ipairs(self.listeners[eventType]) do
        if(listener.object) then
            listener.name(listener.object,event)
        else
            listener.name(event)
        end
    end
end

return EventDispatcher
