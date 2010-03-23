local db = TukuiDB["tooltip"]
if not db.enable then return end

-- Texture tooltips
local tooltips = {
    "GameTooltip",
    "ItemRefTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "ShoppingTooltip3",
    "DropDownList1MenuBackdrop",
    "DropDownList2MenuBackdrop",
	"WorldMapTooltip"
}

for i=1, #tooltips do
		_G[tooltips[i]]:SetBackdrop{bgFile = TukuiDB["media"].blank, edgeFile = TukuiDB["media"].blank, tile = 0, tileSize = 0, edgeSize = TukuiDB.mult, insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult } }
		_G[tooltips[i]]:SetScript("OnShow", function(self) self:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor)) self:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor)) end)
end

-- Hide PVP text
PVP_ENABLED = ""

-- Statusbar
GameTooltipStatusBar:SetStatusBarTexture(TukuiDB["media"].blank)
GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, 5)
GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, 5)

-- Position default anchor
local function defaultPosition(tt, parent)
	if db.cursor == true then
		tt:ClearAllPoints()
		tt:SetOwner(parent, "ANCHOR_CURSOR")
	else
		tt:ClearAllPoints()
		tt:SetOwner(parent, "ANCHOR_NONE")
		tt:SetPoint("BOTTOMRIGHT", InfoRight, "TOPRIGHT", 0, 5)
	end
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", defaultPosition)

local function gtUpdate(self, ...)
	if self:GetAnchorType() == "ANCHOR_NONE" then
		if TukuiDB["bags"].enable == true and StuffingFrameBags:IsShown() then
			self:ClearAllPoints()
			self:SetPoint("BOTTOMRIGHT",StuffingFrameBags,"TOPRIGHT", 0,4)
		else
			self:ClearAllPoints()
			self:SetPoint("BOTTOMRIGHT", InfoRight, "TOPRIGHT", 0, 5)
		end
	end
end

-- Unit tooltip style
local OnTooltipSetUnit = function(self)
	-- Most of this code was inspired from 
	-- aTooltip (from alza) based on sTooltip (from Shantalya)

	local lines = self:NumLines()
	local name, unit = self:GetUnit()

	if not unit then return end
	
	-- Name text, with level and classification
	_G["GameTooltipTextLeft1"]:SetText(name)
	
	local race				= UnitRace(unit)
	local level				= UnitLevel(unit)
	local levelColor		= GetQuestDifficultyColor(level)
	local classification	= UnitClassification(unit)
	local creatureType		= UnitCreatureType(unit)
	
	if level == -1 then
		level = "??"
		levelColor = { r = 1.00, g = 0.00, b = 0.00 }
	end
	
	if classification == "rareelite" then classification = " R+"
	elseif classification == "rare"  then classification = " R"
	elseif classification == "elite" then classification = "+"
	else classification = "" end
	
	if UnitIsPlayer(unit) then
		if GetGuildInfo(unit) then
			_G["GameTooltipTextLeft2"]:SetFormattedText("<%s>", GetGuildInfo(unit))
		end
		
		local n = GetGuildInfo(unit) and 3 or 2
		--  thx TipTac for the fix above with color blind enabled
		if GetCVar("colorblindMode") == "1" then n = n + 1 end
		_G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, classification, race)
	else
		for i = 2, lines do
			local line = _G["GameTooltipTextLeft"..i]
			if not line or not line:GetText() then return end
			if (level and line:GetText():find("^"..LEVEL)) or (creatureType and line:GetText():find("^"..creatureType)) then
				line:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, classification, creatureType or "")
				break
			end
		end
	end
	
	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local r, g, b = GameTooltip_UnitColor(unit.."target")
		GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
	end
end

-- Item Ref icon
local itemTooltipIcon = CreateFrame("Frame", "ItemRefTooltipIcon", _G["ItemRefTooltip"])
itemTooltipIcon:SetPoint("TOPRIGHT", _G["ItemRefTooltip"], "TOPLEFT", -2, -5)
TukuiDB:SetTemplate(itemTooltipIcon)
itemTooltipIcon:SetHeight(30)
itemTooltipIcon:SetWidth(30)

itemTooltipIcon.texture = itemTooltipIcon:CreateTexture("ItemRefTooltipIcon", "TOOLTIP")
itemTooltipIcon.texture:SetAllPoints(itemTooltipIcon)
itemTooltipIcon.texture:SetTexCoord(.08, .92, .08, .92)

local AddItemIcon = function()
	local frame = _G["ItemRefTooltipIcon"]
	frame:Hide()
	
	local _, link = _G["ItemRefTooltip"]:GetItem()
	local icon = link and GetItemIcon(link)
	if not icon then return end
	
	_G["ItemRefTooltipIcon"].texture:SetTexture(icon)
	frame:Show()
end

hooksecurefunc("SetItemRef", AddItemIcon)

-- Unit class color
function GameTooltip_UnitColor(unit)
	local c
	if UnitIsPlayer(unit) then
		-- Class color
		c = oUF.colors.class[select(2, UnitClass(unit))]
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		-- Tapped coloring
		c = { .5, .5, .5 }
	elseif unit == "pet" and GetPetHappiness() then
		-- Pet happiness color
		c = oUF.colors.happiness[GetPetHappiness()]
	else
		-- Reaction Color
		c = oUF.colors.reaction[UnitReaction(unit, "player")]
	end
	
	if not c then
		c = {.5, .5, .5}
	end
	
    return c[1], c[2], c[3]
end

GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
GameTooltip:HookScript("OnUpdate", gtUpdate)