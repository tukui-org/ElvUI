local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if C["actionbar"].enable ~= true or C["actionbar"].microbar ~= true then return end

local microbuttons = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"QuestLogMicroButton",
	"PVPMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"EJMicroButton",
	"RaidMicroButton",
	"HelpMicroButton",
	"MainMenuMicroButton",
	"AchievementMicroButton"
}

local f = CreateFrame("Frame", "MicroParent", E.UIParent)
MicroParent.shown = false
if C["actionbar"].mousemicro == true then f:SetAlpha(0) end

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
	
	if C["actionbar"].mousemicro ~= true then return end
	
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
	
	m:SetParent(MicroParent)
	m.SetParent = E.dummy
	_G[button.."Flash"]:SetTexture("")
	m:SetHighlightTexture("")
	m.SetHighlightTexture = E.dummy

	local f = CreateFrame("Frame", nil, m)
	f:SetFrameLevel(1)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint("BOTTOMLEFT", m, "BOTTOMLEFT", 2, 0)
	f:SetPoint("TOPRIGHT", m, "TOPRIGHT", -2, -28)
	f:SetTemplate("Default", true)
	m.frame = f
	
	pushed:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", m.frame, "TOPLEFT", E.Scale(2), E.Scale(-2))
	pushed:SetPoint("BOTTOMRIGHT", m.frame, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
	
	normal:SetTexCoord(0.17, 0.87, 0.5, 0.908)
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT", m.frame, "TOPLEFT", E.Scale(2), E.Scale(-2))
	normal:SetPoint("BOTTOMRIGHT", m.frame, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
	
	if disabled then
		disabled:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		disabled:ClearAllPoints()
		disabled:SetPoint("TOPLEFT", m.frame, "TOPLEFT", E.Scale(2), E.Scale(-2))
		disabled:SetPoint("BOTTOMRIGHT", m.frame, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
	end
		

	m.mouseover = false
	m:HookScript("OnEnter", function(self) 
		if C["general"].classcolortheme == true then 
			self.frame:SetBackdropBorderColor(unpack(C["media"].bordercolor)) 
		else
			self.frame:SetBackdropBorderColor(unpack(C["media"].valuecolor)) 
		end self.mouseover = true 
	end)
	m:HookScript("OnLeave", function(self) 
		local color = RAID_CLASS_COLORS[E.myclass] 
		if C["general"].classcolortheme ~= true then 
			self.frame:SetBackdropBorderColor(unpack(C["media"].bordercolor)) 
		else
			self.frame:SetBackdropBorderColor(color.r, color.g, color.b) 
		end
		self.mouseover = false 
	end)
end

local x = CreateFrame("Frame", "MicroPlaceHolder", MicroParent)
x:SetPoint("TOPLEFT", CharacterMicroButton.frame, "TOPLEFT")
x:SetPoint("BOTTOMRIGHT", HelpMicroButton.frame, "BOTTOMRIGHT")
x:EnableMouse(true)
x.mouseover = false
x:CreateShadow("Default")
x:SetScript("OnEnter", function(self) self.mouseover = true end)
x:SetScript("OnLeave", function(self) self.mouseover = false end)


--Fix/Create textures for buttons
do
	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:SetPoint("TOPLEFT", CharacterMicroButton.frame, "TOPLEFT", E.Scale(2), E.Scale(-2))
	MicroButtonPortrait:SetPoint("BOTTOMRIGHT", CharacterMicroButton.frame, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
	
	GuildMicroButtonTabard:ClearAllPoints()
	GuildMicroButtonTabard:SetPoint("TOP", GuildMicroButton.frame, "TOP", 0, 25)
	GuildMicroButtonTabard.SetPoint = E.dummy
	GuildMicroButtonTabard.ClearAllPoints = E.dummy
end

MicroParent:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", 2, -2) --Default microbar position

MicroParent:SetWidth(((CharacterMicroButton:GetWidth() + 4) * 9) + 12)
MicroParent:SetHeight(CharacterMicroButton:GetHeight() - 28)

CharacterMicroButton:ClearAllPoints()
CharacterMicroButton:SetPoint("BOTTOMLEFT", MicroParent, "BOTTOMLEFT", 0,  0)
CharacterMicroButton.SetPoint = E.dummy
CharacterMicroButton.ClearAllPoints = E.dummy


E.CreateMover(MicroParent, "MicroMover", "MicroBar")