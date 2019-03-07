local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local UnitIsUnit = UnitIsUnit
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

function NP:Construct_RaidTargetIndicator(nameplate)
	local RaidTargetIndicator = nameplate:CreateTexture(nil, 'OVERLAY', 7)

	function RaidTargetIndicator:Override(event)
		local element = self.RaidTargetIndicator

		if self.unit then
			local index = GetRaidTargetIndex(self.unit)
			if (index) and not UnitIsUnit(self.unit, 'player') then
				SetRaidTargetIconTexture(element, index)
				element:Show()
			else
				element:Hide()
			end
		end
	end

	return RaidTargetIndicator
end

function NP:Update_RaidTargetIndicator(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.raidTargetIndicator and db.raidTargetIndicator.enable then
		if not nameplate:IsElementEnabled('RaidTargetIndicator') then
			nameplate:EnableElement('RaidTargetIndicator')
		end

		nameplate.RaidTargetIndicator:Size(db.raidTargetIndicator.size, db.raidTargetIndicator.size)

		nameplate.RaidTargetIndicator:ClearAllPoints()
		nameplate.RaidTargetIndicator:Point(E.InversePoints[db.raidTargetIndicator.position], nameplate, db.raidTargetIndicator.position, db.raidTargetIndicator.xOffset, db.raidTargetIndicator.yOffset)
	else
		if nameplate:IsElementEnabled('RaidTargetIndicator') then
			nameplate:DisableElement('RaidTargetIndicator')
		end
	end
end
