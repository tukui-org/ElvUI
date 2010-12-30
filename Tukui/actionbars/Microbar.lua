if TukuiCF["actionbar"].enable ~= true or TukuiCF["actionbar"].microbar ~= true then return end

local microbuttons = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"QuestLogMicroButton",
	"MainMenuMicroButton",
	"PVPMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"HelpMicroButton",
	"AchievementMicroButton"
}

local f = CreateFrame("Frame", "MicroParent", UIParent)
MicroParent.shown = false
f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 1, -25) --Default microbar position
f:SetWidth(((CharacterMicroButton:GetWidth() + 4) * 7) + 2)
f:SetHeight(CharacterMicroButton:GetHeight() - 28)
if TukuiCF["actionbar"].mousemicro == true then f:SetAlpha(0) end

UpdateMicroButtonsParent(f)

local function CheckFade(self, elapsed)
	local mouseactive
	for i, button in pairs(microbuttons) do
		local b = _G[button]
		if b.mouseover == true then
			mouseactive = true
			if GameTooltip:IsShown() then
				GameTooltip:Hide()
			end
		end
	end
	
	if TukuiCF["actionbar"].mousemicro ~= true then return end
	
	if MicroPlaceHolder.mouseover == true then
		mouseactive = true
		if GameTooltip:IsShown() then
			GameTooltip:Hide()
		end
	end
	
	if mouseactive == true then
		if MicroParent.shown ~= true then
			UIFrameFadeIn(MicroParent, 0.2)
			MicroParent.shown = true
		end
	else
		if MicroParent.shown == true then
			UIFrameFadeOut(MicroParent, 0.2)
			MicroParent.shown = false
		end
	end
end
f:SetScript("OnUpdate", CheckFade)

for i, button in pairs(microbuttons) do
	local m = _G[button]
	local pushed = m:GetPushedTexture()
	local normal = m:GetNormalTexture()
	local disabled = m:GetDisabledTexture()
	
	m.SetParent = TukuiDB.dummy
	_G[button.."Flash"]:SetTexture("")
	m:SetHighlightTexture("")
	m.SetHighlightTexture = TukuiDB.dummy

	if i == 5 then
		TukuiDB.Kill(m)
	elseif i == 9 then
		m:ClearAllPoints()
		m:SetPoint("LEFT", LFDMicroButton, "RIGHT", -3, 0)
	end
	
	local f = CreateFrame("Frame", nil, m)
	f:SetFrameLevel(1)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint("BOTTOMLEFT", m, "BOTTOMLEFT", 2, 0)
	f:SetPoint("TOPRIGHT", m, "TOPRIGHT", -2, -28)
	TukuiDB.SetNormTexTemplate(f)
	m.frame = f
	
	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", m.frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	pushed:SetPoint("BOTTOMRIGHT", m.frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT", m.frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	normal:SetPoint("BOTTOMRIGHT", m.frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:ClearAllPoints()
		disabled:SetPoint("TOPLEFT", m.frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		disabled:SetPoint("BOTTOMRIGHT", m.frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	end
		

	m.mouseover = false
	m:HookScript("OnEnter", function(self) local color = RAID_CLASS_COLORS[TukuiDB.myclass] self.frame:SetBackdropBorderColor(color.r, color.g, color.b) self.mouseover = true end)
	m:HookScript("OnLeave", function(self) self.frame:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor)) self.mouseover = false end)
end

local x = CreateFrame("Frame", "MicroPlaceHolder", MicroParent)
x:SetPoint("TOPLEFT", CharacterMicroButton.frame, "TOPLEFT")
x:SetPoint("BOTTOMRIGHT", HelpMicroButton.frame, "BOTTOMRIGHT")
x:EnableMouse(true)
x.mouseover = false
TukuiDB.CreateShadow(x)
x:SetScript("OnEnter", function(self) self.mouseover = true end)
x:SetScript("OnLeave", function(self) self.mouseover = false end)


--Fix/Create textures for buttons
do
	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:SetPoint("TOPLEFT", CharacterMicroButton.frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	MicroButtonPortrait:SetPoint("BOTTOMRIGHT", CharacterMicroButton.frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	GuildMicroButtonTabard:ClearAllPoints()
	GuildMicroButtonTabard:SetPoint("TOP", GuildMicroButton.frame, "TOP", 0, 25)
	GuildMicroButtonTabard.SetPoint = TukuiDB.dummy
	GuildMicroButtonTabard.ClearAllPoints = TukuiDB.dummy
end


--Moving of the MicroBar
local f = CreateFrame("Frame", "MicroBar", UIParent)
f:SetFrameLevel(CharacterMicroButton:GetFrameLevel() + 1)
f:SetFrameStrata("FULLSCREEN_DIALOG")
f:SetPoint("BOTTOMLEFT", MicroParent, "BOTTOMLEFT", 0,  -58)
f:SetWidth(((CharacterMicroButton:GetWidth() + 4) * 7) + 2)
f:SetHeight(CharacterMicroButton:GetHeight() - 28)
f:SetBackdrop({
  bgFile = TukuiCF["media"].blank, 
  edgeFile = TukuiCF["media"].blank, 
  tile = false, tileSize = 0, edgeSize = 2, 
  insets = { left = 0, right = 0, top = 0, bottom = 0}
})	
f:SetBackdropBorderColor(0, 0, 0, 1)
f:SetBackdropColor(0, 1, 0, 0.75)
	
f:RegisterForDrag("LeftButton", "RightButton")
f:SetScript("OnDragStart", function(self) 
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	self:StartMoving() 
end)
f:SetScript("OnDragStop", function(self) 
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	self:StopMovingOrSizing() 
end)

f:SetAlpha(0)
f:SetMovable(true)
f:EnableMouse(false)
f.shown = false

CharacterMicroButton:ClearAllPoints()
CharacterMicroButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")

local fs = f:CreateFontString(nil, "OVERLAY")
fs:SetFont(TukuiCF["media"].font, TukuiCF["auras"].auratextscale, "THINOUTLINE")
fs:SetJustifyH("CENTER")
fs:SetShadowColor(0, 0, 0)
fs:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
fs:SetPoint("CENTER")
fs:SetText("MicroBar")


local function MoveMicro()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if MicroBar.shown == false then
		MicroBar.shown = true
		MicroBar:SetAlpha(1)
		MicroBar:EnableMouse(true)
	else
		MicroBar.shown = false
		MicroBar:SetAlpha(0)
		MicroBar:EnableMouse(false)	
	end
end
SLASH_MICRO1 = "/micro"
SlashCmdList["MICRO"] = MoveMicro