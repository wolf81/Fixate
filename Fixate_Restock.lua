-- Global

Restock = {}
Restock.__index = Restock

-- Private

local frame = CreateFrame('Frame')

local reagents = {
	['DRUID'] = {
		['Wrath'] = {
			{1, 'Bean Soup', 1}
		},
		['Rebirth'] = {
			{1, 'Maple Seed', 5},
			{2, 'Stranglethorn Seed', 5},
			{3, 'Ashwood Seed', 5},
			{4, 'Hornbeam Seed', 5},
			{5, 'Ironwood Seed', 5},
			{6, 'Flintweed Seed', 5},			
		},
		['Gift of the Wild'] = {
			{1, 'Wild Berries', 10},
			{2, 'Wild Thornroot', 20}, -- level 60
			{3, 'Wild Quillvine', 20},
		}
	},
}
	-- ['WARRIOR'] = {
	-- 	-- don't need reagents
	-- },
	-- ['PALADIN']	= {
	-- 	{
	-- 		['Symbol of Kings'] 	= {100, 52}, -- Greater Blessing of Kings, Light, Might, Salvation, Wisdom
	-- 	},
	-- 	{
	-- 		['Symbol of Divinity'] 	= {5, 30}, -- Divine Intervention
	-- 	},
	-- },
	-- ['HUNTER'] = {
	-- 	-- arrows, pet food
	-- },
	-- ['ROGUE'] = {
	-- 	{
	-- 		['Essence of Agony'] 	= {20, 48}, -- Crippling Poison II & Mind-numbing Poison III & Wound Poison III, IV			
	-- 	},
	-- 	{
	-- 		['Essence of Pain'] 	= {20, 20}, -- Crippling & Mind-numbing Poison I, II
	-- 	},
	-- 	{
	-- 		['Flash Powder'] 		= {20, 22}, -- Vanish			
	-- 	},
	-- 	{
	-- 		['Dust of Decay'] 		= {20, 20}, -- Instant & Mind-numbing Poison I, II
	-- 	},
	-- 	{
	-- 		['Deathweed'] 			= {20, 30}, -- Deadly Poison
	-- 	},
	-- 	{
	-- 		['Thieves\' Tools'] 	= {1, 15}, -- Lockpicking, also received from quest
	-- 	},		
	-- 	{
	-- 		['Dust of Deterioration'] = {20, 36}, -- Instant Poison
	-- 	},
	-- },
	-- ['PRIEST'] = {
	-- 	{
	-- 		['Holy Candle'] 		= {10, 48}, -- Prayer of Fortitude I
	-- 		['Sacred Candle'] 		= {20, 60}, -- Prayer of Fortitude II, Prayer of Spirit & Shadow Protection I
	-- 	},
	-- 	{
	-- 		['Light Feather'] 		= {20, 34}, -- Levitate
	-- 	},
	-- },
	-- ['SHAMAN'] = {
	-- 	{
	-- 		['Ankh'] 				= {5, 30}, -- Reincarnation
	-- 	},
	-- 	{
	-- 		['Shiny Fish Scales'] 	= {20, 22}, -- Water Breathing
	-- 	},
	-- 	{
	-- 		['Fish Oil'] 			= {20, 28}, -- Water Walking
	-- 	},
	-- },
	-- ['MAGE'] = {
	-- 	{
	-- 		['Arcane Powder'] 		= {20, 56}, -- Ritual of Refreshment
	-- 	},
	-- 	{
	-- 		['Rune of Portals'] 	= {10, 40}, -- Portal
	-- 	},
	-- 	{
	-- 		['Rune of Teleportation'] = {10, 20}, -- Teleport
	-- 	},
	-- 	{
	-- 		['Light Feather'] 		= {12, 20}, -- Slow fall
	-- 	},
	-- },
	-- ['WARLOCK'] = {
	-- 	{
	-- 		['Demonic Figurine'] 	= {1, 60}, -- Ritual of Doom
	-- 	},
	-- 	{
	-- 		['Infernal Stone'] 		= {5, 50}, -- Inferno
	-- 	},
	-- },
-- }

-- determine the reagent item count based on player level and class, e.g.:
-- druid level 30: buy Stranglethorn Seed
local function GetRequiredItemCountForPlayer(itemName)
	local _, playerClass = UnitClass("player")

	local classReagents = reagents[playerClass]
	local itemCount = 0
	local spellInfo = nil

	for spellName, rankInfos in pairs(classReagents) do		
		for rankIndex = 1, #rankInfos do
			local rankInfo = rankInfos[rankIndex]
			local spellRank = 'Rank ' .. rankInfo[1]

			if GetSpellBookItemName(spellName, spellRank) then
				if itemName == rankInfo[2] then 
					itemCount = rankInfo[3]
					spellId = GetSpellInfo(spellName, spellRank)
					spellInfo = {spellId, spellName, spellRank}
				else 
					itemCount = 0
				end
			end
		end
	end

	return itemCount, spellInfo
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

		local requiredItemCount, spellInfo = GetRequiredItemCountForPlayer(itemName)
		local posessItemCount = GetItemCount(itemName) or 0
		local buyItemCount = requiredItemCount - posessItemCount

		local money = GetMoney()
		local totalCost = math.ceil(buyItemCount / quantity) * price

		-- TODO: limit buy amount to numAvailable
		if money < totalCost then
			local itemLink = GetMerchantItemLink(itemIndex)
			Fixate:Print('You don\'t have enough money to buy ' .. itemLink)
			Fixate:Print('You have ' .. GetCoinText(money))
			Fixate:Print('You need ' .. GetCoinText(totalCost))
			return
		end

		if buyItemCount > 0 then 								
			local spellLink = "|Hspell:" .. spellInfo[1] .."|h|r|cff71d5ff[" .. spellInfo[2] .. " (" .. spellInfo[3] .. ")]|r|h"
			Fixate:Print('Buy ' .. itemName .. ' x' .. buyItemCount .. ' for ' .. spellLink)
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
