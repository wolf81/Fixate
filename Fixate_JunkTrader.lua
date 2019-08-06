-- Global

JunkTrader = {}
JunkTrader.__index = JunkTrader

-- Private

local frame = CreateFrame('Frame')

local function OnEvent(event, ...)
	local bag, slot
	for bag = 0, 4 do
		if GetContainerNumSlots(bag) > 0 then
			for slot = 1, GetContainerNumSlots(bag) do
				local _, _, _, quality, _, _, itemLink = GetContainerItemInfo(bag, slot)

				-- sell all items of 'gray' quality in a non-empty bag slot
				if itemLink ~= nil and quality == 0 then					
					UseContainerItem(bag, slot)								
					Fixate:Print('Sold ' .. itemLink)
				end
			end
		end
	end	
end

-- Public

function JunkTrader:New()
	local self = {}    
    setmetatable(self, JunkTrader)
	return self
end

function JunkTrader:Initialize()
	frame:RegisterEvent('MERCHANT_SHOW')
	frame:SetScript('OnEvent', function(self, event, ...) OnEvent(event, ...) end)

	Fixate:DebugPrint('JunkTrader initialized')
end
