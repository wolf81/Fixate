-- Global

EventCapture = {}
EventCapture.__index = EventCapture

-- Private

local frame = CreateFrame('Frame')

local function OnEvent(event, ...)
	Fixate:Print("Capture event")
	Screenshot()
end

-- Public

function EventCapture:New()
	local self = {}    
    setmetatable(self, EventCapture)
	return self
end

function EventCapture:Initialize()
	frame:RegisterEvent('PLAYER_LEVEL_UP')
	frame:RegisterEvent('BOSS_KILL')
	frame:SetScript('OnEvent', function(self, event, ...) OnEvent(event, ...) end)

	Fixate:DebugPrint('EventCapture initialized')
end
