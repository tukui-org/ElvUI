local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')

local CreateFrame = CreateFrame
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

function NP:RaidTargetIndicator_Override()
	local element = self.RaidTargetIndicator
	local index = self.__unit and GetRaidTargetIndex(self.__unit)

	if index then
		SetRaidTargetIconTexture(element, index)
		element:Show()
	else
		element:Hide()
	end
end

function NP:Construct_RaidTargetIndicator(nameplate)
	local element = CreateFrame('Frame', '$parent_RaidTargetIndicator', nameplate)
	element:SetFrameLevel(nameplate.RaisedElement.RaidTargetIndicatorLevel)

	local RaidTargetIndicator = element:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator.Override = NP.RaidTargetIndicator_Override
	RaidTargetIndicator:Hide()

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
