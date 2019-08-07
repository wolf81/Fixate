-- Global

Restock = {}
Restock.__index = Restock

-- Private

local frame = CreateFrame('Frame')

local reagents = {
	['DRUID'] = {
		{
			-- subtables use the notation {targetAmount, minimumPlayerLevel}
			['Maple Seed'] 			= {5, 20}, -- Rebirth I
			['Stranglethorn Seed'] 	= {5, 30}, -- Rebirth II
			['Ashwood Seed'] 		= {5, 40}, -- Rebirth III
			['Hornbeam Seed'] 		= {5, 50}, -- Rebirth IV
			['Ironwood Seed'] 		= {20, 60}, -- Rebirth V
			['Flintweed Seed'] 		= {20, 70}, -- Rebirth VI
		},
		{
			['Wild Berries'] 		= {10, 50}, -- Gift of the Wild I
			['Wild Thornroot'] 		= {20, 60}, -- Gift of the Wild II
			['Wild Quillvine'] 		= {20, 70}, -- Gift of the Wild III			
		},
	},
	['WARRIOR'] = {
		-- don't need reagents
	},
	['PALADIN']	= {
		{
			['Symbol of Kings'] 	= {100, 52}, -- Greater Blessing of Kings, Light, Might, Salvation, Wisdom
		},
		{
			['Symbol of Divinity'] 	= {5, 30}, -- Divine Intervention
		},
	},
	['HUNTER'] = {
		-- arrows
	},
	['ROGUE'] = {
		{
			['Essence of Agony'] 	= {20, 48}, -- Crippling Poison II & Mind-numbing Poison III & Wound Poison III, IV			
		},
		{
			['Essence of Pain'] 	= {20, 20}, -- Crippling & Mind-numbing Poison I, II
		},
		{
			['Flash Powder'] 		= {20, 22}, -- Vanish			
		},
		{
			['Dust of Decay'] 		= {20, 20}, -- Instant & Mind-numbing Poison I, II
		},
		{
			['Deathweed'] 			= {20, 30}, -- Deadly Poison
		},
		{
			['Thieves\' Tools'] 	= {1, 15}, -- Lockpicking, also received from quest
		},		
		{
			['Dust of Deterioration'] = {20, 36}, -- Instant Poison
		},
	},
	['PRIEST'] = {
		['Holy Candle'] = 0, -- Prayer of Fortitude I
		['Sacred Candle'] = 0, -- Prayer of Fortitude II, Prayer of Spirit & Shadow Protection I
		['Light Feather'] = 0, -- Levitate
	},
	['SHAMAN'] = {
		['Ankh'] = 0, -- Reincarnation
		['Shiny Fish Scales'] = 0, -- Water Breathing
		['Fish Oil'] = 0, -- Water Walking
	},
	['MAGE'] = {
		['Arcane Powder'] = 0, -- Ritual of Refreshment
		['Rune of Portals'] = 0, -- Portal
		['Rune of Teleportation'] = 0, -- Teleport
		['Light Feather'] = 0, -- Slow fall
	},
	['WARLOCK'] = {
		['Demonic Figurine'] = 0, -- Ritual of Doom
		['Infernal Stone'] = 0, -- Inferno
	},
}

-- determine the reagent item count based on player level and class, e.g.:
-- druid level 30: buy Stranglethorn Seed
local function GetRequiredItemCountForPlayer(itemName)
	local _, playerClass = UnitClass("player")
	local playerLevel = UnitLevel("player")

	local classReagents = reagents[playerClass]
	local itemCount = 0

	for k, v in pairs(classReagents) do		
		if type(v) == 'table' then
			-- check if the item exists in the subtable and if so, process table
			if v[itemName] ~= nil then
				local itemInfo = nil

				-- find the highest level item available for the player from the subtable
				for k1, v1 in pairs(v) do
					-- select the first usable reagent based on player level
					if itemInfo == nil and v1[2] <= playerLevel then						
						itemInfo = v1		

						if itemName == k1 then
							itemCount = v1[1]
						end
					-- select the highest usable reagent based on player level
					elseif itemInfo ~= nil and v1[2] <= playerLevel and v1[2] > itemInfo[2] then
						itemInfo = v1

						if itemName == k1 then
							itemCount = v1[1]
						end					
					end
				end
			end
		else			
			if k == itemName then itemCount = v break end
		end

		-- if an item with the same name was found, stop processing the reagents table
		if itemCount > 0 then break end
	end

	return itemCount
end

local function OnEvent(event, ...)
	-- on appearance of the merchant dialog, register to receive subsequent merchant stock updates
	if event == 'MERCHANT_SHOW' then
		frame:RegisterEvent('MERCHANT_UPDATE')
	end	

	-- process all merchant stock, to make sure the merchant is ready to trade
	local numItems = GetMerchantNumItems()
	for itemIndex = 1, numItems do
		local itemName = GetMerchantItemInfo(itemIndex)

		if itemName == nil then return end -- wait for update	
	end

	-- buying items will trigger a MERCHANT_UPDATE event, so unsubscribe first
	frame:UnregisterEvent('MERCHANT_UPDATE')

	-- the merchant stock is ready, buy items
	local numItems = GetMerchantNumItems()
	for itemIndex = 1, numItems do
		local itemName, _, price, quantity, numAvailable, isPurchasable = GetMerchantItemInfo(itemIndex)		

		local requiredItemCount = GetRequiredItemCountForPlayer(itemName)
		local posessItemCount = GetItemCount(itemName) or 0
		local buyItemCount = requiredItemCount - posessItemCount

		local money = GetMoney()
		local totalCost = math.ceil(buyItemCount / quantity) * price

		if money < totalCost then
			local itemLink = GetMerchantItemLink(itemIndex)
			Fixate:Print('You don\'t have enough money to buy ' .. itemLink)
			Fixate:Print('You have ' .. GetCoinText(money))
			Fixate:Print('You need ' .. GetCoinText(totalCost))
			return
		end

		if buyItemCount > 0 then 			
			Fixate:Print('Buy ' .. itemName .. ' x' .. buyItemCount)
			BuyMerchantItem(itemIndex, buyItemCount)
		end
	end
end

-- Public

function Restock:New()
	local self = {}    
    setmetatable(self, Restock)
	return self
end

function Restock:Initialize()
	frame:RegisterEvent('MERCHANT_SHOW')
	frame:SetScript('OnEvent', function(self, event, ...) OnEvent(event, ...) end)

	Fixate:DebugPrint('Restock initialized')
end
