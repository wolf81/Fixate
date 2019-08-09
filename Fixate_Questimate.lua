-- Global

Questimate = {}
Questimate.__index = Questimate

-- Private

local frame = CreateFrame('Frame', nil, UIParent)
frame:SetWidth(128)
frame:SetHeight(64)
frame:SetFrameStrata("BACKGROUND")


function CreateBD(frame, alpha)
    frame:SetBackdrop({
        bgFile = 'Interface//Buttons//WHITE8X8', 
        edgeFile = 'Interface//Buttons//WHITE8X8', 
        edgeSize = 1, 
    })
    frame:SetBackdropColor(0.15, 0.15, 0.15, a)
    frame:SetBackdropBorderColor(1, 1, 1)
end

function CreateBDFrame(frame, alpha)
	local f
	if frame:GetObjectType() == "Texture" then
	    f = frame:GetParent()
	else
	    f = frame
	end
	local lvl = f:GetFrameLevel()
	local bg = CreateFrame("Frame", nil, f)
	bg:SetParent(f)
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	CreateBD(bg, alpha)

	return bg
end

local function AddItemBorder(f)
	-- f.icon:SetTexCoord(.08, .92, .08, .92)
	-- local t = f:CreateTexture(nil,BORDER_LAYER, 100)
	-- t:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp")
	-- t:SetAllPoints(f)
	-- f.texture = t

	-- print('t: ' .. tostring(t))

	-- f.SetBorderSize()
	-- f:SetPoint("CENTER",0,0)
	-- f:Show()
	CreateBDFrame(f, 0)

	-- local icon = f.icon or f.Icon or _G[f:GetName().."IconTexture"]
	-- local name = f.name or f.Name or _G[f:GetName().."Name"]
	-- if icon then
	-- 	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	-- 	print('GOT ICON')
	-- end
	-- if name then
	-- 	name:SetFontObject("QuestFontNormalSmall")
	-- 	_G[f:GetName().."NameFrame"]:SetTexture("")
	-- end
end

local function OnEvent(event, ...)
	Fixate:DebugPrint('Quest completed')

	local f = _G["QuestInfoRewardsFrameQuestInfoItem1"]
	print(f)
	if f == nil then return end

	print(f)
	-- print(f:GetID())
	-- print(f.type)
	-- for x in pairs(f) do
	-- 	print(x)
	-- end

	AddItemBorder(f)
	-- Fixate:DebugPrint(icon)
end

-- Public

function Questimate:New()
	local self = {}    
    setmetatable(self, Questimate)
	return self
end

function Questimate:Initialize()
	frame:RegisterEvent('QUEST_COMPLETE')
	frame:SetScript('OnEvent', function(self, event, ...) OnEvent(event, ...) end)

	Fixate:DebugPrint('Questimate initialized')
end
