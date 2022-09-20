local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local unpack = unpack
local CreateFrame = CreateFrame

function UF:Construct_RaidDebuffs(frame)
	local debuff = CreateFrame('Frame', nil, frame.RaisedElementParent)
	debuff:SetTemplate(nil, nil, nil, nil, true)
	debuff:SetFrameLevel(frame.RaisedElementParent.RaidDebuffLevel)

	debuff.icon = debuff:CreateTexture(nil, 'OVERLAY')
	debuff.icon:SetInside(debuff, UF.BORDER, UF.BORDER)

	debuff.count = debuff:CreateFontString(nil, 'OVERLAY')
	debuff.count:FontTemplate(nil, 10, 'OUTLINE')
	debuff.count:Point('BOTTOMRIGHT', 0, 2)
	debuff.count:SetTextColor(1, .9, 0)

	debuff.time = debuff:CreateFontString(nil, 'OVERLAY')
	debuff.time:FontTemplate(nil, 10, 'OUTLINE')
	debuff.time:Point('CENTER')
	debuff.time:SetTextColor(1, .9, 0)

	debuff.ReverseTimer = E.ReverseTimer

	return debuff
end

function UF:Configure_RaidDebuffs(frame)
	local db = frame.db and frame.db.rdebuffs
	if db and db.enable then
		if not frame:IsElementEnabled('RaidDebuffs') then
			frame:EnableElement('RaidDebuffs')
		end

		local debuff = frame.RaidDebuffs
		debuff.showDispellableDebuff = db.showDispellableDebuff
		debuff.onlyMatchSpellID = db.onlyMatchSpellID
		debuff.forceShow = frame.forceShowAuras
		debuff.icon:SetTexCoord(unpack(E.TexCoords))
		debuff:Point('BOTTOM', frame, 'BOTTOM', db.xOffset, db.yOffset + UF.SPACING)
		debuff:Size(db.size)

		local font = LSM:Fetch('font', db.font)
		local stackColor = db.stack.color
		debuff.count:FontTemplate(font, db.fontSize, db.fontOutline)
		debuff.count:ClearAllPoints()
		debuff.count:Point(db.stack.position, db.stack.xOffset, db.stack.yOffset)
		debuff.count:SetTextColor(stackColor.r, stackColor.g, stackColor.b, stackColor.a)

		local durationColor = db.duration.color
		debuff.time:FontTemplate(font, db.fontSize, db.fontOutline)
		debuff.time:ClearAllPoints()
		debuff.time:Point(db.duration.position, db.duration.xOffset, db.duration.yOffset)
		debuff.time:SetTextColor(durationColor.r, durationColor.g, durationColor.b, durationColor.a)
	elseif frame:IsElementEnabled('RaidDebuffs') then
		frame:DisableElement('RaidDebuffs')
	end
end
