-- Global

AutoRepair = {}
AutoRepair.__index = AutoRepair

-- Private

local frame = CreateFrame('Frame')

local function OnEvent(event, ...)
	repairAllCost, canRepair = GetRepairAllCost()

	if canRepair == nil then return end

	money = GetMoney()

	if repairAllCost > 0 then
		if repairAllCost <= money then
			RepairAllItems()

			Fixate:Print('Repaired all equipment for ' .. GetCoinText(repairAllCost))
		else
			Fixate:Print('Not enough money to repair equipment')
		end
	end
end

-- Public

function AutoRepair:New()
	local self = {}    
    setmetatable(self, AutoRepair)
	return self
end

function AutoRepair:Initialize()
	frame:RegisterEvent('MERCHANT_SHOW')
	frame:SetScript('OnEvent', function(self, event, ...) OnEvent(event, ...) end)

	Fixate:DebugPrint('AutoRepair initialized')
end
