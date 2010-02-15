--[[

		This is a modified tooltip mod based on FatalEntity work.

--]]

-- Texture tooltips
if not TukuiTooltip == true then return end

local tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip}

for i=1, #tooltips do
		tooltips[i]:SetBackdrop{bgFile = BLANK_TEXTURE, edgeFile = BLANK_TEXTURE, tile = 0, tileSize = 0, edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 } }
		tooltips[i]:SetScript("OnShow", function(self) self:SetBackdropColor(.1,.1,.1,1) self:SetBackdropBorderColor(.6,.6,.6,1) end)
		tooltips[i]:SetScale(1)
end

local gt = GameTooltip
local unitExists, maxHealth

-- Setup new health statusbar

local StatusBar = CreateFrame("StatusBar", nil, GameTooltip);
	StatusBar:SetWidth(1)
	StatusBar:SetHeight(3)
	StatusBar:ClearAllPoints()
	StatusBar:SetPoint("BOTTOMLEFT", 2, 2);
	StatusBar:SetPoint("BOTTOMRIGHT", -2, 2);
	StatusBar:SetStatusBarTexture(BLANK_TEXTURE)
	StatusBar:Hide()

-- Setup Anchor/Healthbar/Instanthide

local function gtUpdate(self, ...)
	local owner = self:GetOwner()
		
	if hide_all_tooltips == true then
		self:Hide()
	end
		
	-- Update Health bar for world units
	if unitExists then
			local currentHealth = UnitHealth("mouseover")
			local green = currentHealth/maxHealth*2
			local red = 1-green
			StatusBar:SetValue(currentHealth)
			StatusBar:SetStatusBarColor(red+1, green, 0)
	else
		StatusBar:Hide()
	end

	if owner == UIParent then
		-- Instantly hide World Unit tooltips
		if not UnitExists("mouseover") and unitExists then
			self:Hide()
			unitExists = false
		elseif (hide_units == true and UnitExists("mouseover")) or (hide_units_combat == true and InCombatLockdown()) then
			self:Hide()
			unitExists = false
		end
	end
end

-- Get Unit Name

local function unitName(unit)
        if not unit then return end
        local unitName, unitRealm       = UnitName(unit)
        local Reaction                  = UnitReaction(unit, "player") or 5
        local Attackable                = UnitCanAttack("player", unit)
        local Dead                      = UnitIsDead(unit)
        local AFK                       = UnitIsAFK(unit)
        local DND                       = UnitIsDND(unit)
        local Tapped                    = UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)

        if unitRealm then unitName = unitName.." - "..unitRealm end
        if Attackable then
		if Tapped or Dead then
			return "|cff888888"..unitName.."|r"
		else
			if Reaction<4 then
				return "|cffff4444"..unitName.."|r"
			elseif Reaction == 4 then
				return "|cffffff44"..unitName.."|r"
			end
		end
	else
		if AFK then Status = " (AFK)" elseif DND then Status = " (DND)" elseif Dead then Status = " (Dead)" else Status = "" end
		if Reaction<4 then
			return "|cff3071bf"..unitName..Status.."|r"
		else
			return "|cff20C117"..unitName..Status.."|r"
		end
	end
end

-- Get Unit Information

local function unitInformation(unit)
	if not unit then return end
	local Race				= UnitRace(unit) or ""
	local Class, engClass 	= UnitClass(unit)
	local Classification	= UnitClassification(unit) or ""
	local creatureType		= UnitCreatureType(unit) or ""
	local PlayerLevel		= UnitLevel("player")
	local Level				= UnitLevel(unit) or ""
	local Player			= UnitIsPlayer(unit)
	local Difficulty		= GetQuestDifficultyColor(Level)
	local LevelColor		= string.format("%02x%02x%02x", Difficulty.r*255, Difficulty.g*255, Difficulty.b*255)

	if Level == -1 then
		Level = "??"
		LevelColor = "ff0000"
	end

	

	if Player then
		local Color = string.format("%02x%02x%02x", RAID_CLASS_COLORS[engClass].r*255, RAID_CLASS_COLORS[engClass].g*255, RAID_CLASS_COLORS[engClass].b*255)
		return "Level |cff"..LevelColor..Level.."|r |cff"..Color..Class.."|r "..Race
	else
		if Classification == "worldboss" then Type = " Boss" elseif
		Classification == "rareelite" then Type = " Rare Elite" elseif
		Classification == "rare" then Type = " Rare" elseif
		Classification == "elite" then Type = " Elite" else
		Type = "" end
		return "Level |cff"..LevelColor..Level.."|r"..Type.." "..creatureType
	end
end

-- Get Unit Guild

local function unitGuild(unit)
	local GuildName = GameTooltipTextLeft2:GetText()
	if GuildName and not GuildName:find("^Level") then
		return "<"..GuildName..">"
	else
		return nil
	end
end

-- Get Unit Target

local function unitTarget(unit)	
	if UnitExists(unit.."target") then
		local mouseoverTarget, _ = UnitName(unit.."target")
		if mouseoverTarget == UnitName("Player") and not UnitIsPlayer(unit) then
			return targetyou
		else 
			if UnitCanAttack("player", unit.."target") or UnitIsPlayer(unit.."target") then
			local Color = string.format("%02x%02x%02x", RAID_CLASS_COLORS[select(2, UnitClass(unit.."target"))].r*255, RAID_CLASS_COLORS[select(2, UnitClass(unit.."target"))].g*255, RAID_CLASS_COLORS[select(2, UnitClass(unit.."target"))].b*255)
				return "|cff"..Color..mouseoverTarget.."|r"
			else
				return "|cffffffff"..mouseoverTarget.."|r"
			end
		end
	else
		return nil
	end
end

-- Set Unit Tooltip

local function gtUnit(self, ...)
	-- Make sure the unit exists
	local _, unit = self:GetUnit()
	if not unit then return end
	-- Only show unit tooltips for world units, not frames

	if self:GetOwner() ~= UIParent and hide_uf_tooltip == true then self:Hide(); return end
	unitExists = true
	-- Setup statusbar
	maxHealth = UnitHealthMax(unit)
	StatusBar:SetMinMaxValues(0, maxHealth)
	StatusBar:Show()
	-- Setup tooltip
	local gtUnitGuild, gtUnitTarget = unitGuild(unit), unitTarget(unit)
	local gtIdx, gtText = 1, {}
	GameTooltipTextLeft1:SetText(unitName(unit))
	
	if gtUnitGuild then
		GameTooltipTextLeft2:SetText(gtUnitGuild)
		GameTooltipTextLeft3:SetText(unitInformation(unit))
	else
		GameTooltipTextLeft2:SetText(unitInformation(unit))
	end

	for i = 1, self:NumLines() do
		local gtLine = _G["GameTooltipTextLeft"..i]
		local gtLineText = gtLine:GetText()
		if not (gtLineText and UnitIsPVP(unit) and gtLineText:find("^"..PVP_ENABLED)) then
			gtText[gtIdx] = gtLineText
			gtIdx = gtIdx + 1
		end
	end

	self:ClearLines()

	for i = 1, gtIdx - 1 do
		local line = gtText[i]
		if line then
			self:AddLine(line, 1, 1, 1, 1)
		end
	end

	if gtUnitTarget then
		self:AddLine(gtUnitTarget, 1, 1, 1, 1)
	end
end

-- Set Default position for non world tooltips
local function gtDefault(tooltip, parent)
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", 2, 2)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", -2, 2)
	GameTooltipStatusBar:SetStatusBarTexture(BLANK_TEXTURE)
	GameTooltipStatusBar:SetStatusBarColor(0.3, 0.9, 0.3, 1)
	GameTooltipStatusBar:SetHeight(2)
	if cursortooltip == true then
		tooltip:SetOwner(parent, "ANCHOR_CURSOR")
	else
		tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint(ttposZ,ttposX,ttposY)
		-- need to show tooltip to top of bags if open because it's ugly over bags
		if TukuiBags == true and StuffingFrameBags:IsShown() then
			tooltip:ClearAllPoints()
			tooltip:SetPoint("BOTTOMRIGHT",StuffingFrameBags,"TOPRIGHT", 0,4)
		end
	end
	tooltip.default = 1;
end

gt:HookScript("OnUpdate", gtUpdate)
gt:HookScript("OnTooltipSetUnit", gtUnit)
hooksecurefunc("GameTooltip_SetDefaultAnchor", gtDefault)
