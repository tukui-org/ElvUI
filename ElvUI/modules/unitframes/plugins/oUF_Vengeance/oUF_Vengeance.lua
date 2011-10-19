--[[
	Project.: oUF_Vengeance
	File....: oUF_Vengeance.lua
	Version.: 40200.5
	Rev Date: 06/28/2011
	Authors.: Shandrela [EU-Baelgun] <Bloodmoon>
]]

--[[
	Elements handled:
	 .Vengeance [frame]
	 .Vengeance.Text [fontstring]
		
	Code Example:
	 .Vengeance = CreateFrame("StatusBar", nil, self)
	 .Vengeance:SetWidth(400)
	 .Vengeance:SetHeight(20)
	 .Vengeance:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
	 .Vengeance:SetStatusBarTexture(normTex)
	 .Vengeance:SetStatusBarColor(1,0,0)
	 
	Functions that can be overridden from within a layout:
	 - :OverrideText(value)
	 
	Possible OverrideText function:
	
	local VengOverrideText(bar, value)
		local text = bar.Text
		
		text:SetText(value)
	end
	...
	self.Vengeance.OverrideText = VengOverrideText
	
	others:
	self.Vengeance.showInfight [boolean]
	if true, the Vengeance bar will be shown infight, even if you haven't got stacks of Vengeance
--]]

local _, ns = ...
local oUF = oUF or ns.oUF

local _, class = UnitClass("player")
local vengeance = GetSpellInfo(93098)

local UnitAura = UnitAura
local InCombatLockdown = InCombatLockdown

local tooltip = CreateFrame("GameTooltip", "VengeanceTooltip", UIParent, "GameTooltipTemplate")
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

local function GetTooltipText(...)
	local text = ""
	for i=1,select("#",...) do
		local rgn = select(i,...)
		if rgn and rgn:GetObjectType() == "FontString" then
			text = text .. (rgn:GetText() or "")
		end
	end
	return text
end

local function valueChanged(self, event, unit)
	if unit ~= "player" then return end
	local bar = self.Vengeance
	
	if not bar.isTank then
		bar:Hide()
		return
	end
	
	if bar.PreUpdate then
		return bar:PreUpdate(name)
	end	
	
	local name = UnitAura("player", vengeance, nil, "PLAYER|HELPFUL")

	if name then
		tooltip:ClearLines()
		tooltip:SetUnitBuff("player", name)
		local text = GetTooltipText(tooltip:GetRegions())
		local value = tonumber(string.match(text,"%d+"))
		if value then
			if value > bar.max then value = bar.max end
			if value == bar.value then return end
			
			bar:SetMinMaxValues(0, bar.max)
			bar:SetValue(value)
			bar.value = value
			bar:Show()
			
			if bar.Text then
				if bar.OverrideText then
					bar:OverrideText(value)
				else
					bar.Text:SetText(value)
				end
			end
		end
	elseif bar.showInfight and InCombatLockdown() then
		bar:Show()
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)
		bar.value = 0
	else
		bar:Hide()
		bar.value = 0
	end
	
	if bar.PostUpdate then
		return bar:PostUpdate(name)
	end
end

local function maxChanged(self, event, unit)
	if unit ~= "player" then return end
	local bar = self.Vengeance
	
	if not bar.isTank then
		bar:Hide()
		return
	end
	
	local health = UnitHealthMax("player")
	local _, stamina = UnitStat("player", 3)
	
	if not health or not stamina then return end
	
	bar.max = 0.1 * (health - 15 * stamina) + stamina
	bar:SetMinMaxValues(0, bar.max)
	
	valueChanged(self, event, unit)
end

local function isTank(self, event)
	local masteryIndex = GetPrimaryTalentTree()
	local bar = self.Vengeance
	
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	
	if masteryIndex then
		if class == "DRUID" and masteryIndex == 2 then
			bar.isTank = true
		elseif (class == "DEATH KNIGHT" or class == "DEATHKNIGHT") and masteryIndex == 1 then
			bar.isTank = true
		elseif class == "PALADIN" and masteryIndex == 2 then
			bar.isTank = true
		elseif class == "WARRIOR" and masteryIndex == 3 then
			bar.isTank = true
		else
			bar.isTank = false
			bar:Hide()
		end
	else
		bar.isTank = false
		bar:Hide()
	end
	
	maxChanged(self, event, "player")
end

local function Enable(self, unit)
	local bar = self.Vengeance
	
	if bar and unit == "player" then
		bar.max = 0
		bar.value = 0
		
		self:RegisterEvent("UNIT_AURA", valueChanged)
		
		self:RegisterEvent("UNIT_MAXHEALTH", maxChanged)
		self:RegisterEvent("UNIT_LEVEL", maxChanged)
		
		self:RegisterEvent("PLAYER_REGEN_DISABLED", isTank)
		
		bar:Hide()
		
		return true
	end
end

local function Disable(self)
	local bar = self.Vengeance
	
	if bar then
		self:UnregisterEvent("UNIT_AURA", valueChanged)
		
		self:UnregisterEvent("UNIT_MAXHEALTH", maxChanged)
		self:UnregisterEvent("UNIT_LEVEL", maxChanged)
		
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", isTank)
	end
end

oUF:AddElement("Vengeance", nil, Enable, Disable)