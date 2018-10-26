local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:NewModule("DataBars", 'AceEvent-3.0')
E.DataBars = mod

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUI_ExperienceBar, ElvUI_ReputationBar, ElvUI_ArtifactBar, ElvUI_HonorBar, ElvUI_AzeriteBar,
-- GLOBALS: GameTooltip

function mod:OnLeave()
	if (self == ElvUI_ExperienceBar and mod.db.experience.mouseover) or (self == ElvUI_ReputationBar and mod.db.reputation.mouseover) or (self == ElvUI_ArtifactBar and mod.db.artifact.mouseover) or (self == ElvUI_HonorBar and mod.db.honor.mouseover) or (self == ElvUI_AzeriteBar and mod.db.azerite.mouseover) then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end
	GameTooltip:Hide()
end

function mod:CreateBar(name, onEnter, onClick, ...)
	local bar = CreateFrame('Button', name, E.UIParent)
	bar:Point(...)
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', mod.OnLeave)
	bar:SetScript('OnMouseDown', onClick)
	bar:SetFrameStrata('LOW')
	bar:SetTemplate('Transparent')
	bar:Hide()

	bar.statusBar = CreateFrame('StatusBar', nil, bar)
	bar.statusBar:SetInside()
	bar.statusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar.statusBar)
	bar.text = bar.statusBar:CreateFontString(nil, 'OVERLAY')
	bar.text:FontTemplate()
	bar.text:Point('CENTER')

	E.FrameLocks[name] = true

	return bar
end

function mod:UpdateDataBarDimensions()
	self:UpdateExperienceDimensions()
	self:UpdateReputationDimensions()
	--self:UpdateArtifactDimensions()
	self:UpdateHonorDimensions()
	self:UpdateAzeriteDimensions()
end

function mod:PLAYER_LEVEL_UP(level)
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()];
	if (level ~= maxLevel or not self.db.experience.hideAtMaxLevel) and self.db.experience.enable then
		self:UpdateExperience("PLAYER_LEVEL_UP", level)
	else
		self.expBar:Hide()
	end

	if(self.db.honor.enable) then
		self:UpdateHonor("PLAYER_LEVEL_UP", level)
	else
		self.honorBar:Hide()
	end
end

function mod:Initialize()
	self.db = E.db.databars

	self:LoadExperienceBar()
	self:LoadReputationBar()
	self:LoadHonorBar()
	--self:LoadArtifactBar()
	self:LoadAzeriteBar()

	self:RegisterEvent("PLAYER_LEVEL_UP")
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)
