-- Global

Fixate = {}
Fixate.__index = Fixate;    

-- Private

local frame = CreateFrame('Frame')

local function ShowDebugState()
	debugState = Fixate_Defaults['Debug'] and 'enabled' or 'disabled'
	Fixate:Print('Debug mode ' .. debugState)
end

local function CommandHandler(msg, editBox)
	-- pattern matching that skips leading whitespace and whitespace between cmd and args
	-- any whitespace at end of args is retained
	local _, _, cmd, args = string.find(msg, '%s?(%w+)%s?(.*)')

	if cmd == 'debug' then 
		Fixate_Defaults['Debug'] = not Fixate_Defaults['Debug']
		ShowDebugState()
		ReloadUI()
	end
end

local function OnEvent(event, ...)
	frame:UnregisterEvent('ADDON_LOADED')

	if Fixate_Defaults['Debug'] == true then
		ShowDebugState()
	end

	local eventCapture = EventCapture:New()
	eventCapture:Initialize()

	local junkTrader = JunkTrader:New()
	junkTrader:Initialize()

	local autoRepair = AutoRepair:New()
	autoRepair.Initialize()

	local restock = Restock:New()
	restock.Initialize()
end

-- Public

function Fixate:New()
	local self = {}    
    setmetatable(self, Fixate); 
	return self
end

function Fixate:Initialize()
	frame:RegisterEvent('ADDON_LOADED')
	frame:SetScript('OnEvent', function(self, event, ...) OnEvent(event, ...) end)

	SlashCmdList['FIXATE'] = function (msg, editBox) CommandHandler(msg, editBox) end
	SLASH_FIXATE1 = '/fixate'
	SLASH_FIXATE2 = '/fx'
		
	Fixate:Print("Initialized")
end

function Fixate:DebugPrint(...)
	if Fixate_Defaults['Debug'] == true then
		Fixate:Print(...)
	end
end

function Fixate:Print(...)
	print("|cff1bcfcc[Fixate]|r " .. ...)
end

fixate = Fixate:New()
fixate.Initialize()
