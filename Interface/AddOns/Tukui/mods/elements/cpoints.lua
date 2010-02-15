local parent, ns = ...
local oUF = ns.oUF

local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local Update = function(self, event, unit)
	local cpoints = self.CPoints
	if(self.unit ~= unit and (cpoints.unit and cpoints.unit ~= unit)) then return end
	local cp = GetComboPoints(cpoints.unit or unit, 'target')

	if(#cpoints == 0) then
		cpoints:SetText((cp > 0) and cp)
	else
		for i=1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:Show()
			else
				cpoints[i]:Hide()
			end
		end
	end
end

local Enable = function(self)
	if(self.CPoints) then
		self:RegisterEvent('UNIT_COMBO_POINTS', Update)

		return true
	end
end

local Disable = function(self)
	if(self.CPoints) then
		self:UnregisterEvent('UNIT_COMBO_POINTS', Update)
	end
end

oUF:AddElement('CPoints', Update, Enable, Disable)
