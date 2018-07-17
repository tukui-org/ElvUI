local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local select = select
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CreateFrame = CreateFrame
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CUSTOM_CLASS_COLORS, OrderHallCommandBar, OrderHallMissionFrame, ClassHallTalentInset
-- GLOBALS: OrderHallTalentFrame, OrderHallTalentFramePortrait, OrderHallTalentFramePortraitFrame

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

	-- MissionFrame
	local OrderHallMissionFrame = _G["OrderHallMissionFrame"]
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame:CreateBackdrop("Transparent")
	OrderHallMissionFrame.backdrop:SetOutside(OrderHallMissionFrame.BorderFrame)
	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)
	S:HandleCloseButton(_G["OrderHallMissionTutorialFrame"].GlowBox.CloseButton)

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
	local Follower = _G["OrderHallMissionFrameFollowers"]
	local FollowerList = OrderHallMissionFrame.FollowerList
	local FollowerTab = OrderHallMissionFrame.FollowerTab
	Follower:StripTextures()
	Follower:SetTemplate("Transparent")
	FollowerList:StripTextures()
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(OrderHallMissionFrame.FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, "ShowFollower", function(self)
		S:HandleFollowerPage(self, true, true)
	end)
	FollowerTab:StripTextures()
	FollowerTab.Class:SetSize(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E["media"].normTex)
	FollowerTab.XPBar:CreateBackdrop()

	-- Orderhall Portraits
	S:HandleFollowerListOnUpdateData('OrderHallMissionFrameFollowers')
	S:HandleFollowerListOnUpdateData('GarrisonLandingPageFollowerList') -- this also applies to garrison landing page

	-- Missions
	local MissionTab = OrderHallMissionFrame.MissionTab
	local MissionComplete = OrderHallMissionFrame.MissionComplete
	local MissionList = MissionTab.MissionList
	local MissionPage = MissionTab.MissionPage
	local ZoneSupportMissionPage = MissionTab.ZoneSupportMissionPage
	S:HandleScrollBar(MissionList.listScroll.scrollBar)
	MissionList.CompleteDialog:StripTextures()
	MissionList.CompleteDialog:SetTemplate("Transparent")
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	MissionList:StripTextures()
	MissionList.listScroll:StripTextures()
	S:HandleButton(_G["OrderHallMissionFrameMissions"].CombatAllyUI.InProgress.Unassign)
	S:HandleCloseButton(MissionPage.CloseButton)
	S:HandleButton(MissionPage.StartMissionButton)
	S:HandleCloseButton(ZoneSupportMissionPage.CloseButton)
	S:HandleButton(ZoneSupportMissionPage.StartMissionButton)
	S:HandleButton(MissionComplete.NextMissionButton)
end

S:AddCallbackForAddon('Blizzard_GarrisonUI', "OrderHall", LoadSkin)

local function LoadSkinCommandBar()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

	local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

	-- CommandBar
	local OrderHallCommandBar = _G["OrderHallCommandBar"]
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:CreateBackdrop("Transparent")
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:Hide()

	local function colorBorder(child, backdrop, atlas)
		if child.AlphaIconOverlay:IsShown() then --isBeingResearched or (talentAvailability and not selected)
			local alpha = child.AlphaIconOverlay:GetAlpha()
			if alpha <= 0.5 then --talentAvailability
				backdrop:SetBackdropBorderColor(0.5, 0.5, 0.5) --[border = grey, shadow x2]
				child.darkOverlay:SetColorTexture(0, 0, 0, 0.50)
				child.darkOverlay:Show()
			elseif alpha <= 0.7 then --isBeingResearched
				backdrop:SetBackdropBorderColor(0,1,1) --[border = teal, shadow x1]
				child.darkOverlay:SetColorTexture(0, 0, 0, 0.25)
				child.darkOverlay:Show()
			end
		elseif atlas == "orderhalltalents-spellborder-green" then
			backdrop:SetBackdropBorderColor(0,1,0) --[border = green, no shadow]
			child.darkOverlay:Hide()
		elseif atlas == "orderhalltalents-spellborder-yellow" then
			backdrop:SetBackdropBorderColor(1,1,0) --[border = yellow, no shadow]
			child.darkOverlay:Hide()
		elseif atlas == "orderhalltalents-spellborder" then
			backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			child.darkOverlay:SetColorTexture(0, 0, 0, 0.75) --[border will be default, shadow x3]
			child.darkOverlay:Show()
		end
	end

	OrderHallTalentFrame:HookScript("OnShow", function(self)
		if self.skinned then return end

		self:StripTextures()
		self.LeftInset:StripTextures()
		if self.CornerLogo then
			self.CornerLogo:Hide()
		end
		if self.StyleFrame then
			self.StyleFrame:Hide()
		end
		self:SetTemplate("Transparent")
		self.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
		S:HandleCloseButton(self.CloseButton)

		OrderHallTalentFramePortraitFrame:Hide()
		OrderHallTalentFramePortrait:Hide()
		S:HandleButton(self.BackButton)
		-- -- -- -- --
		for i = 1, 7 do
			local bg = CreateFrame("Frame", "OrderHallTalentFrame"..i.."PanelBackground", self)
			if i == 1 then
				bg:Point("TOPLEFT", self, "TOPLEFT", E.PixelMode and 6 or 9, -80)
			else
				bg:Point("TOPLEFT", "OrderHallTalentFrame"..(i-1).."PanelBackground", "BOTTOMLEFT", 0, -6)
			end
			bg:SetTemplate("Transparent")
			bg:SetBackdropColor(0, 0, 0, 0.5)
			bg:SetSize(E.PixelMode and 322 or 316, 52)
		end
		-- -- -- -- --
		local Portrait = OrderHallTalentFramePortrait
		local PortraitFrame = OrderHallTalentFramePortraitFrame

		Portrait:Hide()
		PortraitFrame:Hide()

		local TalentInset = ClassHallTalentInset
		local TalentClassBG = OrderHallTalentFrame.Background
		TalentInset:CreateBackdrop("Transparent")
		TalentInset.backdrop:SetFrameLevel(TalentInset.backdrop:GetFrameLevel()+1)
		TalentInset.backdrop:Point('TOPLEFT', TalentClassBG, 'TOPLEFT', E.Border-1, -E.Border+1)
		TalentInset.backdrop:Point('BOTTOMRIGHT', TalentClassBG, 'BOTTOMRIGHT', -E.Border+1, E.Border-1)
		TalentClassBG:SetAtlas("orderhalltalents-background-"..E.myclass)
		TalentClassBG:SetDrawLayer("ARTWORK")
		TalentClassBG:SetAlpha(0.8)

		for i=1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			if child and child.Icon and not child.backdrop then
				child:StyleButton()
				child:CreateBackdrop()
				child.Border:SetAlpha(0)
				child.Highlight:SetAlpha(0)
				child.AlphaIconOverlay:SetTexture(nil)
				child.Icon:SetTexCoord(unpack(E.TexCoords))
				child.Icon:SetInside(child.backdrop)
				child.hover:SetInside(child.backdrop)
				child.pushed:SetInside(child.backdrop)
				child.backdrop:SetFrameLevel(child.backdrop:GetFrameLevel()+1)

				child.darkOverlay = child:CreateTexture()
				child.darkOverlay:SetAllPoints(child.Icon)
				child.darkOverlay:SetDrawLayer('OVERLAY')
				child.darkOverlay:Hide()

				colorBorder(child, child.backdrop, child.Border:GetAtlas())

				child.TalentDoneAnim:HookScript("OnFinished", function()
					child.Border:SetAlpha(0) -- clear the yellow glow border again, after it finishes the animation
				end)
			end
		end
		self.choiceTexturePool:ReleaseAll()
		hooksecurefunc(self, "RefreshAllData", function(frame)
			frame.choiceTexturePool:ReleaseAll()
			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
				if child and child.Icon and child.backdrop then
					colorBorder(child, child.backdrop, child.Border:GetAtlas())
				end
			end
		end)
		self.skinned = true
	end)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI', "OrderHallCommandBar", LoadSkinCommandBar)