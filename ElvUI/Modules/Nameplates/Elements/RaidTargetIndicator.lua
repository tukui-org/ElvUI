local E, L, V, P, G = unpack(ElvUI)

local NP = E:GetModule('NamePlates')

function NP:Construct_RaidTargetIndicator(frame)
	local RaidTargetIndicator = frame:CreateTexture(nil, 'OVERLAY', 7)
	RaidTargetIndicator:SetSize(24, 24)
	RaidTargetIndicator:Point('BOTTOM', frame.Health, 'TOP', 0, 24)
	RaidTargetIndicator.Override = function(f, event)
		local element = f.RaidTargetIndicator

		if f.unit then
			local index = GetRaidTargetIndex(f.unit)
			if (index) and not UnitIsUnit(f.unit, 'player') then
				SetRaidTargetIconTexture(element, index)
				element:Show()
			else
				element:Hide()
			end
		end
	end

	return RaidTargetIndicator
end