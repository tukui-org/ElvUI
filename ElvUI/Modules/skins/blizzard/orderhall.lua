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
	-- maybe we should kill the WorldMapButton, it looks ugly as fuck and dont know why blizz adds it there
	OrderHallCommandBar.WorldMapButton:ClearAllPoints()
	OrderHallCommandBar.WorldMapButton:SetPoint("RIGHT", OrderHallCommandBar, -5, -2)

	-- MissionFrame
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame:CreateBackdrop("Transparent")
	OrderHallMissionFrame.backdrop:SetOutside(OrderHallMissionFrame.BorderFrame)

	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)

	for i = 1, 3 do 
		S:HandleTab(_G["OrderHallMissionFrameTab" .. i])
	end

	OrderHallMissionFrameMissions:StripTextures()
	OrderHallMissionFrameMissionsListScrollFrame:StripTextures()
	OrderHallMissionFrame.MissionTab:StripTextures()

	S:HandleScrollBar(OrderHallMissionFrameMissionsListScrollFrameScrollBar)
	S:HandleButton(OrderHallMissionFrameMissions.CombatAllyUI.InProgress.Unassign)
	S:HandleCloseButton(OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage.CloseButton)
	S:HandleButton(OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage.StartMissionButton)

	for i, v in ipairs(OrderHallMissionFrame.MissionTab.MissionList.listScroll.buttons) do
		local Button = _G["OrderHallMissionFrameMissionsListScrollFrameButton" .. i]
		if Button and not Button.skinned then
			Button:StripTextures()
			Button:SetTemplate()
			S:HandleButton(Button)
			Button:SetBackdropBorderColor(0, 0, 0, 0)
			Button.LocBG:Hide()
			for i = 1, #Button.Rewards do
				local Texture = Button.Rewards[i].Icon:GetTexture()

				Button.Rewards[i]:StripTextures()
				S:HandleButton(Button.Rewards[i])
				Button.Rewards[i]:CreateBackdrop()
				Button.Rewards[i].Icon:SetTexture(Texture)
				Button.Rewards[i].backdrop:ClearAllPoints()
				Button.Rewards[i].backdrop:SetOutside(Button.Rewards[i].Icon)
				Button.Rewards[i].Icon:SetTexCoord(unpack(E.TexCoords))
			end
			Button.isSkinned = true
		end
	end

	-- Mission Tab
	local follower = OrderHallMissionFrameFollowers
	follower:StripTextures()
	follower.MaterialFrame:StripTextures()

	S:HandleEditBox(follower.SearchBox)
	S:HandleCloseButton(OrderHallMissionFrame.MissionTab.MissionPage.CloseButton)
	S:HandleButton(OrderHallMissionFrame.MissionTab.MissionPage.StartMissionButton)
	S:HandleScrollBar(OrderHallMissionFrameFollowersListScrollFrameScrollBar)

	-- Follower Tab
	local followerList = OrderHallMissionFrame.FollowerTab
	followerList:StripTextures()
	followerList.ModelCluster:StripTextures()
	followerList.Class:SetSize(50, 43)
	followerList.XPBar:StripTextures()
	followerList.XPBar:SetStatusBarTexture(E["media"].normTex)
	followerList.XPBar:CreateBackdrop()

	-- Mission Stage
	local mission = OrderHallMissionFrameMissions
	mission.CompleteDialog:StripTextures()
	mission.CompleteDialog:SetTemplate("Transparent")

	S:HandleButton(mission.CompleteDialog.BorderFrame.ViewButton)
	S:HandleButton(OrderHallMissionFrame.MissionComplete.NextMissionButton)

	-- TalentFrame
	OrderHallTalentFrame:StripTextures()
	OrderHallTalentFrame:SetTemplate("Transparent")
	ClassHallTalentInset:StripTextures()
	OrderHallTalentFrame.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)

	S:HandleCloseButton(OrderHallTalentFrameCloseButton)

	-- Needs Review
	-- Scouting Map Quest Choise
	AdventureMapQuestChoiceDialog:StripTextures()
	AdventureMapQuestChoiceDialog:SetTemplate("Default")
	-- The portrait driving me nuts
	-- AdventureMapQuestChoiceDialog.Portrait:
	
	S:HandleCloseButton(AdventureMapQuestChoiceDialog.CloseButton)
	-- S:HandleScrollBar(AdventureMapQuestChoiceDialog.Details.ScrollBar)
	S:HandleButton(AdventureMapQuestChoiceDialog.AcceptButton)
	S:HandleButton(AdventureMapQuestChoiceDialog.DeclineButton)

	--Dumb
	OrderHallCommandBar.WorldMapButton:Kill()
end

S:RegisterSkin('Blizzard_OrderHallUI', LoadSkin)
