local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule('Blizzard', 'AceEvent-3.0', 'AceHook-3.0');
E.Blizzard = B;

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: IsAddOnLoaded, LossOfControlFrame, CreateFrame, LFRBrowseFrame, TalentMicroButtonAlert

function B:Initialize()
	self:EnhanceColorPicker()
	self:KillBlizzard()
	self:AlertMovers()
	self:PositionCaptureBar()
	self:PositionDurabilityFrame()
	self:PositionGMFrames()
	self:SkinBlizzTimers()
	self:PositionVehicleFrame()
	self:PositionTalkingHead()
	self:Handle_LevelUpDisplay_BossBanner()
	self:Handle_UIWidgets()
	self:GarrisonDropDown()

	if not IsAddOnLoaded("DugisGuideViewerZ") then
		self:MoveObjectiveFrame()
	end

	if not IsAddOnLoaded("SimplePowerBar") then
		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end

	E:CreateMover(LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

	-- Quick Join Bug
	CreateFrame("Frame"):SetScript("OnUpdate", function(self)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- Fix Guild Set Rank Error introduced in Patch 27326
	GuildControlUIRankSettingsFrameRosterLabel = CreateFrame("Frame", nil, E.HiddenFrame)

	-- MicroButton Talent Alert
	if TalentMicroButtonAlert then -- why do we need to check this?
		if E.global.general.showMissingTalentAlert then
			TalentMicroButtonAlert:ClearAllPoints()
			TalentMicroButtonAlert:SetPoint("CENTER", E.UIParent, "TOP", 0, -75)
			TalentMicroButtonAlert:StripTextures()
			TalentMicroButtonAlert.Arrow:Hide()
			TalentMicroButtonAlert.Text:FontTemplate()
			TalentMicroButtonAlert:CreateBackdrop("Transparent")
			E:GetModule("Skins"):HandleCloseButton(TalentMicroButtonAlert.CloseButton)

			TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, "OVERLAY")
			TalentMicroButtonAlert.tex:Point("RIGHT", -10, 0)
			TalentMicroButtonAlert.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
			TalentMicroButtonAlert.tex:SetSize(32, 32)
		else
			TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
		end
	end
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)
