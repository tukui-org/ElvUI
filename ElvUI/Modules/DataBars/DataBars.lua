local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DB = E:GetModule('DataBars')

local _G = _G
local CreateFrame = CreateFrame
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
-- GLOBALS: ElvUI_ExperienceBar, ElvUI_ReputationBar, ElvUI_ArtifactBar, ElvUI_HonorBar, ElvUI_AzeriteBar

function DB:OnLeave()
	if (self == ElvUI_ExperienceBar and DB.db.experience.mouseover) or (self == ElvUI_ReputationBar and DB.db.reputation.mouseover) or (self == ElvUI_ArtifactBar and DB.db.artifact.mouseover) or (self == ElvUI_HonorBar and DB.db.honor.mouseover) or (self == ElvUI_AzeriteBar and DB.db.azerite.mouseover) then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0)
	end

	_G.GameTooltip:Hide()
end

function DB:CreateBar(name, onEnter, onClick, ...)
	local bar = CreateFrame('Button', name, E.UIParent)
	bar:SetPoint(...)
	bar:SetScript('OnEnter', onEnter)
	bar:SetScript('OnLeave', DB.OnLeave)
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
	bar.text:SetPoint('CENTER')

	E.FrameLocks[name] = true

	return bar
end

function DB:UpdateDataBarDimensions()
	DB:UpdateExperienceDimensions()
	DB:UpdateReputationDimensions()
	--self:UpdateArtifactDimensions()
	DB:UpdateHonorDimensions()
	DB:UpdateAzeriteDimensions()
end

function DB:PLAYER_LEVEL_UP(level)
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if (level ~= maxLevel or not self.db.experience.hideAtMaxLevel) and DB.db.experience.enable then
		DB:UpdateExperience('PLAYER_LEVEL_UP', level)
	else
		self.expBar:Hide()
	end

	if(self.db.honor.enable) then
		DB:UpdateHonor('PLAYER_LEVEL_UP', level)
	else
		self.honorBar:Hide()
	end
end

function DB:Initialize()
	DB.Initialized = true
	DB.db = E.db.databars

	DB:LoadExperienceBar()
	DB:LoadReputationBar()
	DB:LoadHonorBar()
	--DB:LoadArtifactBar()
	DB:LoadAzeriteBar()

	DB:RegisterEvent('PLAYER_LEVEL_UP')
end

E:RegisterModule(DB:GetName())
