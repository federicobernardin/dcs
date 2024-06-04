EventHandler = {}
EventHandler.__index = EventHandler

function EventHandler:new()
    local self = setmetatable({}, EventHandler)
    self.dispatcher = EventDispatcher:new()
    return self
end

function EventHandler:addEventListener(eventType, listener)
    self.dispatcher:addEventListener(eventType, listener)
end

function EventHandler:removeEventListener(eventType, listener)
    self.dispatcher:removeEventListener(eventType, listener)
end

function EventHandler:dispatchEvent(eventType, data)
    local event = {type = eventType, data = data}
    self.dispatcher:dispatchEvent(event)
end

return EventHandler
