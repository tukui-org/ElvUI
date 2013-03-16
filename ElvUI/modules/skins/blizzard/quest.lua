local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function StyleScrollFrame(scrollFrame, widthOverride, heightOverride, inset)
	scrollFrame:SetTemplate()	
	scrollFrame.spellTex = scrollFrame:CreateTexture(nil, 'ARTWORK')
	scrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
	if inset then
		scrollFrame.spellTex:SetPoint("TOPLEFT", 2, -2)
	else
		scrollFrame.spellTex:SetPoint("TOPLEFT")
	end
	scrollFrame.spellTex:Size(widthOverride or 506, heightOverride or 615)
	scrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)	
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then return end
	S:HandleCloseButton(QuestLogFrameCloseButton)
	S:HandleScrollBar(QuestLogDetailScrollFrameScrollBar)
	S:HandleScrollBar(QuestLogScrollFrameScrollBar, 5)
	S:HandleScrollBar(QuestProgressScrollFrameScrollBar)
	S:HandleScrollBar(QuestRewardScrollFrameScrollBar)
	QuestLogScrollFrame:StripTextures()
	QuestLogFrame:StripTextures()
	QuestLogFrame:SetTemplate("Transparent")
	QuestLogCount:StripTextures()
	QuestLogCount:SetTemplate("Default")
	QuestLogCount.backdropTexture:SetDrawLayer('BACKGROUND', 2)
	EmptyQuestLogFrame:StripTextures()
	QuestLogDetailFrameInset:Kill()
	S:HandleScrollBar(QuestDetailScrollFrameScrollBar)
	QuestProgressScrollFrame:StripTextures()
	QuestLogFrameShowMapButton:StripTextures()
	S:HandleButton(QuestLogFrameShowMapButton)
	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:SetPoint("CENTER")
	QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40)
	QuestGreetingScrollFrame:StripTextures()
	S:HandleScrollBar(QuestGreetingScrollFrameScrollBar)
	
	QuestLogFrameInset:Kill()
	QuestLogFrameCompleteButton:StripTextures()
	local buttons = {
		"QuestLogFrameAbandonButton",
		"QuestLogFramePushQuestButton",
		"QuestLogFrameTrackButton",
		"QuestLogFrameCancelButton",
		"QuestLogFrameCompleteButton",
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
	QuestLogFrame:HookScript("OnShow", function()
		if not QuestLogScrollFrame.spellTex  then
			QuestLogScrollFrame:SetTemplate("Default")
			QuestLogScrollFrame.spellTex = QuestLogScrollFrame:CreateTexture(nil, 'ARTWORK')
			QuestLogScrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBookBG]])
			QuestLogScrollFrame.spellTex:SetPoint("TOPLEFT", 2, -2)
			QuestLogScrollFrame.spellTex:Size(514, 616)
			QuestLogScrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)

			QuestLogScrollFrame.spellTex2 = QuestLogScrollFrame:CreateTexture(nil, 'BORDER')
			QuestLogScrollFrame.spellTex2:SetTexture([[Interface\FrameGeneral\UI-Background-Rock]])
			QuestLogScrollFrame.spellTex2:SetInside()
		end
	end)
	QuestLogDetailScrollFrame:HookScript('OnShow', function(self)
		if not QuestLogDetailScrollFrame.backdrop then
			QuestLogDetailScrollFrame:CreateBackdrop("Default")	
			StyleScrollFrame(QuestLogDetailScrollFrame, 509, 630, false)		
			QuestLogDetailScrollFrame:Height(self:GetHeight() - 2)
		end
		QuestLogDetailScrollFrame.spellTex:Height(self:GetHeight() + 217)
	end)
	
	QuestRewardScrollFrame:HookScript('OnShow', function(self)
		if not self.backdrop then
			self:CreateBackdrop("Default")	
			StyleScrollFrame(self, 509, 630, false)		
			self:Height(self:GetHeight() - 2)
		end
		self.spellTex:Height(self:GetHeight() + 217)	
	end)
		
	hooksecurefunc("QuestInfo_Display", function(template, parentFrame)
		  for i = 1, MAX_NUM_ITEMS do
			local questItem = _G["QuestInfoItem"..i]
			if not questItem:IsShown() then break end

			local point, relativeTo, relativePoint, x, y = questItem:GetPoint()
			if i == 1 then
			    questItem:Point(point, relativeTo, relativePoint, 0, y)
			elseif relativePoint == "BOTTOMLEFT" then
			    questItem:Point(point, relativeTo, relativePoint, 0, -4)
			else
			    questItem:Point(point, relativeTo, relativePoint, 4, 0)
			end
		  end
	    end)
	
	
	--Quest Frame
	QuestFrame:StripTextures(true)
	QuestFrameInset:Kill()
	QuestFrameDetailPanel:StripTextures(true)
	QuestDetailScrollFrame:StripTextures(true)
	QuestDetailScrollFrame:SetTemplate()	
	StyleScrollFrame(QuestDetailScrollFrame, 506, 615, true)	

	QuestProgressScrollFrame:SetTemplate()	
	StyleScrollFrame(QuestProgressScrollFrame, 506, 615, true)	
	
	QuestGreetingScrollFrame:SetTemplate()
	StyleScrollFrame(QuestGreetingScrollFrame, 506, 615, true)
	
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