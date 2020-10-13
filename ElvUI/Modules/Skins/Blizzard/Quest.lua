local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local gsub, pairs, ipairs, select, unpack, strfind = gsub, pairs, ipairs, select, unpack, strfind

local C_QuestLog_GetNextWaypointText = C_QuestLog.GetNextWaypointText
local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local GetMoney = GetMoney
local CreateFrame = CreateFrame
local GetQuestID = GetQuestID
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestLogRewardSpells = GetNumQuestLogRewardSpells
local GetNumRewardSpells = GetNumRewardSpells
local hooksecurefunc = hooksecurefunc

local function HandleReward(frame)
	if not frame then return end

	if frame.Icon then
		frame.Icon:SetDrawLayer('ARTWORK')
		S:HandleIcon(frame.Icon, true)
	end

	if frame.IconBorder then
		frame.IconBorder:Kill()
	end

	if frame.Count then
		frame.Count:SetDrawLayer('OVERLAY')
		frame.Count:ClearAllPoints()
		frame.Count:Point('BOTTOMRIGHT', frame.Icon, 'BOTTOMRIGHT', 0, 0)
	end

	if frame.NameFrame then
		frame.NameFrame:SetAlpha(0)
		frame.NameFrame:Hide()
	end

	if frame.IconOverlay then
		frame.IconOverlay:SetAlpha(0)
	end

	if frame.Name then
		frame.Name:FontTemplate()
	end

	if frame.CircleBackground then
		frame.CircleBackground:SetAlpha(0)
		frame.CircleBackgroundGlow:SetAlpha(0)
	end

	for i = 1, frame:GetNumRegions() do
		local Region = select(i, frame:GetRegions())
		if Region and Region:IsObjectType('Texture') and Region:GetTexture() == [[Interface\Spellbook\Spellbook-Parts]] then
			Region:SetTexture('')
		end
	end
end

local function StyleScrollFrame(scrollFrame, widthOverride, heightOverride, inset)
	if not scrollFrame.backdrop then
		scrollFrame:CreateBackdrop()
	end

	if not scrollFrame.spellTex then
		scrollFrame.spellTex = scrollFrame:CreateTexture(nil, 'BACKGROUND', 1)
	end

	local parent = scrollFrame:GetParent()
	if parent.SealMaterialBG and parent.SealMaterialBG:IsShown() then
		scrollFrame.spellTex:Hide()
		scrollFrame.backdrop:Hide()
	else
		scrollFrame.backdrop:Show()
		scrollFrame.spellTex:Show()
		scrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
		scrollFrame.spellTex:Point('TOPLEFT', inset and 1 or 0, inset and -1 or 0)
		scrollFrame.spellTex:Size(widthOverride or 506, heightOverride or 615)
		scrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
	end
end

-- Quest objective text color
local function Quest_GetQuestID()
	if _G.QuestInfoFrame.questLog then
		return C_QuestLog_GetSelectedQuest()
	else
		return GetQuestID()
	end
end

function S:BlizzardQuestFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.quest) then return end

	S:HandleScrollBar(_G.QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestRewardScrollFrameScrollBar)
	S:HandleScrollBar(_G.QuestDetailScrollFrameScrollBar)
	_G.QuestProgressScrollFrame:StripTextures()
	_G.QuestGreetingScrollFrame:StripTextures()
	S:HandleScrollBar(_G.QuestGreetingScrollFrameScrollBar)

	local QuestInfoSkillPointFrame = _G.QuestInfoSkillPointFrame
	QuestInfoSkillPointFrame:StripTextures()
	QuestInfoSkillPointFrame:StyleButton()
	QuestInfoSkillPointFrame:Width(QuestInfoSkillPointFrame:GetWidth() - 4)
	QuestInfoSkillPointFrame:SetFrameLevel(QuestInfoSkillPointFrame:GetFrameLevel() + 2)

	local QuestInfoSkillPointFrameIconTexture = _G.QuestInfoSkillPointFrameIconTexture
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(unpack(E.TexCoords))
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer('OVERLAY')
	QuestInfoSkillPointFrameIconTexture:Point('TOPLEFT', 2, -2)
	QuestInfoSkillPointFrameIconTexture:Size(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
	QuestInfoSkillPointFrame:CreateBackdrop()
	_G.QuestInfoSkillPointFrameCount:SetDrawLayer('OVERLAY')

	local QuestInfoItemHighlight = _G.QuestInfoItemHighlight
	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:CreateBackdrop()
	QuestInfoItemHighlight.backdrop:SetAllPoints()
	QuestInfoItemHighlight.backdrop:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight.backdrop:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:Size(142, 40)

	hooksecurefunc('QuestInfoItem_OnClick', function(s)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(s.Icon)

		for _, Button in ipairs(_G.QuestInfoRewardsFrame.RewardButtons) do
			Button.Name:SetTextColor(1, 1, 1)
		end

		s.Name:SetTextColor(1, .8, .1)
	end)

	_G.QuestRewardScrollFrame:CreateBackdrop()
	_G.QuestRewardScrollFrame:Height(_G.QuestRewardScrollFrame:GetHeight() - 2)

	hooksecurefunc('QuestInfo_Display', function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local questItem = _G.QuestInfoRewardsFrame.RewardButtons[i]
			if not questItem:IsShown() then break end

			local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
			if point and relativeTo and relativePoint then
				if i == 1 then
					questItem:Point(point, relativeTo, relativePoint, 0, y)
				elseif relativePoint == 'BOTTOMLEFT' then
					questItem:Point(point, relativeTo, relativePoint, 0, -4)
				else
					questItem:Point(point, relativeTo, relativePoint, 4, 0)
				end
			end

			questItem.Name:SetTextColor(1, 1, 1)
		end

		local rewardsFrame = _G.QuestInfoFrame.rewardsFrame
		local isQuestLog = _G.QuestInfoFrame.questLog ~= nil

		local numSpellRewards = isQuestLog and GetNumQuestLogRewardSpells() or GetNumRewardSpells()
		if numSpellRewards > 0 then
			if E.private.skins.parchmentRemoverEnable then
				for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
					spellHeader:SetVertexColor(1, 1, 1)
				end
				for spellIcon in rewardsFrame.spellRewardPool:EnumerateActive() do
					HandleReward(spellIcon)
				end
			end

			for followerReward in rewardsFrame.followerRewardPool:EnumerateActive() do
				if not followerReward.isSkinned then
					followerReward:CreateBackdrop()
					followerReward.backdrop:SetAllPoints(followerReward.BG)
					followerReward.backdrop:Point('TOPLEFT', 40, -5)
					followerReward.backdrop:Point('BOTTOMRIGHT', 2, 5)
					followerReward.BG:Hide()

					followerReward.PortraitFrame:ClearAllPoints()
					followerReward.PortraitFrame:Point('RIGHT', followerReward.backdrop, 'LEFT', -2, 0)

					followerReward.PortraitFrame.PortraitRing:Hide()
					followerReward.PortraitFrame.PortraitRingQuality:SetTexture()
					followerReward.PortraitFrame.LevelBorder:SetAlpha(0)
					followerReward.PortraitFrame.Portrait:SetTexCoord(0.2, 0.85, 0.2, 0.85)

					local level = followerReward.PortraitFrame.Level
					level:ClearAllPoints()
					level:Point('BOTTOM', followerReward.PortraitFrame, 0, 3)

					local squareBG = CreateFrame('Frame', nil, followerReward.PortraitFrame, 'BackdropTemplate')
					squareBG:SetFrameLevel(followerReward.PortraitFrame:GetFrameLevel()-1)
					squareBG:Point('TOPLEFT', 2, -2)
					squareBG:Point('BOTTOMRIGHT', -2, 2)
					squareBG:SetTemplate()
					followerReward.PortraitFrame.squareBG = squareBG

					followerReward.isSkinned = true
				end

				local r, g, b = followerReward.PortraitFrame.PortraitRingQuality:GetVertexColor()
				followerReward.PortraitFrame.squareBG:SetBackdropBorderColor(r, g, b)
			end
		end

		if E.private.skins.parchmentRemoverEnable then
			_G.QuestInfoTitleHeader:SetTextColor(1, .8, .1)
			_G.QuestInfoDescriptionHeader:SetTextColor(1, .8, .1)
			_G.QuestInfoObjectivesHeader:SetTextColor(1, .8, .1)
			_G.QuestInfoRewardsFrame.Header:SetTextColor(1, .8, .1)
			_G.QuestInfoDescriptionText:SetTextColor(1, 1, 1)
			_G.QuestInfoObjectivesText:SetTextColor(1, 1, 1)
			_G.QuestInfoGroupSize:SetTextColor(1, 1, 1)
			_G.QuestInfoRewardText:SetTextColor(1, 1, 1)
			_G.QuestInfoQuestType:SetTextColor(1, 1, 1)
			_G.QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1, 1, 1)
			_G.QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)

			-- 9.0 Shadowlands Objective Text Colors
			local function handleObjectives()
				local numObjectives = GetNumQuestLeaderBoards()
				local questID = Quest_GetQuestID()
				local numVisibleObjectives = 0

				local waypointText = C_QuestLog_GetNextWaypointText(questID)
				if waypointText then
					numVisibleObjectives = numVisibleObjectives + 1
					local objective = _G['QuestInfoObjective'..numVisibleObjectives]
					objective:SetTextColor(1, .8, .1)
				end

				for i = 1, numObjectives do
					local _, objectiveType, isCompleted = GetQuestLogLeaderBoard(i)
					if objectiveType ~= 'spell' and numVisibleObjectives < _G.MAX_OBJECTIVES then
						numVisibleObjectives = numVisibleObjectives + 1

						local objective = _G['QuestInfoObjective'..numVisibleObjectives]
						if objective then
							if isCompleted then
								objective:SetTextColor(1, .8, .1)
							else
								objective:SetTextColor(1, 1, 1)
							end
						end
					end
				end
			end

			hooksecurefunc('QuestInfo_ShowObjectives', handleObjectives)
			handleObjectives()

			if _G.QuestInfoRewardsFrame.SpellLearnText then
				_G.QuestInfoRewardsFrame.SpellLearnText:SetTextColor(1, 1, 1)
			end

			_G.QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1, 1, 1)
			_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
		else
			_G.QuestInfoTitleHeader:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoRewardsFrame.Header:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoDescriptionText:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoObjectivesText:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoGroupSize:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoRewardText:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoQuestType:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoRewardsFrame.ItemChooseText:SetShadowColor(0, 0, 0, 0)
			_G.QuestInfoRewardsFrame.ItemReceiveText:SetShadowColor(0, 0, 0, 0)
		end
	end)

	for _, frame in pairs({'HonorFrame', 'XPFrame', 'SpellFrame', 'SkillPointFrame', 'ArtifactXPFrame', 'TitleFrame', 'WarModeBonusFrame'}) do
		HandleReward(_G.MapQuestInfoRewardsFrame[frame])
		HandleReward(_G.QuestInfoRewardsFrame[frame])
	end
	HandleReward(_G.MapQuestInfoRewardsFrame.MoneyFrame)

	-- Hook for WorldQuestRewards / QuestLogRewards
	hooksecurefunc('QuestInfo_GetRewardButton', function(rewardsFrame, index)
		local RewardButton = rewardsFrame.RewardButtons[index]
		if not RewardButton.Icon.backdrop then
			HandleReward(RewardButton)
			RewardButton.NameFrame:Hide()
			S:HandleIconBorder(RewardButton.IconBorder, RewardButton.Icon.backdrop)
		end
	end)

	--Reward: Title
	local QuestInfoPlayerTitleFrame = _G.QuestInfoPlayerTitleFrame
	QuestInfoPlayerTitleFrame.FrameLeft:SetTexture()
	QuestInfoPlayerTitleFrame.FrameCenter:SetTexture()
	QuestInfoPlayerTitleFrame.FrameRight:SetTexture()
	QuestInfoPlayerTitleFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	QuestInfoPlayerTitleFrame:CreateBackdrop()
	QuestInfoPlayerTitleFrame.backdrop:SetOutside(QuestInfoPlayerTitleFrame.Icon)

	--Quest Frame
	local QuestFrame = _G.QuestFrame
	S:HandlePortraitFrame(QuestFrame)

	_G.QuestFrameDetailPanel:StripTextures(true)
	_G.QuestDetailScrollFrame:StripTextures(true)
	_G.QuestDetailScrollFrame:CreateBackdrop()
	_G.QuestProgressScrollFrame:CreateBackdrop()
	_G.QuestGreetingScrollFrame:CreateBackdrop()

	local function UpdateGreetingFrame()
		for Button in _G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive() do
			Button.Icon:SetDrawLayer('ARTWORK')
			if E.private.skins.parchmentRemoverEnable then
				local Text = Button:GetFontString():GetText()
				if Text and strfind(Text, '|cff000000') then
					Button:GetFontString():SetText(gsub(Text, '|cff000000', '|cffffe519'))
				end
			end
		end
	end

	_G.QuestFrameGreetingPanel:HookScript('OnShow', UpdateGreetingFrame)
	hooksecurefunc('QuestFrameGreetingPanel_OnShow', UpdateGreetingFrame)

	if E.private.skins.parchmentRemoverEnable then
		hooksecurefunc('QuestFrameProgressItems_Update', function()
			_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, .1)
			_G.QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
		end)

		hooksecurefunc('QuestFrame_SetTitleTextColor', function(fontString)
			fontString:SetTextColor(1, .8, .1)
		end)

		hooksecurefunc('QuestFrame_SetTextColor', function(fontString)
			fontString:SetTextColor(1, 1, 1)
		end)

		hooksecurefunc('QuestInfo_ShowRequiredMoney', function()
			local requiredMoney = GetQuestLogRequiredMoney()
			if requiredMoney > 0 then
				if requiredMoney > GetMoney() then
					_G.QuestInfoRequiredMoneyText:SetTextColor(.63, .09, .09)
				else
					_G.QuestInfoRequiredMoneyText:SetTextColor(1, .8, .1)
				end
			end
		end)

		if _G.QuestFrameDetailPanel.SealMaterialBG then
			_G.QuestFrameDetailPanel.SealMaterialBG:SetAlpha(0)
		end

		if _G.QuestFrameRewardPanel.SealMaterialBG then
			_G.QuestFrameRewardPanel.SealMaterialBG:SetAlpha(0)
		end
	else
		StyleScrollFrame(_G.QuestProgressScrollFrame, 506, 615, true)
		StyleScrollFrame(_G.QuestGreetingScrollFrame, 506, 615, true)
		_G.QuestFrameDetailPanel:HookScript('OnShow', function(s) StyleScrollFrame(s.ScrollFrame, 506, 615, true) end)
		_G.QuestRewardScrollFrame:HookScript('OnShow', function(s) StyleScrollFrame(s, 506, 615, true) end)
	end

	_G.QuestFrameGreetingPanel:StripTextures(true)
	S:HandleButton(_G.QuestFrameGreetingGoodbyeButton)
	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestDetailScrollChildFrame:StripTextures(true)
	_G.QuestRewardScrollFrame:StripTextures(true)
	_G.QuestRewardScrollChildFrame:StripTextures(true)
	_G.QuestFrameProgressPanel:StripTextures(true)
	_G.QuestFrameRewardPanel:StripTextures(true)
	S:HandleButton(_G.QuestFrameAcceptButton)
	S:HandleButton(_G.QuestFrameDeclineButton)
	S:HandleButton(_G.QuestFrameCompleteButton)
	S:HandleButton(_G.QuestFrameGoodbyeButton)
	S:HandleButton(_G.QuestFrameCompleteQuestButton)

	for i = 1, 6 do
		local button = _G['QuestProgressItem'..i]
		local icon = _G['QuestProgressItem'..i..'IconTexture']
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Point('TOPLEFT', 2, -2)
		icon:Size(icon:GetWidth() -3, icon:GetHeight() -3)
		button:Width(button:GetWidth() -4)
		button:StripTextures()
		button:SetFrameLevel(button:GetFrameLevel() +1)

		local frame = CreateFrame('Frame', nil, button, 'BackdropTemplate')
		frame:SetFrameLevel(button:GetFrameLevel() -1)
		frame:SetTemplate('Transparent', nil, true)
		frame:SetBackdropBorderColor(unpack(E.media.bordercolor))
		frame:SetBackdropColor(0, 0, 0, 0)
		frame:SetOutside(icon)
		button.backdrop = frame

		local hover = button:CreateTexture()
		hover:SetColorTexture(1, 1, 1, 0.3)
		hover:SetAllPoints(icon)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	_G.QuestModelScene:StripTextures()
	_G.QuestModelScene:CreateBackdrop('Transparent')
	_G.QuestModelScene:Point('TOPLEFT', _G.QuestLogDetailFrame, 'TOPRIGHT', 4, -34)
	_G.QuestNPCModelTextFrame:StripTextures()
	_G.QuestNPCModelTextFrame:CreateBackdrop('Transparent')
	S:HandleScrollBar(_G.QuestNPCModelTextScrollFrame.ScrollBar)

	local QuestLogPopupDetailFrame = _G.QuestLogPopupDetailFrame
	S:HandlePortraitFrame(QuestLogPopupDetailFrame)

	S:HandleButton(_G.QuestLogPopupDetailFrameAbandonButton)
	S:HandleButton(_G.QuestLogPopupDetailFrameShareButton)
	S:HandleButton(_G.QuestLogPopupDetailFrameTrackButton)
	_G.QuestLogPopupDetailFrameScrollFrame:StripTextures()
	S:HandleScrollBar(_G.QuestLogPopupDetailFrameScrollFrameScrollBar)
	QuestLogPopupDetailFrame:CreateBackdrop('Transparent')

	_G.QuestLogPopupDetailFrameScrollFrame:HookScript('OnShow', function(s)
		if not _G.QuestLogPopupDetailFrameScrollFrame.backdrop then
			_G.QuestLogPopupDetailFrameScrollFrame:CreateBackdrop()
			_G.QuestLogPopupDetailFrameScrollFrame:Height(s:GetHeight() - 2)
			if not E.private.skins.parchmentRemoverEnable then
				StyleScrollFrame(_G.QuestLogPopupDetailFrameScrollFrame, 509, 630, false)
			end
		end
		if not E.private.skins.parchmentRemoverEnable then
			_G.QuestLogPopupDetailFrameScrollFrame.spellTex:Height(s:GetHeight() + 217)
		end
	end)

	QuestLogPopupDetailFrame.ShowMapButton:StripTextures()
	S:HandleButton(QuestLogPopupDetailFrame.ShowMapButton)
	QuestLogPopupDetailFrame.ShowMapButton.Text:ClearAllPoints()
	QuestLogPopupDetailFrame.ShowMapButton.Text:Point('CENTER')
	QuestLogPopupDetailFrame.ShowMapButton:Size(QuestLogPopupDetailFrame.ShowMapButton:GetWidth() - 30, QuestLogPopupDetailFrame.ShowMapButton:GetHeight(), - 40)

	-- 9.0 Needs Update for ShadowLands
	-- Skin the +/- buttons in the QuestLog
	hooksecurefunc('QuestLogQuests_Update', function()
		for i = 1, _G.QuestMapFrame.QuestsFrame.Contents:GetNumChildren() do
			local child = select(i, _G.QuestMapFrame.QuestsFrame.Contents:GetChildren())
			if child and child.ButtonText and not child.questID then
				child:Size(16, 16)

				for x = 1, child:GetNumRegions() do
					local tex = select(x, child:GetRegions())
					if tex and tex.GetAtlas then
						local atlas = tex:GetAtlas()
						if atlas == 'Campaign_HeaderIcon_Closed' or atlas == 'Campaign_HeaderIcon_ClosedPressed' then
							tex:SetTexture(E.Media.Textures.PlusButton)
						elseif atlas == 'Campaign_HeaderIcon_Open' or atlas == 'Campaign_HeaderIcon_OpenPressed' then
							tex:SetTexture(E.Media.Textures.MinusButton)
						end
					end
				end
			end
		end
	end)

	-- +/- Buttons for the CampaignHeaders in the QuestLog
	hooksecurefunc(_G.CampaignCollapseButtonMixin, 'UpdateState', function(button, isCollapsed)
		if isCollapsed then
			button:SetNormalTexture(E.Media.Textures.PlusButton)
			button:SetPushedTexture(E.Media.Textures.PlusButton)
		else
			button:SetNormalTexture(E.Media.Textures.MinusButton)
			button:SetPushedTexture(E.Media.Textures.MinusButton)
		end

		button:Size(16, 16)
	end)
end

S:AddCallback('BlizzardQuestFrames')
