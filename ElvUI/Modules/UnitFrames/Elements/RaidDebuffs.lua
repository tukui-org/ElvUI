local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_RaidDebuffs(frame)
	local debuff = CreateFrame('Frame', nil, frame.RaisedElementParent)
	debuff:SetTemplate(nil, nil, nil, UF.thinBorders, true)
	debuff:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 20) --Make them appear above regular buffs or debuffs

	local offset = UF.thinBorders and E.mult or E.Border
	debuff.icon = debuff:CreateTexture(nil, 'OVERLAY')
	debuff.icon:SetInside(debuff, offset, offset)

	debuff.count = debuff:CreateFontString(nil, 'OVERLAY')
	debuff.count:FontTemplate(nil, 10, 'OUTLINE')
	debuff.count:Point('BOTTOMRIGHT', 0, 2)
	debuff.count:SetTextColor(1, .9, 0)

	debuff.time = debuff:CreateFontString(nil, 'OVERLAY')
	debuff.time:FontTemplate(nil, 10, 'OUTLINE')
	debuff.time:Point('CENTER')
	debuff.time:SetTextColor(1, .9, 0)

	return debuff
end

function UF:Configure_RaidDebuffs(frame)
	local debuff = frame.RaidDebuffs
	local db = frame.db.rdebuffs

	if db.enable then
		if not frame:IsElementEnabled('RaidDebuffs') then
			frame:EnableElement('RaidDebuffs')
		end

		debuff.showDispellableDebuff = db.showDispellableDebuff
		debuff.onlyMatchSpellID = db.onlyMatchSpellID
		debuff.forceShow = frame.forceShowAuras
		debuff.icon:SetTexCoord(unpack(E.TexCoords))
		debuff:Point('BOTTOM', frame, 'BOTTOM', db.xOffset, db.yOffset + frame.SPACING)
		debuff:Size(db.size)

		local font = UF.LSM:Fetch("font", db.font)
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
