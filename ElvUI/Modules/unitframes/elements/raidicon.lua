local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

function UF:Construct_RaidIcon(frame)
	local tex = (frame.RaisedElementParent or frame):CreateTexture(nil, "OVERLAY")
	tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	tex:Size(18)
	tex:Point("CENTER", frame.Health, "TOP", 0, 2)
	tex.SetTexture = E.noop

	return tex
end

function UF:Configure_RaidIcon(frame)
	local RI = frame.RaidIcon
	local db = frame.db

	if db.raidicon.enable then
		frame:EnableElement('RaidIcon')
		RI:Show()
		RI:Size(db.raidicon.size)

		local attachPoint = self:GetObjectAnchorPoint(frame, db.raidicon.attachToObject)
		RI:ClearAllPoints()
		RI:Point(db.raidicon.attachTo, attachPoint, db.raidicon.attachTo, db.raidicon.xOffset, db.raidicon.yOffset)
	else
		frame:DisableElement('RaidIcon')
		RI:Hide()
	end
end