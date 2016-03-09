local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_RaidDebuffs(frame)
	local rdebuff = CreateFrame('Frame', nil, frame.RaisedElementParent)
	rdebuff:SetTemplate("Default", nil, nil, (UF.thinBorders and not E.global.tukuiMode))

	local offset = (UF.thinBorders and not E.global.tukuiMode) and E.mult or E.Border
	rdebuff.icon = rdebuff:CreateTexture(nil, 'OVERLAY')
	rdebuff.icon:SetTexCoord(unpack(E.TexCoords))
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
	local db = frame.db
	local rdebuffs = frame.RaidDebuffs
	local stackColor = db.rdebuffs.stack.color
	local durationColor = db.rdebuffs.duration.color

	if db.rdebuffs.enable then
		local rdebuffsFont = UF.LSM:Fetch("font", db.rdebuffs.font)
		if not frame:IsElementEnabled('RaidDebuffs') then
			frame:EnableElement('RaidDebuffs')
		end
		
		rdebuffs.showDispellableDebuff = db.rdebuffs.showDispellableDebuff
		rdebuffs.forceShow = frame.forceShowAuras
		rdebuffs:Size(db.rdebuffs.size)
		rdebuffs:Point('BOTTOM', frame, 'BOTTOM', db.rdebuffs.xOffset, db.rdebuffs.yOffset + frame.SPACING)

		rdebuffs.count:FontTemplate(rdebuffsFont, db.rdebuffs.fontSize, db.rdebuffs.fontOutline)
		rdebuffs.count:ClearAllPoints()
		rdebuffs.count:Point(db.rdebuffs.stack.position, db.rdebuffs.stack.xOffset, db.rdebuffs.stack.yOffset)
		rdebuffs.count:SetTextColor(stackColor.r, stackColor.g, stackColor.b)

		rdebuffs.time:FontTemplate(rdebuffsFont, db.rdebuffs.fontSize, db.rdebuffs.fontOutline)
		rdebuffs.time:ClearAllPoints()
		rdebuffs.time:Point(db.rdebuffs.duration.position, db.rdebuffs.duration.xOffset, db.rdebuffs.duration.yOffset)
		rdebuffs.time:SetTextColor(durationColor.r, durationColor.g, durationColor.b)
	elseif frame:IsElementEnabled('RaidDebuffs') then
		frame:DisableElement('RaidDebuffs')
		rdebuffs:Hide()
	end
end