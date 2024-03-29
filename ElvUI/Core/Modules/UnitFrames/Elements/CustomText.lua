local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local pairs = pairs

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
	local font = LSM:Fetch('font', UF.db.font)

	for name, db in pairs(frameDB) do
		local object = customTexts[name]
		if not object then
			object = frame:CreateFontString(nil, 'OVERLAY')
			customTexts[name] = object -- reference it
		end

		local tagFont
		if db.font then
			tagFont = LSM:Fetch('font', db.font)
		end

		local attachPoint = UF:GetObjectAnchorPoint(frame, db.attachTextTo, db.attachTextTo == 'Power')
		object:ClearAllPoints()
		object:Point(db.justifyH or 'CENTER', attachPoint, db.justifyH or 'CENTER', db.xOffset, db.yOffset)
		object:FontTemplate(tagFont or font, db.size or UF.db.fontSize, db.fontOutline or UF.db.fontOutline)
		object:SetJustifyH(db.justifyH or 'CENTER')
		object:SetShown(db.enable)

		if db.attachTextTo == 'Power' and frame.Power then
			object:SetParent(frame.Power.RaisedElementParent)
		elseif db.attachTextTo == 'EclipseBar' and frame.EclipseBar then
			object:SetParent(frame.EclipseBar.RaisedElementParent)
		elseif db.attachTextTo == 'AdditionalPower' and frame.AdditionalPower then
			object:SetParent(frame.AdditionalPower.RaisedElementParent)
		elseif db.attachTextTo == 'InfoPanel' and frame.InfoPanel then
			object:SetParent(frame.InfoPanel)
		else
			object:SetParent(frame.RaisedElementParent)
		end

		-- This takes care of custom texts that were added before the enable option was added
		if db.enable == nil then
			db.enable = true
		end

		if db.enable then
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
