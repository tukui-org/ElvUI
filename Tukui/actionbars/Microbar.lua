if TukuiCF["actionbar"].enable ~= true then return end

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
f:SetAlpha(0)
UpdateMicroButtonsParent(f)

local function CheckFade(self, elapsed)
	if(self.elapsed and self.elapsed > 0.2) then
		local mouseactive
		for i, button in pairs(microbuttons) do
			local b = _G[button]
			if b.mouseover == true then
				mouseactive = true
			end
		end
		
		if MicroPlaceHolder.mouseover == true then
			mouseactive = true
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
		
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end
f:SetScript("OnUpdate", CheckFade)

for i, button in pairs(microbuttons) do
	local m = _G[button]
	m.SetParent = TukuiDB.dummy
	_G[button.."Flash"]:SetTexture("")
	m:SetHighlightTexture("")
	m:SetPushedTexture("")
	m:SetNormalTexture("")	
	m:SetDisabledTexture("")
	m.SetDisabledTexture = TukuiDB.dummy
	m.SetPushedTexture = TukuiDB.dummy
	m.SetNormalTexture = TukuiDB.dummy
	m.SetHighlightTexture = TukuiDB.dummy
	
	if i == 1 then
		m:ClearAllPoints()
		m:SetPoint("TOP", UIParent, "TOP", -m:GetWidth()*4.5, 18)
		m.ClearAllPoints = TukuiDB.dummy
		m.SetPoint = TukuiDB.dummy
	elseif i == 5 then
		TukuiDB.Kill(m)
	elseif i == 9 then
		m:ClearAllPoints()
		m:SetPoint("LEFT", LFDMicroButton, "RIGHT", -3, 0)
	end
	
	local f = CreateFrame("Frame", nil, m)
	f:SetFrameLevel(1)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint("BOTTOMLEFT", m, "BOTTOMLEFT", 2, 0)
	f:SetPoint("TOPRIGHT", m, "TOPRIGHT", -2, -25)
	TukuiDB.SetNormTexTemplate(f)
	m.frame = f
		

	m.mouseover = false
	m:HookScript("OnEnter", function(self) local color = RAID_CLASS_COLORS[TukuiDB.myclass] self.frame:SetBackdropBorderColor(color.r, color.g, color.b) self.mouseover = true end)
	m:HookScript("OnLeave", function(self) self.frame:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor)) self.mouseover = false end)
end

local x = CreateFrame("Frame", "MicroPlaceHolder", MicroParent)
x:SetPoint("TOPLEFT", CharacterMicroButton, "TOPLEFT")
x:SetPoint("BOTTOMRIGHT", HelpMicroButton, "BOTTOMRIGHT")
x:EnableMouse(true)
x.mouseover = false
x:SetScript("OnEnter", function(self) self.mouseover = true end)
x:SetScript("OnLeave", function(self) self.mouseover = false end)

--Fix/Create textures for buttons
do
	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:SetPoint("TOPLEFT", CharacterMicroButton.frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	MicroButtonPortrait:SetPoint("BOTTOMRIGHT", CharacterMicroButton.frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	--Spellbook
	local sb = SpellbookMicroButton:CreateTexture(nil, "OVERLAY")
	sb:SetTexture([[Interface\Buttons\UI-MicroButton-Spellbook-Up]])
	sb:SetTexCoord(0.15, 0.85, 0.48, 0.923)
	sb:SetPoint("TOPLEFT", sb:GetParent().frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	sb:SetPoint("BOTTOMRIGHT", sb:GetParent().frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	--Talents
	local tal = TalentMicroButton:CreateTexture(nil, "OVERLAY")
	tal:SetTexture([[Interface\Buttons\UI-MicroButton-Talents-Up]])
	tal:SetTexCoord(0.15, 0.85, 0.48, 0.923)
	tal:SetPoint("TOPLEFT", tal:GetParent().frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	tal:SetPoint("BOTTOMRIGHT", tal:GetParent().frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	--Achievements
	local ach = AchievementMicroButton:CreateTexture(nil, "OVERLAY")
	ach:SetTexture([[Interface\Buttons\UI-MicroButton-Achievement-Up]])
	ach:SetTexCoord(0.15, 0.85, 0.48, 0.923)
	ach:SetPoint("TOPLEFT", ach:GetParent().frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	ach:SetPoint("BOTTOMRIGHT", ach:GetParent().frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	--Quests
	local que = QuestLogMicroButton:CreateTexture(nil, "OVERLAY")
	que:SetTexture([[Interface\Buttons\UI-MicroButton-Quest-Up]])
	que:SetTexCoord(0.15, 0.85, 0.48, 0.923)
	que:SetPoint("TOPLEFT", que:GetParent().frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	que:SetPoint("BOTTOMRIGHT", que:GetParent().frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	--LFG
	local lfg = LFDMicroButton:CreateTexture(nil, "OVERLAY")
	lfg:SetTexture([[Interface\Buttons\UI-MicroButton-LFG-Up]])
	lfg:SetTexCoord(0.15, 0.85, 0.48, 0.923)
	lfg:SetPoint("TOPLEFT", lfg:GetParent().frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	lfg:SetPoint("BOTTOMRIGHT", lfg:GetParent().frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	
	--Help
	local help = HelpMicroButton:CreateTexture(nil, "OVERLAY")
	help:SetTexture([[Interface\Buttons\UI-MicroButton-Help-Up]])
	help:SetTexCoord(0.15, 0.85, 0.48, 0.923)
	help:SetPoint("TOPLEFT", help:GetParent().frame, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	help:SetPoint("BOTTOMRIGHT", help:GetParent().frame, "BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
end