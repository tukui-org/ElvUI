local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local gsub = gsub
local pairs = pairs
local select = select
local unpack = unpack
--WoW API / Variables
local GetMoney = GetMoney
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_QuestLog_GetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function StyleScrollFrame(scrollFrame, widthOverride, heightOverride, inset)
	scrollFrame:SetTemplate()
	if not scrollFrame.spellTex then
		scrollFrame.spellTex = scrollFrame:CreateTexture(nil, 'ARTWORK')
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

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end

	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)

	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	QuestProgressScrollFrame:StripTextures()

	QuestGreetingScrollFrame:StripTextures()
	S:HandleScrollBar(QuestGreetingScrollFrameScrollBar)

	QuestInfoSkillPointFrame:StripTextures()
	QuestInfoSkillPointFrame:StyleButton()
	QuestInfoSkillPointFrame:Width(QuestInfoSkillPointFrame:GetWidth() - 4)
	QuestInfoSkillPointFrame:SetFrameLevel(QuestInfoSkillPointFrame:GetFrameLevel() + 2)
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(unpack(E.TexCoords))
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameIconTexture:Point("TOPLEFT", 2, -2)
	QuestInfoSkillPointFrameIconTexture:Size(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
	QuestInfoSkillPointFrame:CreateBackdrop("Default")
	QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")

	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:SetTemplate("Default", nil, true)
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight.backdropTexture:SetAlpha(0)
	QuestInfoItemHighlight:Size(142, 40)

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(self.Icon)

		self.Name:SetTextColor(1, 1, 0)

		local parent = self:GetParent()
		for i=1, #parent.RewardButtons do
			local questItem = QuestInfoRewardsFrame.RewardButtons[i]
			if(questItem ~= self) then
				questItem.Name:SetTextColor(1, 1, 1)
			end
		end
	end)

	QuestRewardScrollFrame:CreateBackdrop('Default')
	QuestRewardScrollFrame:Height(QuestRewardScrollFrame:GetHeight() - 2)

	hooksecurefunc("QuestInfo_Display", function()
		for i = 1, #QuestInfoRewardsFrame.RewardButtons do
			local questItem = QuestInfoRewardsFrame.RewardButtons[i]
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
		if E.private.skins.parchmentRemover.enable then
			QuestInfoTitleHeader:SetTextColor(1, .8, .1)
			QuestInfoDescriptionHeader:SetTextColor(1, .8, .1)
			QuestInfoObjectivesHeader:SetTextColor(1, .8, .1)
			QuestInfoRewardsFrame.Header:SetTextColor(1, .8, .1)
			QuestInfoDescriptionText:SetTextColor(1, 1, 1)
			QuestInfoObjectivesText:SetTextColor(1, 1, 1)
			QuestInfoGroupSize:SetTextColor(1, 1, 1)
			QuestInfoRewardText:SetTextColor(1, 1, 1)
			QuestInfoQuestType:SetTextColor(1, 1, 1)
			QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1, 1, 1)
			QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)
			if (QuestInfoRewardsFrame.SpellLearnText) then
				QuestInfoRewardsFrame.SpellLearnText:SetTextColor(1, 1, 1)
			end
			QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1, 1, 1)
			QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
			local numObjectives = GetNumQuestLeaderBoards()
			local numVisibleObjectives = 0
			for i = 1, numObjectives do
				local _, type, finished = GetQuestLogLeaderBoard(i)
				if type ~= 'spell' then
					numVisibleObjectives = numVisibleObjectives + 1
					local objective = _G['QuestInfoObjective'..numVisibleObjectives]
					if objective then
						if finished then
							objective:SetTextColor(1, .8, .1)
						else
							objective:SetTextColor(0.6, 0.6, 0.6)
						end
					end
				end
			end
		end
	end)

	local rewardFrames = {
		["MoneyFrame"] = true,
		["XPFrame"] = true,
		["SkillPointFrame"] = true, -- this may have extra textures.. need to check on it when possible
		["HonorFrame"] = true,
		["ArtifactXPFrame"] = true,
		["TitleFrame"] = true,
	}

	local function HandleReward(frame)
		if frame.backdrop then return end
		frame.NameFrame:SetAlpha(0)
		frame.Icon:SetTexCoord(unpack(E.TexCoords))
		frame:CreateBackdrop()
		frame.backdrop:SetOutside(frame.Icon)
		frame.Name:FontTemplate()
		frame.Count:ClearAllPoints()
		frame.Count:Point("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)

		if(frame.CircleBackground) then
			frame.CircleBackground:SetAlpha(0)
			frame.CircleBackgroundGlow:SetAlpha(0)
		end
	end

	for frame in pairs(rewardFrames) do
		HandleReward(MapQuestInfoRewardsFrame[frame])
	end

	-- Hook for WorldQuestRewards / QuestLogRewards
	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local rewardButton = rewardsFrame.RewardButtons[index]
		local mapButton = MapQuestInfoRewardsFrame.RewardButtons[index]

		if(mapButton and not mapButton.IsSkinned) then
			HandleReward(mapButton)
			mapButton.IsSkinned = true
		end

		if(rewardButton and not rewardButton.skinned) then
			rewardButton.NameFrame:Hide()
			rewardButton.Icon:SetTexCoord(unpack(E.TexCoords))
			rewardButton.IconBorder:SetAlpha(0)
			rewardButton:CreateBackdrop("Default")
			rewardButton.backdrop:SetOutside(rewardButton.Icon)
			rewardButton.Icon:SetDrawLayer("OVERLAY")
			rewardButton.Count:SetDrawLayer("OVERLAY")

			hooksecurefunc(rewardButton.IconBorder, "SetVertexColor", function(self, r, g, b)
				self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
				self:SetTexture("")
			end)
			hooksecurefunc(rewardButton.IconBorder, "Hide", function(self)
				self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end)

			rewardButton.skinned = true
		end
	end)

	--Reward: Title
	QuestInfoPlayerTitleFrame.FrameLeft:SetTexture(nil)
	QuestInfoPlayerTitleFrame.FrameCenter:SetTexture(nil)
	QuestInfoPlayerTitleFrame.FrameRight:SetTexture(nil)
	QuestInfoPlayerTitleFrame.Icon:SetTexCoord(unpack(E.TexCoords))
	QuestInfoPlayerTitleFrame:CreateBackdrop("Default")
	QuestInfoPlayerTitleFrame.backdrop:SetOutside(QuestInfoPlayerTitleFrame.Icon)

	--Quest Frame
	QuestFrame:StripTextures(true)
	QuestFrameInset:Kill()
	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollFrame:SetTemplate()

	QuestProgressScrollFrame:SetTemplate()

	QuestGreetingScrollFrame:SetTemplate()

	if E.private.skins.parchmentRemover.enable then
		hooksecurefunc('QuestFrameProgressItems_Update', function()
			QuestProgressRequiredItemsText:SetTextColor(1, .8, .1)
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
					QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
				else
					QuestInfoRequiredMoneyText:SetTextColor(1, .8, .1)
				end
			end
		end)

		for i = 1, C_QuestLog_GetMaxNumQuestsCanAccept() do
			local button = _G['QuestTitleButton'..i]
			if button then
				hooksecurefunc(button, 'SetFormattedText', function()
					if button:GetFontString() then
						if button:GetFontString():GetText() and button:GetFontString():GetText():find('|cff000000') then
							button:GetFontString():SetText(gsub(button:GetFontString():GetText(), '|cff000000', '|cffffe519'))
						end
					end
				end)
			end
		end

		if (QuestInfoRewardsFrame.spellHeaderPool) then
			for _, pool in pairs({"followerRewardPool", "spellRewardPool"}) do
				QuestInfoRewardsFrame[pool]._acquire = QuestInfoRewardsFrame[pool].Acquire
				QuestInfoRewardsFrame[pool].Acquire = function(self)
					local frame = QuestInfoRewardsFrame[pool]:_acquire()
					frame.Name:SetTextColor(1, 1, 1)
					return frame
				end
			end
			QuestInfoRewardsFrame.spellHeaderPool._acquire = QuestInfoRewardsFrame.spellHeaderPool.Acquire
			QuestInfoRewardsFrame.spellHeaderPool.Acquire = function(self)
				local frame = self:_acquire()
				frame:SetTextColor(1, 1, 1)
				return frame
			end
		end
	else
		StyleScrollFrame(QuestDetailScrollFrame, 506, 615, true)
		StyleScrollFrame(QuestProgressScrollFrame, 506, 615, true)
		StyleScrollFrame(QuestGreetingScrollFrame, 506, 615, true)
		QuestRewardScrollFrame:HookScript('OnShow', function(self)
			StyleScrollFrame(self, 506, 615, true)
		end)
	end

	QuestFrameGreetingPanel:StripTextures(true)
	S:HandleButton(QuestFrameGreetingGoodbyeButton, true)
	QuestGreetingFrameHorizontalBreak:Kill()

	QuestDetailScrollChildFrame:StripTextures(true)
	QuestRewardScrollFrame:StripTextures(true)
	QuestRewardScrollChildFrame:StripTextures(true)
	QuestFrameProgressPanel:StripTextures(true)
	QuestFrameRewardPanel:StripTextures(true)
	QuestFrame:CreateBackdrop("Transparent")
	S:HandleButton(QuestFrameAcceptButton, true)
	S:HandleButton(QuestFrameDeclineButton, true)
	S:HandleButton(QuestFrameCompleteButton, true)
	S:HandleButton(QuestFrameGoodbyeButton, true)
	S:HandleButton(QuestFrameCompleteQuestButton, true)
	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)

	for i=1, 6 do
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

	QuestNPCModel:StripTextures()
	QuestNPCModel:CreateBackdrop("Transparent")
	QuestNPCModel:Point("TOPLEFT", QuestLogDetailFrame, "TOPRIGHT", 4, -34)
	QuestNPCModelTextFrame:StripTextures()
	QuestNPCModelTextFrame:CreateBackdrop("Default")
	QuestNPCModelTextFrame.backdrop:Point("TOPLEFT", QuestNPCModel.backdrop, "BOTTOMLEFT", 0, -2)

	QuestLogPopupDetailFrame:StripTextures()
	QuestLogPopupDetailFrameInset:StripTextures()
	S:HandleButton(QuestLogPopupDetailFrameAbandonButton)
	S:HandleButton(QuestLogPopupDetailFrameShareButton)
	S:HandleButton(QuestLogPopupDetailFrameTrackButton)
	QuestLogPopupDetailFrameScrollFrame:StripTextures()
	S:HandleScrollBar(QuestLogPopupDetailFrameScrollFrameScrollBar)
	QuestLogPopupDetailFrame:SetTemplate("Transparent")

	QuestLogPopupDetailFrameScrollFrame:HookScript('OnShow', function(self)
		if not QuestLogPopupDetailFrameScrollFrame.backdrop then
			QuestLogPopupDetailFrameScrollFrame:CreateBackdrop("Default")
			QuestLogPopupDetailFrameScrollFrame:Height(self:GetHeight() - 2)
			if not E.private.skins.parchmentRemover.enable then
				StyleScrollFrame(QuestLogPopupDetailFrameScrollFrame, 509, 630, false)
			end
		end
		if not E.private.skins.parchmentRemover.enable then
			QuestLogPopupDetailFrameScrollFrame.spellTex:Height(self:GetHeight() + 217)
		end
	end)

	S:HandleCloseButton(QuestLogPopupDetailFrameCloseButton)
	S:HandleScrollBar(QuestMapDetailsScrollFrameScrollBar)

	QuestLogPopupDetailFrame.ShowMapButton:StripTextures()
	S:HandleButton(QuestLogPopupDetailFrame.ShowMapButton)
	QuestLogPopupDetailFrame.ShowMapButton.Text:ClearAllPoints()
	QuestLogPopupDetailFrame.ShowMapButton.Text:Point("CENTER")
	QuestLogPopupDetailFrame.ShowMapButton:Size(QuestLogPopupDetailFrame.ShowMapButton:GetWidth() - 30, QuestLogPopupDetailFrame.ShowMapButton:GetHeight(), - 40)

	-- Skin the +/- buttons in the QuestLog
	hooksecurefunc("QuestLogQuests_Update", function()
		local tex, texture
		for i = 6, QuestMapFrame.QuestsFrame.Contents:GetNumChildren() do
			local child = select(i, QuestMapFrame.QuestsFrame.Contents:GetChildren())
			if child and child.ButtonText and not child.Text then
				if not child.buttonSized then
					child:Size(16, 16)
					child.buttonSized = true
				end

				tex = select(2, child:GetRegions())
				if tex and tex.GetTexture then
					texture = tex:GetTexture()
					if texture then
						if texture:find("PlusButton") then
							tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusButton")
						else
							tex:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\MinusButton")
						end
					end
				end
			end
		end
	end)
end

S:AddCallback("Quest", LoadSkin)
