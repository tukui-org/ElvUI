local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs, unpack = ipairs, unpack
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS, OrderHallCommandBar, OrderHallMissionFrame
-- GLOBALS: OrderHallMissionFrameMissions, OrderHallMissionFrameMissionsListScrollFrame
-- GLOBALS: OrderHallMissionFrameMissionsListScrollFrameScrollBar, OrderHallTalentFrame
-- GLOBALS: OrderHallMissionFrameFollowersListScrollFrameScrollBar, OrderHallMissionFrameFollowers
-- GLOBALS: ClassHallTalentInset, OrderHallTalentFrameCloseButton, AdventureMapQuestChoiceDialog

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

	local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

	-- CommandBar
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:SetTemplate("Transparent")
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:Hide()

	-- MissionFrame
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame:CreateBackdrop("Transparent")
	OrderHallMissionFrame.backdrop:SetOutside(OrderHallMissionFrame.BorderFrame)
	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)
	if E.wowbuild >= 23623 then --7.2
		S:HandleCloseButton(OrderHallMissionTutorialFrame.GlowBox.CloseButton)
	end

	for i = 1, 3 do
		S:HandleTab(_G["OrderHallMissionFrameTab" .. i])
	end

	for _, Button in pairs(OrderHallMissionFrame.MissionTab.MissionList.listScroll.buttons) do
		if not Button.isSkinned then
			Button:StripTextures()
			Button:SetTemplate()
			S:HandleButton(Button)
			Button:SetBackdropBorderColor(0, 0, 0, 0)
			Button.LocBG:Hide()
			Button.isSkinned = true
		end
	end

	-- Followers
	local FollowerList = OrderHallMissionFrame.FollowerList
	local FollowerTab = OrderHallMissionFrame.FollowerTab
	FollowerList:StripTextures()
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(OrderHallMissionFrame.FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, "ShowFollower", function(self)
		S:HandleFollowerPage(self, true)
	end)
	FollowerTab:StripTextures()
	FollowerTab.Class:SetSize(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E["media"].normTex)
	FollowerTab.XPBar:CreateBackdrop()

	-- Missions
	local MissionTab = OrderHallMissionFrame.MissionTab
	local MissionList = MissionTab.MissionList
	local MissionPage = MissionTab.MissionPage
	local ZoneSupportMissionPage = MissionTab.ZoneSupportMissionPage
	S:HandleScrollBar(MissionList.listScroll.scrollBar)
	MissionList.CompleteDialog:StripTextures()
	MissionList.CompleteDialog:SetTemplate("Transparent")
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	MissionList:StripTextures()
	MissionList.listScroll:StripTextures()
	S:HandleButton(OrderHallMissionFrameMissions.CombatAllyUI.InProgress.Unassign)
	S:HandleCloseButton(MissionPage.CloseButton)
	S:HandleButton(MissionPage.StartMissionButton)
	S:HandleCloseButton(ZoneSupportMissionPage.CloseButton)
	S:HandleButton(ZoneSupportMissionPage.StartMissionButton)
	S:HandleButton(OrderHallMissionFrame.MissionComplete.NextMissionButton)

	-- TalentFrame
	local TalentFrame = OrderHallTalentFrame
	TalentFrame:StripTextures()
	TalentFrame.LeftInset:StripTextures()
	TalentFrame:SetTemplate("Transparent")
	TalentFrame.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	S:HandleCloseButton(TalentFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI', "OrderHall", LoadSkin)
