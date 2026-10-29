local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local CreateFrame = CreateFrame

function UF:Construct_RaidIcon(frame)
	local anchor = CreateFrame('Frame', nil, frame.RaisedElementParent)
	anchor:SetFrameLevel(frame.RaisedElementParent.RaidIconLevel)

	local tex = anchor:CreateTexture(nil, 'OVERLAY')
	tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	tex:Point('CENTER', frame.Health, 'TOP', 0, 2)
	tex:Size(18)
	tex:Hide()

	return tex
end

function UF:Configure_RaidIcon(frame)
	local icon = frame.RaidTargetIndicator
	local db = frame.db

	if db.raidicon.enable then
		frame:EnableElement('RaidTargetIndicator')
		icon:Size(db.raidicon.size)

		local attachPoint = UF:GetObjectAnchorPoint(frame, db.raidicon.attachToObject)
		icon:ClearAllPoints()
		icon:Point(db.raidicon.attachTo, attachPoint, db.raidicon.attachTo, db.raidicon.xOffset, db.raidicon.yOffset)
	else
		frame:DisableElement('RaidTargetIndicator')
	end
end
