local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
--WoW API / Variables

function UF:Construct_ReadyCheckIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "OVERLAY", nil, 7)
	tex:Size(12)
	tex:Point("BOTTOM", frame.Health, "BOTTOM", 0, 2)

	return tex
end

function UF:Configure_ReadyCheckIcon(frame)
	local ReadyCheckIndicator = frame.ReadyCheckIndicator
	local db = frame.db

	if (db.readycheckIcon.enable) then
		if not frame:IsElementEnabled('ReadyCheckIndicator') then
			frame:EnableElement('ReadyCheckIndicator')
		end

		local attachPoint = self:GetObjectAnchorPoint(frame, db.readycheckIcon.attachTo)
		ReadyCheckIndicator:ClearAllPoints()
		ReadyCheckIndicator:Point(db.readycheckIcon.position, attachPoint, db.readycheckIcon.position, db.readycheckIcon.xOffset, db.readycheckIcon.yOffset)
		ReadyCheckIndicator:Size(db.readycheckIcon.size)
	else
		frame:DisableElement('ReadyCheckIndicator')
	end
end
