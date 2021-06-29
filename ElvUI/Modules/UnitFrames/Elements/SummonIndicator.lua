local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')

function UF:Construct_SummonIcon(frame)
	local tex = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY')
	tex:Point('CENTER', frame.Health, 'CENTER')
	tex:Size(30)
	tex:SetDrawLayer('OVERLAY', 7)

	return tex
end

function UF:Configure_SummonIcon(frame)
	local SI = frame.SummonIndicator
	local db = frame.db

	if db.summonIcon.enable then
		frame:EnableElement('SummonIndicator')
		SI:Show()
		SI:Size(db.summonIcon.size)

		local attachPoint = self:GetObjectAnchorPoint(frame, db.summonIcon.attachToObject)
		SI:ClearAllPoints()
		SI:Point(db.summonIcon.attachTo, attachPoint, db.summonIcon.attachTo, db.summonIcon.xOffset, db.summonIcon.yOffset)
	else
		frame:DisableElement('SummonIndicator')
		SI:Hide()
	end
end
