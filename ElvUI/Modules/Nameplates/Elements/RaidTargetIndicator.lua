local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

function NP:RaidTargetIndicator_Override()
	local element = self.RaidTargetIndicator

	if self.unit then
		local index = GetRaidTargetIndex(self.unit)
		if index and not self.isMe then
			SetRaidTargetIconTexture(element, index)
			element:Show()
		else
			element:Hide()
		end
	end
end

function NP:Construct_RaidTargetIndicator(nameplate)
	local RaidTargetIndicator = nameplate:CreateTexture(nil, 'OVERLAY', 7)
	RaidTargetIndicator.Override = NP.RaidTargetIndicator_Override

	return RaidTargetIndicator
end

function NP:Update_RaidTargetIndicator(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.raidTargetIndicator and db.raidTargetIndicator.enable then
		if not nameplate:IsElementEnabled('RaidTargetIndicator') then
			nameplate:EnableElement('RaidTargetIndicator')
		end

		nameplate.RaidTargetIndicator:ClearAllPoints()
		nameplate.RaidTargetIndicator:Point(E.InversePoints[db.raidTargetIndicator.position], nameplate, db.raidTargetIndicator.position, db.raidTargetIndicator.xOffset, db.raidTargetIndicator.yOffset)
		nameplate.RaidTargetIndicator:Size(db.raidTargetIndicator.size)
	elseif nameplate:IsElementEnabled('RaidTargetIndicator') then
		nameplate:DisableElement('RaidTargetIndicator')
	end
end
