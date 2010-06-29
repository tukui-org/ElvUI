local db = TukuiDB["tooltip"]
if not db.enable then return end

-- Texture tooltips
local tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	WorldMapTooltip,
	BNToastFrame.tooltip,
	FriendsTooltip
}

for _, tt in pairs(tooltips) do
	TukuiDB:SetTemplate(tt)
	tt:HookScript("OnShow", function(self)
		self:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
		self:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
	end)
end

-- Hide PVP text
PVP_ENABLED = ""

-- Statusbar
GameTooltipStatusBar:SetStatusBarTexture(TukuiDB["media"].normTex)
GameTooltipStatusBar:SetHeight(TukuiDB:Scale(5))
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", TukuiDB:Scale(2), TukuiDB:Scale(5))
GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -TukuiDB:Scale(2), TukuiDB:Scale(5))

-- Statusbar background
local StatusBarBG = CreateFrame("Frame", "StatusBarBG", GameTooltipStatusBar)
StatusBarBG:SetFrameLevel(GameTooltipStatusBar:GetFrameLevel() - 1)
StatusBarBG:SetPoint("TOPLEFT", -TukuiDB:Scale(2), TukuiDB:Scale(2))
StatusBarBG:SetPoint("BOTTOMRIGHT", TukuiDB:Scale(2), -TukuiDB:Scale(2))
TukuiDB:SetTemplate(StatusBarBG)

-- Position default anchor
local function defaultPosition(tt, parent)
	if db.cursor == true then
		tt:ClearAllPoints()
		tt:SetOwner(parent, "ANCHOR_CURSOR")
	else
		tt:ClearAllPoints()
		tt:SetOwner(parent, "ANCHOR_NONE")
		tt:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB:Scale(5))
	end
end
hooksecurefunc("GameTooltip_SetDefaultAnchor", defaultPosition)

local function OnUpdate(self, ...)
	if self:GetAnchorType() == "ANCHOR_NONE" then
		if InCombatLockdown() and db.hidecombat == true then
			self:SetAlpha(0)
		else
			self:SetAlpha(1)
			if TukuiDB["bags"].enable == true and StuffingFrameBags:IsShown() then
				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", 0, TukuiDB:Scale(4))
			else
				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB:Scale(5))
			end
		end
	end
end

-- Unit tooltip style
local OnTooltipSetUnit = function(self)
	local lines = self:NumLines()
	local _, unit = self:GetUnit()

	if(not unit or not UnitExists(unit)) then return end
	if self:GetOwner() ~= UIParent and db.hideuf == true then self:Hide() return end
	
	local level = UnitLevel(unit)
	local levelColor = GetQuestDifficultyColor(level)
	local race	= UnitRace(unit)
	local title = UnitPVPName(unit)
	local unitName, unitRealm = UnitName(unit)
	local Dead = UnitIsDead(unit)
	local AFK = UnitIsAFK(unit)
	local DND = UnitIsDND(unit)
	local isPlayer = UnitIsPlayer(unit)
	local r, g, b = GameTooltip_UnitColor(unit)
	
	-- display unit name / realm if available / AFK or DND status if available
	if AFK and isPlayer then Status = " (AFK)" elseif DND and isPlayer then Status = " (DND)" else Status = ""  end
	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", title or unitName, unitRealm and unitRealm ~= "" and " - "..unitRealm or "", Status)

	if level == -1 then
		level = "??"
		levelColor = { r = 1.00, g = 0.00, b = 0.00 }
	end

	if UnitIsPlayer(unit) then		
		if GetGuildInfo(unit) then
			_G["GameTooltipTextLeft2"]:SetFormattedText("<%s>", GetGuildInfo(unit))
		end

		local n = GetGuildInfo(unit) and 3 or 2
		--  thx TipTac for the fix above with color blind enabled
		if GetCVar("colorblindMode") == "1" then n = n + 1 end
		_G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%02x%02x%02x%s|r %s", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, race)
	else
		local classification = UnitClassification(unit)
		local creatureType = UnitCreatureType(unit)

		classification = (classification == "rareelite" and " R+") or
			(classification == "rare" and " R") or
			(classification == "elite" and "+") or ""

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
	
	-- tooltip border color, status bar color & status bar background border color
	GameTooltip:SetBackdropBorderColor(r, g, b)
	GameTooltipStatusBar:SetStatusBarColor(r, g, b)
	StatusBarBG:SetBackdropBorderColor(r, g, b)
end

-- Unit color
GameTooltip_UnitColor = function(unit)
	local player = UnitIsPlayer(unit)
	local reaction = UnitReaction(unit, "player") or 5
	local tapped = UnitIsTapped(unit)
	local tappedplayer = UnitIsTappedByPlayer(unit)
	local connected = UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local r, g, b

	if tapped and not tappedplayer or not connected or dead or ghost then
		r, g, b = 0.55, 0.57, 0.61
	elseif player then
		local _, class = UnitClass(unit)
		r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
	elseif reaction then
		r, g, b = FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
	else
		r, g, b = UnitSelectionColor(unit)
	end
	
	return r, g, b
end

-- function to short-display HP value on StatusBar
local function ShortValue(value)
        if value >= 1e7 then
                return ('%.1fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
        elseif value >= 1e6 then
                return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
        elseif value >= 1e5 then
                return ('%.0fk'):format(value / 1e3)
        elseif value >= 1e3 then
                return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
        else
                return value
        end
end

-- update HP value on status bar
GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
        if not value then
                return
        end
        local min, max = self:GetMinMaxValues()
        if (value < min) or (value > max) then
                return
        end
		local _, unit = GameTooltip:GetUnit()
		
		-- fix target of target returning nil
		if (not unit) then
			local ToT = GetMouseFocus()
			unit = ToT and ToT:GetAttribute("unit")
		end
		
		-- fix mage mirror sometime returning nil
		if (not unit) and (UnitExists("mouseover")) then
			unit = "mouseover"
		end

		if not self.text then
			self.text = self:CreateFontString(nil, "OVERLAY")
			self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, TukuiDB:Scale(6))
			self.text:SetFont(TukuiDB["media"].font, 12, "THINOUTLINE")
			self.text:Show()
			if unit then
				min, max = UnitHealth(unit), UnitHealthMax(unit)
				local hp = ShortValue(min).." / "..ShortValue(max)
				self.text:SetText(hp)
			end
		else
			if unit then
				min, max = UnitHealth(unit), UnitHealthMax(unit)
				self.text:Show()
				local hp = ShortValue(min).." / "..ShortValue(max)
				self.text:SetText(hp)
			else
				self.text:Hide()
			end
		end
end)

-- This will clean up border/background color to default when we aren't showing a unit
local OnTooltipCleared = function(self)
	self:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
	GameTooltipStatusBar:SetStatusBarColor(unpack(TukuiDB["media"].bordercolor))
	StatusBarBG:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
end

-- border color according to if unit is player/friendly/hostile and item quality
local OnShow = function(self)
	local ToT = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (ToT and ToT:GetAttribute("unit"))
	local reaction = unit and UnitReaction("player", unit)
	local isPlayer = unit and UnitIsPlayer(unit)
		
	if isPlayer or reaction then
		local r, g, b = GameTooltip_UnitColor(unit)
		self:SetBackdropBorderColor(r, g, b)
		GameTooltipStatusBar:SetStatusBarColor(r, g, b)
		StatusBarBG:SetBackdropBorderColor(r, g, b)
	else
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			self:SetBackdropBorderColor(r, g, b)
		else
			self:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
		end
	end
end

ItemRefTooltip:HookScript("OnShow", OnShow)
GameTooltip:HookScript("OnShow", OnShow)
GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
GameTooltip:HookScript("OnUpdate", OnUpdate)

-- Reskin and reposition battle.net popup
TukuiDB:SetTemplate(BNToastFrame)
BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, TukuiDB:Scale(5))
	self:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	self:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
end)

-- Hide tooltips in combat for actions, pet actions and shapeshift
if db.hidebuttons == true then
	local CombatHideActionButtonsTooltip = function(self)
		if not IsShiftKeyDown() then
			self:Hide()
		end
	end
 
	hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
	hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
	hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
end