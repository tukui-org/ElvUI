local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true --[[or E.private.skins.blizzard.garrison ~= true]] then return end
	--Frame show on clicking minimap button
	GarrisonLandingPage:StripTextures()
	GarrisonLandingPage:SetTemplate("Transparent")
	
	GarrisonLandingPageList:StripTextures()
	GarrisonLandingPageList:SetTemplate("Transparent")
	S:HandleScrollBar(GarrisonLandingPageListListScrollFrameScrollBar)
	S:HandleCloseButton(GarrisonLandingPage.CloseButton)
	
	local function SkinFakeTabs()
		GarrisonLandingPage.InProgress:StripTextures()
		GarrisonLandingPage.InProgress:SetTemplate("Transparent")
		GarrisonLandingPage.Available:StripTextures()
		GarrisonLandingPage.Available:SetTemplate("Transparent")
	end
	GarrisonLandingPage.InProgress:HookScript("OnUpdate", SkinFakeTabs)

	for i = 1, GarrisonLandingPageListListScrollFrameScrollChild:GetNumChildren() do
		local child = select(i, GarrisonLandingPageListListScrollFrameScrollChild:GetChildren())
		S:HandleButton(child, true)
		--actually doesn't matter if we do that, result is pretty much the same
		for j = 1, child:GetNumChildren() do
			local childC = select(j, child:GetChildren())
			S:HandleButton(childC, true)
		end
	end
	
	--Mission management
	GarrisonMissionFrame:StripTextures()
	GarrisonMissionFrame:SetTemplate("Transparent")
	
	GarrisonMissionFrameMissions:StripTextures()
	GarrisonMissionFrameMissions:SetTemplate("Transparent")
	
	GarrisonMissionFrameMissionsTab1:ClearAllPoints()
	GarrisonMissionFrameMissionsTab1:Point("BOTTOMLEFT", GarrisonMissionFrameMissions, "TOPLEFT", 20, -4)
	GarrisonMissionFrameMissions.MaterialFrame:StripTextures()
	GarrisonMissionFrameMissions.MaterialFrame:SetTemplate("Transparent")
	
	GarrisonMissionFrameTab1:ClearAllPoints()
	GarrisonMissionFrameTab1:Point("BOTTOMLEFT", GarrisonMissionFrame, "BOTTOMLEFT", 11, -30)
	
	S:HandleScrollBar(GarrisonMissionFrameMissionsListScrollFrameScrollBar)
	
	for i = 1, GarrisonMissionFrameMissionsListScrollFrameScrollChild:GetNumChildren() do
		local child = select(i, GarrisonMissionFrameMissionsListScrollFrameScrollChild:GetChildren())
		S:HandleButton(child, true)
	end
	
	GarrisonMissionFrameFollowers:StripTextures()
	GarrisonMissionFrameFollowers:SetTemplate("Transparent")
	GarrisonMissionFrameFollowers.MaterialFrame:StripTextures()
	GarrisonMissionFrameFollowers.MaterialFrame:SetTemplate("Transparent")
	S:HandleScrollBar(GarrisonMissionFrameFollowersListScrollFrameScrollBar)
	S:HandleEditBox(GarrisonMissionFrameFollowers.SearchBox)
	--S:HandleButton() --Filter button on followers tab seems to have no name
	GarrisonMissionFrame.FollowerTab:StripTextures()
	GarrisonMissionFrame.FollowerTab:SetTemplate("Transparent")
	
	S:HandleButton(GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton)
	S:HandleCloseButton(GarrisonMissionFrame.MissionTab.MissionPage.CloseButton)
	
	S:HandleTab(GarrisonMissionFrameMissionsTab1)
	S:HandleTab(GarrisonMissionFrameMissionsTab2)
	S:HandleTab(GarrisonMissionFrameTab1)
	S:HandleTab(GarrisonMissionFrameTab2)
	
	GarrisonMissionFrame.FollowerTab.PortraitFrame:Kill()
	--[[GarrisonMissionFrame.FollowerTab.PortraitFrame:StripTextures()
	GarrisonMissionFrame.FollowerTab.PortraitFrame:SetTemplate("Transparent")]]
	GarrisonMissionFrame.FollowerTab.XPBar:StripTextures()
	GarrisonMissionFrame.FollowerTab.XPBar:SetTemplate("Transparent")
	GarrisonMissionFrame.FollowerTab.XPBar:SetStatusBarTexture(E['media'].normTex)
	GarrisonMissionFrame.FollowerTab.XPBar:ClearAllPoints()
	GarrisonMissionFrame.FollowerTab.XPBar:Point("RIGHT", GarrisonMissionFrame.FollowerTab, "TOPRIGHT", -10, -80)

	GarrisonMissionFrame.FollowerTab.ItemWeapon:StripTextures()
	GarrisonMissionFrame.FollowerTab.ItemWeapon:SetTemplate("Transparent")
	GarrisonMissionFrame.FollowerTab.ItemArmor:StripTextures()
	GarrisonMissionFrame.FollowerTab.ItemArmor:SetTemplate("Transparent")
	
	S:HandleCloseButton(GarrisonMissionFrame.CloseButton)
	
	--Garrison building ui
	GarrisonBuildingFrame:StripTextures()
	GarrisonBuildingFrame:SetTemplate("Transparent")
	S:HandleCloseButton(GarrisonBuildingFrame.CloseButton)
	GarrisonBuildingFrame.BuildingList:StripTextures()
	GarrisonBuildingFrame.BuildingList:SetTemplate("Transparent")
	GarrisonBuildingFrame.InfoBox:StripTextures()
	GarrisonBuildingFrame.InfoBox:SetTemplate("Transparent")
	GarrisonBuildingFrame.BuildingList.MoneyFrame:StripTextures()
	GarrisonBuildingFrame.BuildingList.MoneyFrame:SetTemplate("Transparent")
	
	local function SkinFakeTabs()
		GarrisonBuildingFrame.BuildingList.Tab1:StripTextures()
		GarrisonBuildingFrame.BuildingList.Tab2:StripTextures()
		GarrisonBuildingFrame.BuildingList.Tab3:StripTextures()
		GarrisonBuildingFrame.BuildingList.Tab1:SetTemplate("Transparent")
		GarrisonBuildingFrame.BuildingList.Tab2:SetTemplate("Transparent")
		GarrisonBuildingFrame.BuildingList.Tab3:SetTemplate("Transparent")
	end
	GarrisonBuildingFrame.BuildingList.Tab1:HookScript("OnUpdate", SkinFakeTabs)
	
	--Monument
	GarrisonMonumentFrame:StripTextures()
	GarrisonMonumentFrame:SetTemplate("Transparent")
	-- Those doesn't work, fuck them
	-- S:HandleButton(GarrisonMonumentFrame.LeftBtn)
	-- S:HandleButton(GarrisonMonumentFrame.RightBtn)
end

S:RegisterSkin('Blizzard_GarrisonUI', LoadSkin)