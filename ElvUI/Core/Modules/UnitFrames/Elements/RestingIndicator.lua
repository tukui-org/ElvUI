local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local C_Timer_NewTimer = C_Timer.NewTimer
local IsResting = IsResting

local DEFAULT = [[Interface\CharacterFrame\UI-StateIcon]]

function UF:Construct_RestingIndicator(frame)
	local icon = frame.RaisedElementParent.TextureParent:CreateTexture(nil, 'OVERLAY')
	icon.PostUpdate = UF.RestingIndicator_PostUpdate

	return icon
end

local function ShouldHide(frame)
	return frame.db.RestIcon.hideAtMaxLevel and E:XPIsLevelMax()
end

local TestingTimer, TestingFrame
local function TestingFunc()
	if TestingFrame and not IsResting() then
		TestingFrame:Hide()
	end
end

function UF:TestingDisplay_RestingIndicator(frame)
	local icon = frame.RestingIndicator
	local db = frame.db.RestIcon

	if TestingTimer then
		TestingTimer:Cancel()
	end

	if not db.enable or ShouldHide(frame) then
		icon:Hide()
		return
	end

	icon:Show()

	TestingFrame = icon
	TestingTimer = C_Timer_NewTimer(10, TestingFunc)
end

function UF:Configure_RestingIndicator(frame)
	local db = frame.db and frame.db.RestIcon
	if db and db.enable then
		if not frame:IsElementEnabled('RestingIndicator') then
			frame:EnableElement('RestingIndicator')
		end

		local icon = frame.RestingIndicator
		if db.defaultColor then
			icon:SetVertexColor(1, 1, 1, 1)
			icon:SetDesaturated(false)
		else
			icon:SetVertexColor(db.color.r, db.color.g, db.color.b, db.color.a)
			icon:SetDesaturated(true)
		end

		if db.texture == 'CUSTOM' and db.customTexture then
			icon:SetTexture(db.customTexture)
			icon:SetTexCoord(0, 1, 0, 1)
		elseif db.texture ~= 'DEFAULT' and E.Media.RestIcons[db.texture] then
			icon:SetTexture(E.Media.RestIcons[db.texture])
			icon:SetTexCoord(0, 1, 0, 1)
		else
			icon:SetTexture(DEFAULT)
			icon:SetTexCoord(0, .5, 0, .421875)
		end

		icon:Size(db.size)
		icon:ClearAllPoints()

		if frame.ORIENTATION ~= 'RIGHT' and (frame.USE_PORTRAIT and not frame.USE_PORTRAIT_OVERLAY) then
			icon:Point('CENTER', frame.Portrait, db.anchorPoint, db.xOffset, db.yOffset)
		else
			icon:Point('CENTER', frame.Health, db.anchorPoint, db.xOffset, db.yOffset)
		end
	elseif frame:IsElementEnabled('RestingIndicator') then
		frame:DisableElement('RestingIndicator')
	end
end

function UF:RestingIndicator_PostUpdate()
	if self:IsShown() and ShouldHide(self.__owner) then
		self:Hide()
	end
end
