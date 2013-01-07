local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "AltoholicSkin"
local function SkinAltoholic(self)
	LoadAddOn("Altoholic_Characters")
	AltoholicFrame.IsSkinned = "False"
	AltoTooltip:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)
	AltoholicFramePortrait:Kill()
	AS:SkinFrame(AltoholicFrame)
	AltoholicFrame:HookScript("OnShow", function(self) if AltoholicFrame.IsSkinned == "True" then return end
		AltoholicFrame.IsSkinned = "True"
		AS:SkinFrame(AltoholicFrameSummary)
		AS:SkinFrame(AltoholicFrameActivity)
		AS:SkinFrame(AltoholicFrameBagUsage)
		AS:SkinFrame(AltoholicFrameSkills)
		AS:SkinFrame(AltoMsgBox)
		AS:SkinFrame(AltoholicFrameContainers)
		AS:SkinFrame(AltoholicFrameRecipes)
		AS:SkinFrame(AltoholicFrameQuests)
		AS:SkinFrame(AltoholicFrameGlyphs)
		AS:SkinFrame(AltoholicFrameMail)
		AS:SkinFrame(AltoholicFrameSpellbook)
		AS:SkinFrame(AltoholicFramePets)
		AS:SkinFrame(AltoholicFrameAuctions)
		S:HandleCloseButton(AltoholicFrameCloseButton)
		S:HandleDropDownBox(AltoholicTabSummary_SelectLocation)
		S:HandleEditBox(AltoholicFrame_SearchEditBox)
		S:HandleScrollBar(AltoholicFrameSummaryScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicFrameBagUsageScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicFrameSkillsScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicFrameActivityScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicFrameContainersScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicFrameQuestsScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicFrameRecipesScrollFrameScrollBar)
		S:HandleDropDownBox(AltoholicFrameTalents_SelectMember)
		S:HandleDropDownBox(AltoholicTabCharacters_SelectRealm)
		S:HandleNextPrevButton(AltoholicFrameSpellbookPrevPage)
		S:HandleNextPrevButton(AltoholicFrameSpellbookNextPage)
		S:HandleNextPrevButton(AltoholicFramePetsNormalPrevPage)
		S:HandleNextPrevButton(AltoholicFramePetsNormalNextPage)
		S:HandleRotateButton(AltoholicFramePetsNormal_ModelFrameRotateLeftButton)
		S:HandleRotateButton(AltoholicFramePetsNormal_ModelFrameRotateRightButton)
		S:HandleButton(AltoMsgBoxYesButton)
		S:HandleButton(AltoMsgBoxNoButton)
		S:HandleButton(AltoholicFrame_ResetButton)
		S:HandleButton(AltoholicFrame_SearchButton)
		S:HandleButton(AltoholicTabCharacters_Sort1)
		S:HandleButton(AltoholicTabCharacters_Sort2)
		S:HandleButton(AltoholicTabCharacters_Sort3)

		AltoholicFrameContainersScrollFrame:StripTextures(True)
		AltoholicFrameQuestsScrollFrame:StripTextures(True)
		AltoholicFrameSummaryScrollFrame:StripTextures(True)
		AltoholicFrameBagUsageScrollFrame:StripTextures(True)
		AltoholicFrameSkillsScrollFrame:StripTextures(True)
		AltoholicFrameActivityScrollFrame:StripTextures(True)
		AltoholicFrameRecipesScrollFrame:StripTextures(True)

		AltoholicFrame_ResetButton:Size(85, 24)
		AltoholicFrame_SearchButton:Size(85, 24)
		AltoholicFrame_SearchEditBox:Size(175, 15)
		AltoholicTabSummary_SelectLocation:Width(200)

		AltoholicFrameTab1:Point("TOPLEFT", AltoholicFrame, "BOTTOMLEFT", -5, 2)
		AltoholicFrame_ResetButton:Point("TOPLEFT", AltoholicFrame, "TOPLEFT", 25, -77)
		AltoholicFrame_SearchEditBox:Point("TOPLEFT", AltoholicFrame, "TOPLEFT", 37, -56)

		for i = 1, 4 do
			_G["AltoholicTabSummaryMenuItem"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabSummaryMenuItem"..i])
		end

		for i = 1, 8 do
			_G["AltoholicTabSummary_Sort"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabSummary_Sort"..i])
		end

		for i = 1, 7 do
			_G["AltoholicFrameTab"..i]:StripTextures(True)
			S:HandleTab(_G["AltoholicFrameTab"..i])
		end

		for i = 1, 14 do
			_G["AltoholicFrameContainersEntry1Item"..i]:StripTextures(True)
			_G["AltoholicFrameContainersEntry2Item"..i]:StripTextures(True)
			_G["AltoholicFrameContainersEntry3Item"..i]:StripTextures(True)
			_G["AltoholicFrameContainersEntry4Item"..i]:StripTextures(True)
			_G["AltoholicFrameContainersEntry5Item"..i]:StripTextures(True)
			_G["AltoholicFrameContainersEntry6Item"..i]:StripTextures(True)
			_G["AltoholicFrameContainersEntry7Item"..i]:StripTextures(True)
		end
	end)

	local function LoadSkinAchievements()

		AltoholicFrameAchievements:StripTextures(True)
		AltoholicFrameAchievements:CreateBackdrop("Transparent")
		AltoholicFrameAchievementsScrollFrame:StripTextures(True)
		AltoholicAchievementsMenuScrollFrame:StripTextures(True)
		S:HandleScrollBar(AltoholicFrameAchievementsScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicAchievementsMenuScrollFrameScrollBar)
		S:HandleDropDownBox(AltoholicTabAchievements_SelectRealm)
		AltoholicTabAchievements_SelectRealm:Point("TOPLEFT", AltoholicFrame, "TOPLEFT", 205, -57)

		for i = 1, 15 do
			_G["AltoholicTabAchievementsMenuItem"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabAchievementsMenuItem"..i])
		end

		for i = 1, 10 do
			_G["AltoholicFrameAchievementsEntry1Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry2Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry3Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry4Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry5Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry6Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry7Item"..i]:StripTextures(True)
			_G["AltoholicFrameAchievementsEntry8Item"..i]:StripTextures(True)
		end
	end


	local function LoadSkinAgenda()

		AS:SkinFrame(AltoholicFrameCalendarScrollFrame)
		AS:SkinFrame(AltoholicTabAgendaMenuItem1)
		S:HandleScrollBar(AltoholicFrameCalendarScrollFrameScrollBar)
		S:HandleNextPrevButton(AltoholicFrameCalendar_NextMonth)
		S:HandleNextPrevButton(AltoholicFrameCalendar_PrevMonth)
		AltoholicTabAgendaMenuItem1:SetTemplate("Transparent")

		for i = 1, 14 do
			_G["AltoholicFrameCalendarEntry"..i]:StripTextures(True)
			AS:SkinFrame(_G["AltoholicFrameCalendarEntry"..i])
		end
	end

	local function LoadSkinGrids()

		AltoholicFrameGridsScrollFrame:StripTextures(True)
		AltoholicFrameGrids:CreateBackdrop("Transparent")
		S:HandleScrollBar(AltoholicFrameGridsScrollFrameScrollBar)
		S:HandleDropDownBox(AltoholicTabGrids_SelectRealm)
		S:HandleDropDownBox(AltoholicTabGrids_SelectView)

		for i = 1, 10 do
			_G["AltoholicFrameGridsEntry1Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry2Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry3Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry4Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry5Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry6Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry7Item"..i]:StripTextures(True)
			_G["AltoholicFrameGridsEntry8Item"..i]:StripTextures(True)
		end
	end

	local function LoadSkinGuild()

		AS:SkinFrame(AltoholicFrameGuildMembers)
		AS:SkinFrame(AltoholicFrameGuildBank)
		S:HandleScrollBar(AltoholicFrameGuildMembersScrollFrameScrollBar)
		AltoholicFrameGuildMembersScrollFrame:StripTextures(True)

		for i = 1, 2 do
			_G["AltoholicTabGuildMenuItem"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabGuildMenuItem"..i])
		end

		for i = 1, 14 do
			_G["AltoholicFrameGuildBankEntry1Item"..i]:StripTextures(True)
			_G["AltoholicFrameGuildBankEntry2Item"..i]:StripTextures(True)
			_G["AltoholicFrameGuildBankEntry3Item"..i]:StripTextures(True)
			_G["AltoholicFrameGuildBankEntry4Item"..i]:StripTextures(True)
			_G["AltoholicFrameGuildBankEntry5Item"..i]:StripTextures(True)
			_G["AltoholicFrameGuildBankEntry6Item"..i]:StripTextures(True)
			_G["AltoholicFrameGuildBankEntry7Item"..i]:StripTextures(True)
		end

		for i = 1, 19 do
			_G["AltoholicFrameGuildMembersItem"..i]:StripTextures(True)
		end

		for i = 1, 5 do
			_G["AltoholicTabGuild_Sort"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabGuild_Sort"..i])
		end
	end

	local function LoadSkinSearch()

		AltoholicFrameSearch:StripTextures(True)
		AltoholicFrameSearch:CreateBackdrop("Transparent")
		AltoholicFrameSearchScrollFrame:StripTextures(True)
		AltoholicSearchMenuScrollFrame:StripTextures(True)
		S:HandleScrollBar(AltoholicFrameSearchScrollFrameScrollBar)
		S:HandleScrollBar(AltoholicSearchMenuScrollFrameScrollBar)
		S:HandleDropDownBox(AltoholicTabSearch_SelectRarity)
		S:HandleDropDownBox(AltoholicTabSearch_SelectSlot)
		S:HandleDropDownBox(AltoholicTabSearch_SelectLocation)
		AltoholicTabSearch_SelectRarity:Size(125, 32)
		AltoholicTabSearch_SelectSlot:Size(125, 32)
		AltoholicTabSearch_SelectLocation:Size(175, 32)
		S:HandleEditBox(_G["AltoholicTabSearch_MinLevel"])
		S:HandleEditBox(_G["AltoholicTabSearch_MaxLevel"])

		for i = 1, 15 do
			_G["AltoholicTabSearchMenuItem"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabSearchMenuItem"..i])
		end

		for i = 1, 8 do
			_G["AltoholicTabSearch_Sort"..i]:StripTextures(True)
			S:HandleButton(_G["AltoholicTabSearch_Sort"..i])
		end
	end

	S:RegisterSkin('Altoholic_Achievements', LoadSkinAchievements)
	S:RegisterSkin('Altoholic_Agenda', LoadSkinAgenda)
	S:RegisterSkin('Altoholic_Grids', LoadSkinGrids)
	S:RegisterSkin('Altoholic_Guild', LoadSkinGuild)
	S:RegisterSkin('Altoholic_Search', LoadSkinSearch)
end

AS:RegisterSkin(name,SkinAltoholic)
