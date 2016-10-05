--[[ Element: Totem Indicator

 Handles updating and visibility of Shaman totems, Druid mushrooms and Death
 Knight ghouls.

 Widget

 Totems - A table to hold sub-widgets.

 Sub-Widgets

 Totem     - Any UI widget.
 .Icon     - A Texture representing the totem icon.
 .Cooldown - A Cooldown representing the duration of the totem.

 Notes

 OnEnter and OnLeave will be set to display the default Tooltip, if the
 `Totem` widget is mouse enabled.

 Options

 :UpdateTooltip - The function that should populate the tooltip, when the
                  `Totem` widget is hovered. A default function, which calls
                  `:SetTotem(id)`, will be used if none is defined.

 Examples

   local Totems = {}
   for index = 1, MAX_TOTEMS do
      -- Position and size of the totem indicator
      local Totem = CreateFrame('Button', nil, self)
      Totem:SetSize(40, 40)
      Totem:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Totem:GetWidth(), 0)
      
      local Icon = Totem:CreateTexture(nil, "OVERLAY")
      Icon:SetAllPoints()
      
      local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
      Cooldown:SetAllPoints()
      
      Totem.Icon = Icon
      Totem.Cooldown = Cooldown
      
      Totems[index] = Totem
   end
   
   -- Register with oUF
   self.Totems = Totems

 Hooks

 Override(self) - Used to completely override the internal update function.
                  Removing the table key entry will make the element fall-back
                  to its internal function again.
]]

local parent, ns = ...
local oUF = ns.oUF

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
	if(slot > #totems) then return end

	if(totems.PreUpdate) then totems:PreUpdate(slot) end

	local totem = totems[slot]
	local haveTotem, name, start, duration, icon = GetTotemInfo(slot)
	if(haveTotem and duration > 0) then
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
		return totems:PostUpdate(slot, haveTotem, name, start, duration, icon)
	end
end

local Path = function(self, ...)
	return (self.Totems.Override or UpdateTotem) (self, ...)
end

local Update = function(self, event)
	for i = 1, #self.Totems do
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

		for i = 1, #totems do
			local totem = totems[i]

			totem:SetID(i)

			if(totem:IsMouseEnabled()) then
				totem:SetScript('OnEnter', OnEnter)
				totem:SetScript('OnLeave', OnLeave)

				if(not totem.UpdateTooltip) then
					totem.UpdateTooltip = UpdateTooltip
				end
			end
		end

		self:RegisterEvent('PLAYER_TOTEM_UPDATE', Path, true)

		TotemFrame:UnregisterEvent"PLAYER_TOTEM_UPDATE"
		TotemFrame:UnregisterEvent"PLAYER_ENTERING_WORLD"
		TotemFrame:UnregisterEvent"UPDATE_SHAPESHIFT_FORM"
		TotemFrame:UnregisterEvent"PLAYER_TALENT_UPDATE"

		return true
	end
end

local Disable = function(self)
	local totems = self.Totems

	if(totems) then
		for i = 1, #totems do
			totems[i]:Hide()
		end

		TotemFrame:RegisterEvent"PLAYER_TOTEM_UPDATE"
		TotemFrame:RegisterEvent"PLAYER_ENTERING_WORLD"
		TotemFrame:RegisterEvent"UPDATE_SHAPESHIFT_FORM"
		TotemFrame:RegisterEvent"PLAYER_TALENT_UPDATE"

		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', Path)
	end
end

oUF:AddElement("Totems", Update, Enable, Disable)
