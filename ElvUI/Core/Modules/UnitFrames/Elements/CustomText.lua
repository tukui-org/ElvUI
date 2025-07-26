local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local pairs = pairs

-- avoid indicator icons being below the text
UF.CustomTextForceFallback = {
	Health = true
}

-- these need to be hidden; remove the fallback
UF.CustomTextAvoidFallback = {
	EnergyManaRegen	= E.Classic,
	EclipseBar		= E.Mists,
	AdditionalPower	= E.Mists,
	Stagger			= E.Mists
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

		local horizontal = db.justifyH or 'CENTER'
		local tagFont = (db.font and LSM:Fetch('font', db.font)) or mainFont
		local attachPoint = UF:GetObjectAnchorPoint(frame, db.attachTextTo, db.attachTextTo == 'Power')
		object:ClearAllPoints()
		object:Point(horizontal, attachPoint, horizontal, db.xOffset, db.yOffset)
		object:FontTemplate(tagFont, db.size or UF.db.fontSize, db.fontOutline or UF.db.fontOutline)
		object:SetJustifyH(horizontal)
		object:SetShown(db.enable)

		local forceFallback = UF.CustomTextForceFallback[db.attachTextTo]
		local avoidFallback = UF.CustomTextAvoidFallback[db.attachTextTo]
		local anchor = (forceFallback and frame) or frame[db.attachTextTo] or (not avoidFallback and frame)
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
