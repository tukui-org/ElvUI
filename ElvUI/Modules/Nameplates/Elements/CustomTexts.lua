local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

-- Lua functions
local pairs = pairs
-- WoW API / Variables

function NP:Configure_CustomTexts(nameplate)
	local db = NP.db.units[nameplate.frameType]

	--Make sure CustomTexts are hidden if they don't exist in current profile
	--nameplate.frameType = 'PLAYER'
	--nameplate.frameType = 'FRIENDLY_PLAYER'
	--nameplate.frameType = 'FRIENDLY_NPC'
	--nameplate.frameType = 'ENEMY_NPC'
	--nameplate.frameType = 'ENEMY_PLAYER'

	nameplate.customTexts = nameplate.customTexts or {}

	for objectName, object in pairs(nameplate.customTexts) do
		if (not db.customTexts) or (db.customTexts and not db.customTexts[objectName]) then
			object:Hide()
		end
	end

	if db.customTexts then
		local customFont = E.LSM:Fetch("font", NP.db.font)
		for objectName in pairs(db.customTexts) do
			if not nameplate.customTexts[objectName] then
				nameplate.customTexts[objectName] = nameplate.RaisedElement:CreateFontString(nil, 'OVERLAY')
			end

			local objectDB = db.customTexts[objectName]

			if objectDB.font then
				customFont = E.LSM:Fetch("font", objectDB.font)
			end

			local attachPoint = self:GetObjectAnchorPoint(nameplate, objectDB.attachTextTo)
			nameplate.customTexts[objectName]:FontTemplate(customFont, objectDB.size or NP.db.fontSize, objectDB.fontOutline or NP.db.fontOutline)
			nameplate.customTexts[objectName]:SetJustifyH(objectDB.justifyH or 'CENTER')
			nameplate.customTexts[objectName]:ClearAllPoints()
			nameplate.customTexts[objectName]:Point(objectDB.justifyH or 'CENTER', attachPoint, objectDB.justifyH or 'CENTER', objectDB.xOffset, objectDB.yOffset)

			--This takes care of custom texts that were added before the enable option was added.
			if objectDB.enable == nil then
				objectDB.enable = true
			end

			if objectDB.enable then
				nameplate:Tag(nameplate.customTexts[objectName], objectDB.text_format or '')
				nameplate.customTexts[objectName]:Show()
			else
				nameplate:Untag(nameplate.customTexts[objectName])
				nameplate.customTexts[objectName]:Hide()
			end
		end
	end
end
