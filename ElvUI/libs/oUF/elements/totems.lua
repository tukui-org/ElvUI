local parent, ns = ...
local oUF = ns.oUF

-- colors
-- from Interface/BUTTONS/UI-TotemBar.blp
oUF.colors.totems = {
	[FIRE_TOTEM_SLOT] = { 181/255, 073/255, 033/255 },
	[EARTH_TOTEM_SLOT] = { 074/255, 142/255, 041/255 },
	[WATER_TOTEM_SLOT] = { 057/255, 146/255, 181/255 },
	[AIR_TOTEM_SLOT] = { 132/255, 056/255, 231/255 }
}

local tmap = SHAMAN_TOTEM_PRIORITIES

local OnClick = function(self)
	DestroyTotem(self:GetID())
end

local UpdateTooltip = function(self)
	GameTooltip:SetTotem(self:GetID())
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local UpdateTotem = function(self, event, slot)
	local totems = self.Totems

	if(totems.PreUpdate) then totems:PreUpdate(tmap[slot]) end

	local totem = totems[tmap[slot]]
	local haveTotem, name, start, duration, icon = GetTotemInfo(slot)
	if(duration > 0) then
		if(totem.Icon) then
			totem.Icon:SetTexture(icon)
		end

		if(totem.Cooldown) then
			totem.Cooldown:SetCooldown(start, duration)
		end

		totem:Show()
	else
		totem:Hide()
	end

	if(totems.PostUpdate) then
		return totems:PostUpdate(tmap[slot], haveTotem, name, start, duration, icon)
	end
end

local Path = function(self, ...)
	return (self.Totems.Override or UpdateTotem) (self, ...)
end

local Update = function(self, event)
	for i = 1, MAX_TOTEMS do
		Path(self, event, i)
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local totems = self.Totems

	if(totems) then
		totems.__owner = self
		totems.ForceUpdate = ForceUpdate

		for i = 1, MAX_TOTEMS do
			local totem = totems[i]

			totem:SetID(tmap[i])

			if(totem:HasScript'OnClick') then
				totem:SetScript('OnClick', OnClick)
			end

			if(totem:IsMouseEnabled()) then
				totem:SetScript('OnEnter', OnEnter)
				totem:SetScript('OnLeave', OnLeave)

				if(not totem.UpdateTooltip) then
					totem.UpdateTooltip = UpdateTooltip
				end
			end
		end

		self:RegisterEvent('PLAYER_TOTEM_UPDATE', Path, true)

		TotemFrame.Show = TotemFrame.Hide
		TotemFrame:Hide()

		TotemFrame:UnregisterEvent"PLAYER_TOTEM_UPDATE"
		TotemFrame:UnregisterEvent"PLAYER_ENTERING_WORLD"
		TotemFrame:UnregisterEvent"UPDATE_SHAPESHIFT_FORM"
		TotemFrame:UnregisterEvent"PLAYER_TALENT_UPDATE"

		return true
	end
end

local Disable = function(self)
	if(self.Totems) then
		TotemFrame.Show = nil
		TotemFrame:Show()

		TotemFrame:RegisterEvent"PLAYER_TOTEM_UPDATE"
		TotemFrame:RegisterEvent"PLAYER_ENTERING_WORLD"
		TotemFrame:RegisterEvent"UPDATE_SHAPESHIFT_FORM"
		TotemFrame:RegisterEvent"PLAYER_TALENT_UPDATE"

		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', Path)
	end
end

oUF:AddElement("Totems", Update, Enable, Disable)
