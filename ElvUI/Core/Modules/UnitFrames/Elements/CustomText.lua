local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local pairs = pairs

UF.CustomTextAttachState = {
	Power			= 2, -- two means can fallback
	InfoPanel		= 2, -- no raised element parent
	EnergyManaRegen	= E.Classic and 1 or 0,
	EclipseBar		= E.Mists and 1 or 0,
	AdditionalPower	= E.Mists and 1 or 0,
	Stagger			= E.Mists and 1 or 0
}

function UF:Configure_CustomTexts(frame)
	local customTexts = frame.customTexts
	if not customTexts then return end

	-- Make sure CustomTexts are hidden if they don't exist in current profile
	local frameDB = frame.db.customTexts
	for name, object in pairs(customTexts) do
		if not frameDB or not frameDB[name] then
			object:Hide()
		end
	end

	if not frameDB then return end
	local mainFont = LSM:Fetch('font', UF.db.font)

	for name, db in pairs(frameDB) do
		local object = customTexts[name]
		if not object then
			object = frame:CreateFontString(nil, 'OVERLAY')
			customTexts[name] = object -- reference it
		end

		local tagFont = (db.font and LSM:Fetch('font', db.font)) or mainFont
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.attachTextTo, db.attachTextTo == 'Power')
		object:ClearAllPoints()
		object:Point(db.justifyH or 'CENTER', attachPoint, db.justifyH or 'CENTER', db.xOffset, db.yOffset)
		object:FontTemplate(tagFont, db.size or UF.db.fontSize, db.fontOutline or UF.db.fontOutline)
		object:SetJustifyH(db.justifyH or 'CENTER')
		object:SetShown(db.enable)

		local state = UF.CustomTextAttachState[db.attachTextTo]
		local anchor = (state and frame[db.attachTextTo]) or (state == 2 and frame)
		object:SetParent((not anchor and E.HiddenFrame) or anchor.RaisedElementParent or anchor)

		-- This takes care of custom texts that were added before the enable option was added
		if db.enable == nil then
			db.enable = true
		end

		-- Require an anchor otherwise untag as its hidden
		if anchor and db.enable then
			frame:Tag(object, db.text_format or '')
		else
			frame:Untag(object)
		end
	end
end

function UF:ToggleVisibility_CustomTexts(frame, show)
	local customTexts = frame.customTexts
	if not customTexts then return end

	local frameDB = frame.db.customTexts
	if not frameDB then return end

	for name, db in pairs(frameDB) do
		local object = customTexts[name]
		if object then
			object:SetShown(show and db.enable)
		end
	end
end
