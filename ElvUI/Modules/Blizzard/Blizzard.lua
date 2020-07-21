local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')
local Skins = E:GetModule('Skins')

local _G = _G

local IsAddOnLoaded = IsAddOnLoaded

function B:Initialize()
	B.Initialized = true

	B:EnhanceColorPicker()
	B:KillBlizzard()
	B:AlertMovers()
	B:PositionCaptureBar()
	B:PositionDurabilityFrame()
	B:PositionGMFrames()
	B:SkinBlizzTimers()
	B:PositionVehicleFrame()
	B:PositionTalkingHead()
	B:Handle_LevelUpDisplay_BossBanner()
	B:Handle_UIWidgets()
	B:GarrisonDropDown()

	if not IsAddOnLoaded("DugisGuideViewerZ") then
		B:MoveObjectiveFrame()
	end

	if not IsAddOnLoaded("SimplePowerBar") then
		B:PositionAltPowerBar()
		B:SkinAltPowerBar()
	end

	E:CreateMover(_G.LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

	-- Quick Join Bug
	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if _G.LFRBrowseFrame.timeToClear then
			_G.LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- MicroButton Talent Alert
	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
	if TalentMicroButtonAlert then -- why do we need to check this?
		if E.global.general.showMissingTalentAlert then
			TalentMicroButtonAlert:ClearAllPoints()
			TalentMicroButtonAlert:Point("CENTER", E.UIParent, "TOP", 0, -75)
			TalentMicroButtonAlert:StripTextures()
			TalentMicroButtonAlert.Arrow:Hide()
			TalentMicroButtonAlert.Text:FontTemplate()
			TalentMicroButtonAlert:CreateBackdrop("Transparent")
			Skins:HandleCloseButton(TalentMicroButtonAlert.CloseButton)

			TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, "OVERLAY")
			TalentMicroButtonAlert.tex:Point("RIGHT", -10, 0)
			TalentMicroButtonAlert.tex:SetTexture([[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]])
			TalentMicroButtonAlert.tex:Size(32, 32)
		else
			TalentMicroButtonAlert:Kill() -- Kill it, because then the blizz default will show
		end
	end
end

E:RegisterModule(B:GetName())
