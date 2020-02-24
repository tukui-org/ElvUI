local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_RaidDebuffs(frame)
	local rdebuff = CreateFrame('Frame', nil, frame.RaisedElementParent)
	rdebuff:SetTemplate(nil, nil, nil, UF.thinBorders, true)
	rdebuff:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 20) --Make them appear above regular buffs or debuffs

	local offset = UF.thinBorders and E.mult or E.Border
	rdebuff.icon = rdebuff:CreateTexture(nil, 'OVERLAY')
	rdebuff.icon:SetInside(rdebuff, offset, offset)

	rdebuff.count = rdebuff:CreateFontString(nil, 'OVERLAY')
	rdebuff.count:FontTemplate(nil, 10, 'OUTLINE')
	rdebuff.count:Point('BOTTOMRIGHT', 0, 2)
	rdebuff.count:SetTextColor(1, .9, 0)

	rdebuff.time = rdebuff:CreateFontString(nil, 'OVERLAY')
	rdebuff.time:FontTemplate(nil, 10, 'OUTLINE')
	rdebuff.time:Point('CENTER')
	rdebuff.time:SetTextColor(1, .9, 0)

	return rdebuff
end

function UF:Configure_RaidDebuffs(frame)
	local debuffs = frame.RaidDebuffs
	local db = frame.db.rdebuffs

	if db.enable then
		if not frame:IsElementEnabled('RaidDebuffs') then
			frame:EnableElement('RaidDebuffs')
		end

		debuffs.showDispellableDebuff = db.showDispellableDebuff
		debuffs.onlyMatchSpellID = db.onlyMatchSpellID
		debuffs.forceShow = frame.forceShowAuras
		debuffs.icon:SetTexCoord(unpack(E.TexCoords))
		debuffs:Point('BOTTOM', frame, 'BOTTOM', db.xOffset, db.yOffset + frame.SPACING)
		debuffs:Size(db.size)

		local font = UF.LSM:Fetch("font", db.font)
		local stackColor = db.stack.color
		debuffs.count:FontTemplate(font, db.fontSize, db.fontOutline)
		debuffs.count:ClearAllPoints()
		debuffs.count:Point(db.stack.position, db.stack.xOffset, db.stack.yOffset)
		debuffs.count:SetTextColor(stackColor.r, stackColor.g, stackColor.b, stackColor.a)

		local durationColor = db.duration.color
		debuffs.time:FontTemplate(font, db.fontSize, db.fontOutline)
		debuffs.time:ClearAllPoints()
		debuffs.time:Point(db.duration.position, db.duration.xOffset, db.duration.yOffset)
		debuffs.time:SetTextColor(durationColor.r, durationColor.g, durationColor.b, durationColor.a)
	elseif frame:IsElementEnabled('RaidDebuffs') then
		frame:DisableElement('RaidDebuffs')
		debuffs:Hide()
	end
end
