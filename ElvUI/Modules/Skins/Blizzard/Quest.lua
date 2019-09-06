local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local gsub, type, pairs, ipairs, select, unpack, strfind = gsub, type, pairs, ipairs, select, unpack, strfind
--WoW API / Variables
local C_QuestLog_GetNextWaypointText = C_QuestLog.GetNextWaypointText
local GetMoney = GetMoney
local CreateFrame = CreateFrame
local GetQuestID = GetQuestID
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetNumQuestLogRewardSpells = GetNumQuestLogRewardSpells
local GetNumRewardSpells = GetNumRewardSpells
local GetQuestLogSelection = GetQuestLogSelection
local hooksecurefunc = hooksecurefunc

local PlusButtonIDs = {
	[130835] = 'interface/buttons/ui-plusbutton-disabled.blp',
	[130836] = 'interface/buttons/ui-plusbutton-down.blp',
	[130837] = 'interface/buttons/ui-plusbutton-hilight.blp',
	[130838] = 'interface/buttons/ui-plusbutton-up.blp'
}

local function HandleReward(frame)
	if (not frame) then return end

	if frame.Icon then
		S:HandleIcon(frame.Icon, true)

		frame.Count:ClearAllPoints()
		frame.Count:Point("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)
	end

	if frame.NameFrame then
		frame.NameFrame:SetAlpha(0)
	end

	if frame.Name then
		frame.Name:SetFontObject("GameFontHighlightSmall")
	end

	if (frame.CircleBackground) then
		frame.CircleBackground:SetAlpha(0)
		frame.CircleBackgroundGlow:SetAlpha(0)
	end
end

local function StyleScrollFrame(scrollFrame, widthOverride, heightOverride, inset)
	scrollFrame:SetTemplate()
	if not scrollFrame.spellTex then
		scrollFrame.spellTex = scrollFrame:CreateTexture(nil, 'BACKGROUND', 1)
	end

	scrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
	if inset then
		scrollFrame.spellTex:Point("TOPLEFT", 1, -1)
	else
		scrollFrame.spellTex:Point("TOPLEFT")
	end
	scrollFrame.spellTex:Size(widthOverride or 506, heightOverride or 615)
	scrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
end

-- Quest objective text color
local function Quest_GetQuestID()
	if _G.QuestInfoFrame.questLog then
		return select(8, GetQuestLogTitle(GetQuestLogSelection()))
	else
		return GetQuestID()
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end

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
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameIconTexture:Point("TOPLEFT", 2, -2)
	QuestInfoSkillPointFrameIconTexture:Size(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
	QuestInfoSkillPointFrame:CreateBackdrop()
	_G.QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")

	local QuestInfoItemHighlight = _G.QuestInfoItemHighlight
	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:SetTemplate(nil, nil, true)
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:Size(142, 40)

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(self.Icon)

		for _, Button in ipairs(_G.QuestInfoRewardsFrame.RewardButtons) do
			Button.Name:SetTextColor(1, 1, 1)
		end

		self.Name:SetTextColor(1, .8, .1)
	end)

	_G.QuestRewardScrollFrame:CreateBackdrop()
	_G.QuestRewardScrollFrame:Height(_G.QuestRewardScrollFrame:GetHeight() - 2)

	hooksecurefunc("QuestInfo_Display", function()
		for i = 1, #_G.QuestInfoRewardsFrame.RewardButtons do
			local questItem = _G.QuestInfoRewardsFrame.RewardButtons[i]
			if not questItem:IsShown() then break end

			local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
			if point and relativeTo and relativePoint then
				if i == 1 then
					questItem:Point(point, relativeTo, relativePoint, 0, y)
				elseif relativePoint == "BOTTOMLEFT" then
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
			if E.private.skins.parchmentRemover.enable then
				for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
					spellHeader:SetVertexColor(1, 1, 1)
				end
			end

			for followerReward in rewardsFrame.followerRewardPool:EnumerateActive() do
				if not followerReward.isSkinned then
					followerReward:CreateBackdrop()
					followerReward.backdrop:SetAllPoints(followerReward.BG)
					followerReward.backdrop:SetPoint("TOPLEFT", 40, -5)
					followerReward.backdrop:SetPoint("BOTTOMRIGHT", 2, 5)
					followerReward.BG:Hide()

					followerReward.PortraitFrame:ClearAllPoints()
					followerReward.PortraitFrame:SetPoint("RIGHT", followerReward.backdrop, "LEFT", -2, 0)

					followerReward.PortraitFrame.PortraitRing:Hide()
					followerReward.PortraitFrame.PortraitRingQuality:SetTexture()
					followerReward.PortraitFrame.LevelBorder:SetAlpha(0)
					followerReward.PortraitFrame.Portrait:SetTexCoord(0.2, 0.85, 0.2, 0.85)

					local level = followerReward.PortraitFrame.Level
					level:ClearAllPoints()
					level:SetPoint("BOTTOM", followerReward.PortraitFrame, 0, 3)

					local squareBG = CreateFrame("Frame", nil, followerReward.PortraitFrame)
					squareBG:SetFrameLevel(followerReward.PortraitFrame:GetFrameLevel()-1)
					squareBG:SetPoint("TOPLEFT", 2, -2)
					squareBG:SetPoint("BOTTOMRIGHT", -2, 2)
					squareBG:SetTemplate()
					followerReward.PortraitFrame.squareBG = squareBG

					followerReward.isSkinned = true
				end

				local r, g, b = followerReward.PortraitFrame.PortraitRingQuality:GetVertexColor()
				followerReward.PortraitFrame.squareBG:SetBackdropBorderColor(r, g, b)
			end
		end

		if E.private.skins.parchmentRemover.enable then
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

			if _G.QuestInfoRewardsFrame.SpellLearnText then
				_G.QuestInfoRewardsFrame.SpellLearnText:SetTextColor(1, 1, 1)
			end

			_G.QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1, 1, 1)
			_G.QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)

			local questID = Quest_GetQuestID()
			local numObjectives = GetNumQuestLeaderBoards()
			local numVisibleObjectives = 0

			local waypointText = C_QuestLog_GetNextWaypointText(questID)
			if waypointText then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = _G['QuestInfoObjective'..numVisibleObjectives]
				objective:SetTextColor(1, .8, .1)
			end

			for i = 1, numObjectives do
				local _, _, finished = GetQuestLogLeaderBoard(i)
				if (type ~= "spell" and type ~= "log" and numVisibleObjectives < _G.MAX_OBJECTIVES) then
					numVisibleObjectives = numVisibleObjectives + 1
					local objective = _G['QuestInfoObjective'..numVisibleObjectives]
					if objective then
						if finished then
							objective:SetTextColor(1, .8, .1)
						else
							objective:SetTextColor(.63, .09, .09)
						end
					end
				end
			end
		end
	end)

	local Rewards = { 'MoneyFrame', 'HonorFrame', 'XPFrame', 'SpellFrame', 'SkillPointFrame' }

	for _, frame in pairs(Rewards) do
		HandleReward(_G.MapQuestInfoRewardsFrame[frame])
		HandleReward(_G.QuestInfoRewardsFrame[frame])
	end

	-- Hook for WorldQuestRewards / QuestLogRewards
	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local RewardButton = rewardsFrame.RewardButtons[index]

		if (not RewardButton.Icon.backdrop) then
			HandleReward(RewardButton)

			RewardButton.IconBorder:SetAlpha(0)
			RewardButton.NameFrame:Hide()

			hooksecurefunc(RewardButton.IconBorder, 'SetVertexColor', function(_, r, g, b) RewardButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
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
	S:HandlePortraitFrame(QuestFrame, true)

	_G.QuestFrameDetailPanel:StripTextures(true)
	_G.QuestDetailScrollFrame:StripTextures(true)
	_G.QuestDetailScrollFrame:SetTemplate()
	_G.QuestProgressScrollFrame:SetTemplate()
	_G.QuestGreetingScrollFrame:SetTemplate()

	local function UpdateGreetingFrame()
		for Button in _G.QuestFrameGreetingPanel.titleButtonPool:EnumerateActive() do
			Button.Icon:SetDrawLayer("ARTWORK")
			if E.private.skins.parchmentRemover.enable then
				local Text = Button:GetFontString():GetText()
				if Text and strfind(Text, '|cff000000') then
					Button:GetFontString():SetText(gsub(Text, '|cff000000', '|cffffe519'))
				end
			end
		end
	end

	_G.QuestFrameGreetingPanel:HookScript('OnShow', UpdateGreetingFrame)
	hooksecurefunc("QuestFrameGreetingPanel_OnShow", UpdateGreetingFrame)

	if E.private.skins.parchmentRemover.enable then
		hooksecurefunc('QuestFrameProgressItems_Update', function()
			_G.QuestProgressRequiredItemsText:SetTextColor(1, .8, .1)
			_G.QuestProgressRequiredMoneyText:SetTextColor(1, 1, 1)
		end)

		hooksecurefunc("QuestFrame_SetTitleTextColor", function(fontString)
			fontString:SetTextColor(1, .8, .1)
		end)

		hooksecurefunc("QuestFrame_SetTextColor", function(fontString)
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

		local QuestInfoRewardsFrame = _G.QuestInfoRewardsFrame
		if QuestInfoRewardsFrame.spellHeaderPool then
			for _, pool in ipairs({"followerRewardPool", "spellRewardPool"}) do
				QuestInfoRewardsFrame[pool]._acquire = QuestInfoRewardsFrame[pool].Acquire
				QuestInfoRewardsFrame[pool].Acquire = function()
					local frame = QuestInfoRewardsFrame[pool]:_acquire()
					if frame then
						frame.Name:SetTextColor(1, 1, 1)
					end
					return frame
				end
			end
			QuestInfoRewardsFrame.spellHeaderPool._acquire = QuestInfoRewardsFrame.spellHeaderPool.Acquire
			QuestInfoRewardsFrame.spellHeaderPool.Acquire = function(self)
				local frame = self:_acquire()
				if frame then
					frame:SetTextColor(1, 1, 1)
				end
				return frame
			end
		end
	else
		StyleScrollFrame(_G.QuestDetailScrollFrame, 506, 615, true)
		StyleScrollFrame(_G.QuestProgressScrollFrame, 506, 615, true)
		StyleScrollFrame(_G.QuestGreetingScrollFrame, 506, 615, true)
		_G.QuestRewardScrollFrame:HookScript('OnShow', function(self)
			StyleScrollFrame(self, 506, 615, true)
		end)
	end

	_G.QuestFrameGreetingPanel:StripTextures(true)
	S:HandleButton(_G.QuestFrameGreetingGoodbyeButton, true)
	_G.QuestGreetingFrameHorizontalBreak:Kill()

	_G.QuestDetailScrollChildFrame:StripTextures(true)
	_G.QuestRewardScrollFrame:StripTextures(true)
	_G.QuestRewardScrollChildFrame:StripTextures(true)
	_G.QuestFrameProgressPanel:StripTextures(true)
	_G.QuestFrameRewardPanel:StripTextures(true)
	S:HandleButton(_G.QuestFrameAcceptButton, true)
	S:HandleButton(_G.QuestFrameDeclineButton, true)
	S:HandleButton(_G.QuestFrameCompleteButton, true)
	S:HandleButton(_G.QuestFrameGoodbyeButton, true)
	S:HandleButton(_G.QuestFrameCompleteQuestButton, true)

	for i = 1, 6 do
		local button = _G["QuestProgressItem"..i]
		local icon = _G["QuestProgressItem"..i.."IconTexture"]
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Point("TOPLEFT", 2, -2)
		icon:Size(icon:GetWidth() -3, icon:GetHeight() -3)
		button:Width(button:GetWidth() -4)
		button:StripTextures()
		button:SetFrameLevel(button:GetFrameLevel() +1)

		local frame = CreateFrame("Frame", nil, button)
		frame:SetFrameLevel(button:GetFrameLevel() -1)
		frame:SetTemplate("Transparent", nil, true)
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

	_G.QuestNPCModel:StripTextures()
	_G.QuestNPCModel:CreateBackdrop("Transparent")
	_G.QuestNPCModel:Point("TOPLEFT", _G.QuestLogDetailFrame, "TOPRIGHT", 4, -34)
	_G.QuestNPCModelTextFrame:StripTextures()
	_G.QuestNPCModelTextFrame:CreateBackdrop()
	_G.QuestNPCModelTextFrame.backdrop:Point("TOPLEFT", _G.QuestNPCModel.backdrop, "BOTTOMLEFT", 0, -2)

	local QuestLogPopupDetailFrame = _G.QuestLogPopupDetailFrame
	S:HandlePortraitFrame(QuestLogPopupDetailFrame)

	S:HandleButton(_G.QuestLogPopupDetailFrameAbandonButton)
	S:HandleButton(_G.QuestLogPopupDetailFrameShareButton)
	S:HandleButton(_G.QuestLogPopupDetailFrameTrackButton)
	_G.QuestLogPopupDetailFrameScrollFrame:StripTextures()
	S:HandleScrollBar(_G.QuestLogPopupDetailFrameScrollFrameScrollBar)
	QuestLogPopupDetailFrame:SetTemplate("Transparent")

	_G.QuestLogPopupDetailFrameScrollFrame:HookScript('OnShow', function(self)
		if not _G.QuestLogPopupDetailFrameScrollFrame.backdrop then
			_G.QuestLogPopupDetailFrameScrollFrame:CreateBackdrop()
			_G.QuestLogPopupDetailFrameScrollFrame:Height(self:GetHeight() - 2)
			if not E.private.skins.parchmentRemover.enable then
				StyleScrollFrame(_G.QuestLogPopupDetailFrameScrollFrame, 509, 630, false)
			end
		end
		if not E.private.skins.parchmentRemover.enable then
			_G.QuestLogPopupDetailFrameScrollFrame.spellTex:Height(self:GetHeight() + 217)
		end
	end)

	S:HandleScrollBar(_G.QuestMapDetailsScrollFrameScrollBar)

	QuestLogPopupDetailFrame.ShowMapButton:StripTextures()
	S:HandleButton(QuestLogPopupDetailFrame.ShowMapButton)
	QuestLogPopupDetailFrame.ShowMapButton.Text:ClearAllPoints()
	QuestLogPopupDetailFrame.ShowMapButton.Text:Point("CENTER")
	QuestLogPopupDetailFrame.ShowMapButton:Size(QuestLogPopupDetailFrame.ShowMapButton:GetWidth() - 30, QuestLogPopupDetailFrame.ShowMapButton:GetHeight(), - 40)

	-- Skin the +/- buttons in the QuestLog
	hooksecurefunc("QuestLogQuests_Update", function()
		for i = 6, _G.QuestMapFrame.QuestsFrame.Contents:GetNumChildren() do
			local child = select(i, _G.QuestMapFrame.QuestsFrame.Contents:GetChildren())
			if child and child.ButtonText and not child.Text then
				if not child.buttonSized then
					child:Size(16, 16)
					child.buttonSized = true
				end

				local tex = select(2, child:GetRegions())
				if tex and tex.GetTexture then
					local texture = tex:GetTexture()
					local texType = type(texture)
					if texType == 'number' or texType == 'string' then
						if (texType == 'number' and PlusButtonIDs[texture])
						or (texType == 'string' and strfind(texture, "PlusButton")) then
							tex:SetTexture(E.Media.Textures.PlusButton)
						else
							tex:SetTexture(E.Media.Textures.MinusButton)
						end
					end
				end
			end
		end
	end)
end

S:AddCallback("Quest", LoadSkin)
