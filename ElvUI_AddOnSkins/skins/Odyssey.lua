local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "OdysseySkin"
local function SkinOdyssey(self)
	OdysseyFrameQuestDBScrollFrame:StripTextures(True)
	OdysseyMapsMenuScrollFrame:StripTextures(True)
	OdysseyFrameQuestDetailsSeries:StripTextures(True)
	OdysseyFrameSearchScrollFrame:StripTextures(True)

	OdysseyFramePortrait:Kill()

	AS:SkinFrame(OdysseyFrame)
	AS:SkinFrame(OdysseyFrameRealmSummaryScrollFrame)
	OdysseyFrameQuestDB:SetTemplate("Transparent")
	OdysseyFrameQuestDBScrollFrame:SetTemplate("Transparent")
	OdysseyFrameQuestDetails:SetTemplate("Transparent")
	OdysseyFrameZoneMaps:SetTemplate("Transparent")

	S:HandleScrollBar(OdysseyFrameQuestDBScrollFrameScrollBar)
	S:HandleScrollBar(OdysseyFrameRealmSummaryScrollFrameScrollBar)
	S:HandleScrollBar(OdysseyMapsMenuScrollFrameScrollBar)
	S:HandleEditBox(OdysseyFrame_SearchEditBox)
	S:HandleEditBox(OdysseyFrameQuestDB_MinLevel)
	S:HandleEditBox(OdysseyFrameQuestDB_MaxLevel)
	
	OdysseyFrame_ResetButton:Point("TOPLEFT", OdysseyFrame, "TOPLEFT", 55, -77)
	OdysseyFrameTab1:Point("TOPLEFT", OdysseyFrame, "BOTTOMLEFT", -5, 2)
	S:HandleButton(OdysseyFrame_ResetButton)
	S:HandleButton(OdysseyFrame_SearchButton)
	S:HandleButton(OdysseyFrameQuestDB_GetHistory)
	S:HandleCloseButton(OdysseyFrameCloseButton)
	S:HandleNextPrevButton(OdysseyFrameQuestDetailsGoBack)
	S:HandleNextPrevButton(OdysseyFrameQuestDetailsGoForward)
	S:HandleDropDownBox(OdysseyFrameRealmSummary_SelectContinent)
	S:HandleScrollBar(OdysseyFrameSearchScrollFrameScrollBar)

	for i = 1, 3 do
		S:HandleTab(_G["OdysseyFrameTab"..i])
		AS:SkinFrame(_G["OdysseyTabQuestsMenuItem"..i])
	end

	for i = 1, 5 do
		AS:SkinFrame(_G["OdysseyTabQuests_Sort"..i])
	end

	for i = 1, 15 do
		AS:SkinFrame(_G["OdysseyTabMapsMenuItem"..i])
	end

	for i = 1, 4 do
		AS:SkinFrame(_G["OdysseyTabSearchMenuItem"..i])
	end

	for i = 1, 10 do
		_G["OdysseyFrameRealmSummaryEntry1Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry2Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry3Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry4Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry5Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry6Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry7Item"..i]:StripTextures(True)
		_G["OdysseyFrameRealmSummaryEntry8Item"..i]:StripTextures(True)
	end

	OdyTooltip:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)

end

AS:RegisterSkin(name,SkinOdyssey)
