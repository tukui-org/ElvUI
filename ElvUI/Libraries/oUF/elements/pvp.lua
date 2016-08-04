--[[ Element: PvP and Prestige Icons

 Handles updating and visibility of PvP and prestige icons based on unit's PvP
 status and prestige level.

 Widget

 PvP - A Texture used to display faction, FFA PvP status or prestige icon.

 Sub-Widgets

 Prestige - A Texture used to display prestige background image.

 Notes

 This element updates by changing the texture;
 `Prestige` texture has to be on a lower sub-layer than `PvP` texture.

 Examples

   -- Position and size
   local PvP = self:CreateTexture(nil, 'ARTWORK', nil, 1)
   PvP:SetSize(30, 30)
   PvP:SetPoint('RIGHT', self, 'LEFT')

   local Prestige = self:CreateTexture(nil, 'ARTWORK')
   Prestige:SetSize(50, 52)
   Prestige:SetPoint('CENTER', PvP, 'CENTER')

   -- Register it with oUF
   self.PvP = PvP
   self.PvP.Prestige = Prestige

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

local function Update(self, event, unit)
	if(unit ~= self.unit) then return end

	local pvp = self.PvP

	if(pvp.PreUpdate) then
		pvp:PreUpdate(unit)
	end

	local status
	local hasPrestige
	local level = UnitPrestige(unit)
	local factionGroup = UnitFactionGroup(unit)

	if(UnitIsPVPFreeForAll(unit)) then
		if(level > 0 and pvp.Prestige) then
			pvp:SetTexture(GetPrestigeInfo(level))
			pvp:SetTexCoord(0, 1, 0, 1)

			pvp.Prestige:SetAtlas('honorsystem-portrait-neutral', false)

			hasPrestige = true
		else
			pvp:SetTexture('Interface\\TargetingFrame\\UI-PVP-FFA')
			pvp:SetTexCoord(0, 0.65625, 0, 0.65625)
		end

		status = 'ffa'
	elseif(factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		if(UnitIsMercenary(unit)) then
			if(factionGroup == 'Horde') then
				factionGroup = 'Alliance'
			elseif(factionGroup == 'Alliance') then
				factionGroup = 'Horde'
			end
		end

		if(level > 0 and pvp.Prestige) then
			pvp:SetTexture(GetPrestigeInfo(level))
			pvp:SetTexCoord(0, 1, 0, 1)

			pvp.Prestige:SetAtlas('honorsystem-portrait-'..factionGroup, false)

			hasPrestige = true
		else
			pvp:SetTexture('Interface\\TargetingFrame\\UI-PVP-'..factionGroup)
			pvp:SetTexCoord(0, 0.65625, 0, 0.65625)
		end

		status = factionGroup
	end

	if(status) then
		pvp:Show()

		if(pvp.Prestige) then
			if(hasPrestige) then
				pvp.Prestige:Show()
			else
				pvp.Prestige:Hide()
			end
		end
	else
		pvp:Hide()

		if(pvp.Prestige) then
			pvp.Prestige:Hide()
		end
	end

	if(pvp.PostUpdate) then
		return pvp:PostUpdate(unit, status, hasPrestige, level)
	end
end

local function Path(self, ...)
	return (self.PvP.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local pvp = self.PvP

	if(pvp) then
		pvp.__owner = self
		pvp.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_FACTION', Path)

		if(pvp.Prestige) then
			self:RegisterEvent('HONOR_PRESTIGE_UPDATE', Path)
		end

		return true
	end
end

local function Disable(self)
	local pvp = self.PvP

	if(pvp) then
		pvp:Hide()

		self:UnregisterEvent('UNIT_FACTION', Path)

		if(pvp.Prestige) then
			pvp.Prestige:Hide()

			self:UnregisterEvent('HONOR_PRESTIGE_UPDATE', Path)
		end
	end
end

oUF:AddElement('PvP', Path, Enable, Disable)
