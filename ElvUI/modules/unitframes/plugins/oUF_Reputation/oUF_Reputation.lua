local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local _, ns = ...
local oUF = ns.oUF or oUF
if C.unitframes.enable ~= true then return end
--[[

	Elements handled:
	 .Reputation [statusbar]
	 .Reputation.Text [fontstring] (optional)

	Booleans:
	 - Tooltip

	Functions that can be overridden from within a layout:
	 - PostUpdate(self, event, unit, bar, min, max, value, name, id)
	 - OverrideText(bar, min, max, value, name, id)

--]]

if not oUF then return end

local function tooltip(self)
	local name, id, min, max, value = GetWatchedFactionInfo()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -5)
	GameTooltip:AddLine(string.format('%s (%s)', name, _G['FACTION_STANDING_LABEL'..id]))
	GameTooltip:AddLine(string.format('%d / %d (%d%%)', value - min, max - min, (value - min) / (max - min) * 100))
	GameTooltip:Show()
end

local function update(self, event, unit)
	local bar = self.Reputation
	if(not GetWatchedFactionInfo()) then return bar:Hide() end

	local name, id, min, max, value = GetWatchedFactionInfo()
	bar:SetMinMaxValues(min, max)
	bar:SetValue(value)
	bar:Show()

	if(bar.Text) then
		if(bar.OverrideText) then
			bar:OverrideText(bar, min, max, value, name, id)
		else
			bar.Text:SetFormattedText('%d / %d - %s', value - min, max - min, name)
		end
	end
	
	if bar.color then
		local color = FACTION_BAR_COLORS[id]
		bar:SetStatusBarColor(color.r, color.g, color.b)
	end
	
	if(bar.PostUpdate) then bar.PostUpdate(self, event, unit, bar, min, max, value, name, id) end
end

local function enable(self, unit)
	local bar = self.Reputation
	if(bar and unit == 'player') then
		if(not bar:GetStatusBarTexture()) then
			bar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		self:RegisterEvent('UPDATE_FACTION', update)

		if(bar.Tooltip) then
			bar:EnableMouse()
			bar:HookScript('OnLeave', GameTooltip_Hide)
			bar:HookScript('OnEnter', tooltip)
		end

		return true
	end
end

local function disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', update)
	end
end

oUF:AddElement('Reputation', update, enable, disable)
