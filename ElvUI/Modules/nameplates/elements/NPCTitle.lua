local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UIParent, ElvUI_NPCTitleTextLeft2

local tooltip = CreateFrame("GameTooltip", "ElvUI_NPCTitle", UIParent, "GameTooltipTemplate")
tooltip:SetPoint("CENTER")
tooltip:SetSize(200, 200)
GameTooltip_SetDefaultAnchor(tooltip, UIParent)

function mod:UpdateElement_NPCTitle(frame, triggered)
	if self.db.showNPCTitles and not UnitIsPlayer(frame.unit) and not UnitPlayerControlled(frame.unit) and (triggered or (not self.db.units[frame.UnitType].healthbar.enable and (not self.db.alwaysShowTargetHealth or not UnitIsUnit("target", frame.unit)))) then
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		tooltip:SetUnit(frame.unit)
		tooltip:Show()

		local title = ElvUI_NPCTitleTextLeft2:GetText();
		tooltip:Hide()
		if not title or title:find('^Level ') then return end

		frame.NPCTitle:SetText(title)
		local reactionType = UnitReaction(frame.unit, "player")
		local r, g, b
		if(reactionType == 4) then
			r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
		elseif(reactionType > 4) then
			r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
		else
			r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
		end

		frame.NPCTitle:SetTextColor(r - 0.1, g - 0.1, b - 0.1)

		if self.db.nameColoredGlow then
			frame.NPCTitle.NameOnlyGlow:SetVertexColor(r, g, b, 1)
		else
			frame.NPCTitle.NameOnlyGlow:SetVertexColor(self.db.glowColor.r, self.db.glowColor.g, self.db.glowColor.b, self.db.glowColor.a)
		end
	else
		frame.NPCTitle:SetText("")
	end
end

function mod:ConfigureElement_NPCTitle(frame)
	local title = frame.NPCTitle

	title:SetJustifyH("CENTER")
	title:SetPoint("TOP", frame.Name, "BOTTOM", 0, -2)

	title:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_NPCTitle(frame)
	local title = frame:CreateFontString(nil, "OVERLAY")

	local g = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	g:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark.tga]])
	g:SetVertexColor(1, 1, 1, .3)
	g:Hide()
	g:SetPoint("TOPLEFT", title, -20, 8)
	g:SetPoint("BOTTOMRIGHT", title, 20, -8)

	title.NameOnlyGlow = g

	return title
end
