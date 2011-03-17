local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales

if C.unitframes.enable ~= true or C.unitframes.combatfeedback ~= true then return end
local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local damage_format = "-%d"
local heal_format = "+%d"
local maxAlpha = 0.6
local updateFrame
local feedback = {}
local originalHeight = {}
local color 
local colors = {
	STANDARD		= { 1, 1, 1 }, -- color for everything not in the list below
	-- damage colors
	IMMUNE			= { 1, 1, 1 },
	DAMAGE			= { 1, 0, 0 },
	CRUSHING		= { 1, 0, 0 },
	CRITICAL		= { 1, 0, 0 },
	GLANCING		= { 1, 0, 0 },
	ABSORB			= { 1, 1, 1 },
	BLOCK			= { 1, 1, 1 },
	RESIST			= { 1, 1, 1 },
	MISS			= { 1, 1, 1 },
	-- heal colors
	HEAL			= { 0, 1, 0 },
	CRITHEAL		= { 0, 1, 0 },
	-- energize colors
	ENERGIZE		= { 0.41, 0.8, 0.94 },
	CRITENERGIZE	= { 0.41, 0.8, 0.94 },
}

local function createUpdateFrame()
	if updateFrame then return end
	updateFrame = CreateFrame("Frame")
	updateFrame:Hide()
	updateFrame:SetScript("OnUpdate", function()
		if next(feedback) == nil then
			updateFrame:Hide()
			return
		end
		for object, startTime in pairs(feedback) do
			local maxalpha = object.CombatFeedbackText.maxAlpha
			local elapsedTime = GetTime() - startTime
			if ( elapsedTime < COMBATFEEDBACK_FADEINTIME ) then
				local alpha = maxalpha*(elapsedTime / COMBATFEEDBACK_FADEINTIME)
				object.CombatFeedbackText:SetAlpha(alpha)
			elseif ( elapsedTime < (COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME) ) then
				object.CombatFeedbackText:SetAlpha(maxalpha)
			elseif ( elapsedTime < (COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME + COMBATFEEDBACK_FADEOUTTIME) ) then
				local alpha = maxalpha - maxalpha*((elapsedTime - COMBATFEEDBACK_HOLDTIME - COMBATFEEDBACK_FADEINTIME) / COMBATFEEDBACK_FADEOUTTIME)
				object.CombatFeedbackText:SetAlpha(alpha)
			else
				object.CombatFeedbackText:Hide()
				feedback[object] = nil
			end
		end		
	end)
end


local function combat(self, event, unit, eventType, flags, amount, dtype)
	if unit ~= self.unit then return end
	if unit == "vehicle" then return end
	local FeedbackText = self.CombatFeedbackText
	local fColors = FeedbackText.colors
	local font, fontHeight, fontFlags = FeedbackText:GetFont()
	fontHeight = FeedbackText.origHeight -- always start at original height
	local text, arg
	color = fColors and fColors.STANDARD or colors.STANDARD
	if eventType == "IMMUNE" and not FeedbackText.ignoreImmune then
		color = fColors and fColors.IMMUNE or colors.IMMUNE
		fontHeight = fontHeight * 0.75
		text = CombatFeedbackText[eventType]
	elseif eventType == "WOUND" and not FeedbackText.ignoreDamage then
		if amount ~= 0 then
			if flags == "CRITICAL" then
				color = fColors and fColors.CRITICAL or colors.CRITICAL
				fontHeight = fontHeight * 1.5
			elseif  flags == "CRUSHING" then
				color = fColors and fColors.CRUSING or colors.CRUSHING
				fontHeight = fontHeight * 1.5
			elseif flags == "GLANCING" then
				color = fColors and fColors.GLANCING or colors.GLANCING
				fontHeight = fontHeight * 0.75
			else
				color = fColors and fColors.DAMAGE or colors.DAMAGE
			end
			text = damage_format
			arg = amount
		elseif flags == "ABSORB" then
			color = fColors and fColors.ABSORB or colors.ABSORB
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["ABSORB"]
		elseif flags == "BLOCK" then
			color = fColors and fColors.BLOCK or colors.BLOCK
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["BLOCK"]
		elseif flags == "RESIST" then
			color = fColors and fColors.RESIST or colors.RESIST
			fontHeight = fontHeight * 0.75
			text = CombatFeedbackText["RESIST"]
		else
			color = fColors and fColors.MISS or colors.MISS
			text = CombatFeedbackText["MISS"]
		end
	elseif eventType == "BLOCK" and not FeedbackText.ignoreDamage then
		color = fColors and fColors.BLOCK or colors.BLOCK
		fontHeight = fontHeight * 0.75
		text = CombatFeedbackText[eventType]
	elseif eventType == "HEAL" and not FeedbackText.ignoreHeal then
		text = heal_format
		arg = amount
		if flags == "CRITICAL" then
			color = fColors and fColors.CRITHEAL or colors.CRITHEAL
			fontHeight = fontHeight * 1.3
		else
			color = fColors and fColors.HEAL or colors.HEAL
		end
	elseif event == "ENERGIZE" and not FeedbackText.ignoreEnergize then
		text = amount
		if flags == "CRITICAL" then
			color = fColors and fColors.ENERGIZE or colors.ENERGIZE
			fontHeight = fontHeight * 1.3
		else
			color = fColors and fColors.CRITENERGIZE or colors.CRITENERGIZE
		end
	elseif not FeedbackText.ignoreOther then
		text = CombatFeedbackText[eventType]
	end

	if text then
		FeedbackText:SetFont(font,fontHeight,fontFlags)
		FeedbackText:SetFormattedText(text, arg)
		FeedbackText:SetTextColor(unpack(color))
		FeedbackText:SetAlpha(0)
		FeedbackText:Show()
		feedback[self] = GetTime()
		updateFrame:Show() -- start our onupdate
	end
end

local function addCombat(object)
	if not object.CombatFeedbackText then return end
	-- store the original starting height
	local font, fontHeight, fontFlags = object.CombatFeedbackText:GetFont()
	object.CombatFeedbackText.origHeight = fontHeight
	object.CombatFeedbackText.maxAlpha = object.CombatFeedbackText.maxAlpha or maxAlpha
	createUpdateFrame()
	object:RegisterEvent("UNIT_COMBAT", combat)
end

for k, object in ipairs(oUF.objects) do addCombat(object) end
oUF:RegisterInitCallback(addCombat)
