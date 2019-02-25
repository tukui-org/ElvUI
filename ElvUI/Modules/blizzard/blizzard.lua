local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:NewModule('Blizzard', 'AceEvent-3.0', 'AceHook-3.0');
E.Blizzard = B --Deprecated, start using E:GetModule("Blizzard") for a reference to this module

local _G = _G
local select = select
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local hooksecurefunc = hooksecurefunc

local function OnMouseDown(self, button)
	local string = self.Text:GetText()
	if button == "RightButton" then
		E:GetModule("Chat"):SetChatEditBoxMessage(string)
	elseif button == "MiddleButton" then
		local rawData = self:GetParent():GetAttributeData().rawValue

		if rawData.GetObjectType and rawData:GetObjectType() == "Texture" then
			_G.TEX = rawData
			E:Print("_G.TEX set to: ", string)
		else
			_G.FRAME = rawData
			E:Print("_G.FRAME set to: ", string)
		end
	else
		_G.TableAttributeDisplayValueButton_OnMouseDown(self)
	end
end

local function UpdateLines()
	for i=1, _G.TableAttributeDisplay.LinesScrollFrame.LinesContainer:GetNumChildren() do
		local child = select(i, _G.TableAttributeDisplay.LinesScrollFrame.LinesContainer:GetChildren())
		if child.ValueButton and child.ValueButton:GetScript("OnMouseDown") ~= OnMouseDown then
			child.ValueButton:SetScript("OnMouseDown", OnMouseDown)
		end
	end
end

function B:ADDON_LOADED()
	local debugTools = IsAddOnLoaded("Blizzard_DebugTools")
	if not debugTools and not self.Registered then
		self:RegisterEvent("ADDON_LOADED")
		self.Registered = true
	elseif debugTools then
		hooksecurefunc(_G.TableAttributeDisplay.dataProviders[2], "RefreshData", UpdateLines)

		self:UnregisterEvent("ADDON_LOADED")
		self.Registered = nil
	end
end

function B:Initialize()
	E.Blizzard = B

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

	E:CreateMover(_G.LossOfControlFrame, 'LossControlMover', L["Loss Control Icon"])

	-- Quick Join Bug
	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if _G.LFRBrowseFrame.timeToClear then
			_G.LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- Fix Guild Set Rank Error introduced in Patch 27326
	_G.GuildControlUIRankSettingsFrameRosterLabel = CreateFrame("Frame", nil, E.HiddenFrame)

	-- MicroButton Talent Alert
	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
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

	self:ADDON_LOADED()
end

local function InitializeCallback()
	B:Initialize()
end

E:RegisterModule(B:GetName(), InitializeCallback)
