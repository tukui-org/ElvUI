local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.quest ~= true then return end
	S:HandleCloseButton(QuestLogFrameCloseButton)
	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogScrollFrameScrollBar, 5)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)
	QuestLogFrame:StripTextures()
	QuestLogFrame:SetTemplate("Transparent")
	QuestLogFrame:CreateShadow("Default")
	QuestLogCount:StripTextures()
	QuestLogCount:SetTemplate("Default")
	QuestLogCount.backdropTexture:SetDrawLayer('BACKGROUND', 2)
	
	EmptyQuestLogFrame:StripTextures()
	
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	
	QuestLogFrameShowMapButton:StripTextures()
	S:HandleButton(QuestLogFrameShowMapButton)
	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:SetPoint("CENTER")
	QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40)
	
	local buttons = {
		"QuestLogFrameAbandonButton",
		"QuestLogFramePushQuestButton",
		"QuestLogFrameTrackButton",
		"QuestLogFrameCancelButton",
	}
	
	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end
	QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2, 0)
	QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", -2, 0)

	for i=1, MAX_NUM_ITEMS do
		_G["QuestInfoItem"..i]:StripTextures()
		_G["QuestInfoItem"..i]:StyleButton()
		_G["QuestInfoItem"..i]:Width(_G["QuestInfoItem"..i]:GetWidth() - 4)
		_G["QuestInfoItem"..i]:SetFrameLevel(_G["QuestInfoItem"..i]:GetFrameLevel() + 2)
		_G["QuestInfoItem"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["QuestInfoItem"..i.."IconTexture"]:SetDrawLayer("OVERLAY")
		_G["QuestInfoItem"..i.."IconTexture"]:Point("TOPLEFT", 2, -2)
		_G["QuestInfoItem"..i.."IconTexture"]:Size(_G["QuestInfoItem"..i.."IconTexture"]:GetWidth() - 2, _G["QuestInfoItem"..i.."IconTexture"]:GetHeight() - 2)
		_G["QuestInfoItem"..i]:SetTemplate("Default")
		_G["QuestInfoItem"..i].backdropTexture:SetDrawLayer('BACKGROUND', 2)
		_G["QuestInfoItem"..i.."Count"]:SetDrawLayer("OVERLAY")
	end
	
	QuestInfoSkillPointFrame:StripTextures()
	QuestInfoSkillPointFrame:StyleButton()
	QuestInfoSkillPointFrame:Width(QuestInfoSkillPointFrame:GetWidth() - 4)
	QuestInfoSkillPointFrame:SetFrameLevel(QuestInfoSkillPointFrame:GetFrameLevel() + 2)
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(unpack(E.TexCoords))
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameIconTexture:Point("TOPLEFT", 2, -2)
	QuestInfoSkillPointFrameIconTexture:Size(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
	QuestInfoSkillPointFrame:SetTemplate("Default")
	QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFramePoints:ClearAllPoints()
	QuestInfoSkillPointFramePoints:Point("BOTTOMRIGHT", QuestInfoSkillPointFrameIconTexture, "BOTTOMRIGHT")
	
	QuestInfoItemHighlight:StripTextures()
	QuestInfoItemHighlight:SetTemplate("Default", nil, true)
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight.backdropTexture:SetAlpha(0)
	QuestInfoItemHighlight:Size(142, 40)
	
	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetAllPoints(self)
	end)
	
	--Everything here to make the text a readable color
	local function QuestObjectiveText()
		local numObjectives = GetNumQuestLeaderBoards()
		local objective
		local type, finished
		local numVisibleObjectives = 0
		for i = 1, numObjectives do
			_, type, finished = GetQuestLogLeaderBoard(i)
			if (type ~= "spell") then
				numVisibleObjectives = numVisibleObjectives+1
				objective = _G["QuestInfoObjective"..numVisibleObjectives]
				if ( finished ) then
					objective:SetTextColor(1, 1, 0)
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end			
	end
	
	hooksecurefunc("QuestInfo_Display", function(template, parentFrame, acceptButton, material)								
		local textColor = {1, 1, 1}
		local titleTextColor = {1, 1, 0}
		
		-- headers
		QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
		QuestInfoRewardsHeader:SetTextColor(unpack(titleTextColor))
		-- other text
		QuestInfoDescriptionText:SetTextColor(unpack(textColor))
		QuestInfoObjectivesText:SetTextColor(unpack(textColor))
		QuestInfoGroupSize:SetTextColor(unpack(textColor))
		QuestInfoRewardText:SetTextColor(unpack(textColor))
		-- reward frame text
		QuestInfoItemChooseText:SetTextColor(unpack(textColor))
		QuestInfoItemReceiveText:SetTextColor(unpack(textColor))
		QuestInfoSpellLearnText:SetTextColor(unpack(textColor))
		QuestInfoXPFrameReceiveText:SetTextColor(unpack(textColor))	
		
		QuestObjectiveText()
	end)
	
	hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if ( requiredMoney > 0 ) then
			if ( requiredMoney > GetMoney() ) then
				-- Not enough money
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(1, 1, 0)
			end
		end			
	end)		
	
	QuestLogFrame:HookScript("OnShow", function()
		QuestLogScrollFrame:Height(331)
		QuestLogDetailScrollFrame:Height(328)
		
		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogScrollFrame:SetTemplate("Default")
			QuestLogDetailScrollFrame:CreateBackdrop("Default")
		end
	end)
	
	--Quest Frame
	QuestFrame:StripTextures(true)
	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollChildFrame:StripTextures(true)
	QuestRewardScrollFrame:StripTextures(true)
	QuestRewardScrollChildFrame:StripTextures(true)
	QuestFrameProgressPanel:StripTextures(true)
	QuestFrameRewardPanel:StripTextures(true)
	QuestFrame:CreateBackdrop("Transparent")
	QuestFrame.backdrop:Point("TOPLEFT", 6, -8)
	QuestFrame.backdrop:Point("BOTTOMRIGHT", -20, 65)
	QuestFrame.backdrop:CreateShadow("Default")
	S:HandleButton(QuestFrameAcceptButton, true)
	S:HandleButton(QuestFrameDeclineButton, true)
	S:HandleButton(QuestFrameCompleteButton, true)
	S:HandleButton(QuestFrameGoodbyeButton, true)
	S:HandleButton(QuestFrameCompleteQuestButton, true)
	S:HandleCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)
	
	for i=1, 6 do
		local button = _G["QuestProgressItem"..i]
		local texture = _G["QuestProgressItem"..i.."IconTexture"]
		button:StripTextures()
		button:StyleButton()
		button:Width(_G["QuestProgressItem"..i]:GetWidth() - 4)
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		texture:SetTexCoord(unpack(E.TexCoords))
		texture:SetDrawLayer("OVERLAY")
		texture:Point("TOPLEFT", 2, -2)
		texture:Size(texture:GetWidth() - 2, texture:GetHeight() - 2)
		_G["QuestProgressItem"..i.."Count"]:SetDrawLayer("OVERLAY")
		button:SetTemplate("Default")				
	end
	
	hooksecurefunc("QuestFrameProgressItems_Update", function()
		QuestProgressTitleText:SetTextColor(1, 1, 0)
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetTextColor(1, 1, 0)
		QuestProgressRequiredMoneyText:SetTextColor(1, 1, 0)
	end)
	
	QuestNPCModel:StripTextures()
	QuestNPCModel:CreateBackdrop("Transparent")
	QuestNPCModel:Point("TOPLEFT", QuestLogDetailFrame, "TOPRIGHT", 4, -34)
	QuestNPCModelTextFrame:StripTextures()
	QuestNPCModelTextFrame:CreateBackdrop("Default")
	QuestNPCModelTextFrame.backdrop:Point("TOPLEFT", QuestNPCModel.backdrop, "BOTTOMLEFT", 0, -2)
	QuestLogDetailFrame:StripTextures()
	QuestLogDetailFrame:SetTemplate("Transparent")
	QuestLogDetailScrollFrame:StripTextures()
	S:HandleCloseButton(QuestLogDetailFrameCloseButton)
	
	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, portrait, text, name, x, y)
		QuestNPCModel:ClearAllPoints();
		QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x + 18, y);			
	end)	
end

S:RegisterSkin('ElvUI', LoadSkin)