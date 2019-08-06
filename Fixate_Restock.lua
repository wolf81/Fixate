-- Global

Restock = {}
Restock.__index = Restock

-- Private

local frame = CreateFrame('Frame')

local reagents = {
	['DRUID'] = {
		{
			-- subtables use the notation {targetAmount, minimumPlayerLevel}
			['Bean Soup'] = {5, 0},
			['Versicolor Treat'] = {1, 5},
		},
		['Tough Hunk of Bread'] = 14,
		['Flintweed Seed'] = 0, -- Rebirth VI
		['Wild Berries'] = 0, -- Gift of the Wild I
		['Wild Thornroot'] = 0, -- Gift of the Wild II
		['Wild Quillvine'] = 0, -- Gift of the Wild III
		['Maple Seed'] = 0, -- Rebirth I
		['Stranglethorn Seed'] = 0, -- Rebirth II
		['Ashwood Seed'] = 0, -- Rebirth III
		['Hornbeam Seed'] = 0, -- Rebirth IV
		['Ironwood Seed'] = 0, -- Rebirth V
	},
	['WARRIOR'] = {
		-- don't need reagents
	},
	['PALADIN']	= {
		['Symbol of Kings'] = 0, -- Greater Blessing of Kings, Light, Might, Salvation, Wisdom
		['Symbol of Divinity'] = 0, -- Divine Intervention
	},
	['HUNTER'] = {
		-- arrows
	},
	['ROGUE'] = {
		['Essence of Agony'] = 0, -- Crippling Poison II & Mind-numbing Poison III & Wound Poison III, IV
		['Essence of Pain'] = 0, -- Crippling & Mind-numbing Poison I, II
		['Flash Powder'] = 0, -- Vanish
		['Dust of Decay'] = 0, -- Instant & Mind-numbing Poison I, II
		['Dust of Detorioration'] = 0, -- Instant Poison
		['Deathweed'] = 0, -- Deadly Poison
		['Thieves\' Tools'] = 0, -- Lockpicking, also received from quest
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

local function GetRequiredItemCount(itemName)
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

		local requiredItemCount = GetRequiredItemCount(itemName)
		print('required: ' .. requiredItemCount)

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

		-- TODO: 
		-- 2. buy reagents based on player level		
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
