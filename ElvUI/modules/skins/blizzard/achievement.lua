local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.achievement ~= true then return end
	local frames = {
		"AchievementFrame",
		"AchievementFrameCategories",
		"AchievementFrameSummary",
		"AchievementFrameHeader",
		"AchievementFrameSummaryCategoriesHeader",
		"AchievementFrameSummaryAchievementsHeader",
		"AchievementFrameStatsBG",
		"AchievementFrameAchievements",
		"AchievementFrameComparison",
		"AchievementFrameComparisonHeader",
		"AchievementFrameComparisonSummaryPlayer",
		"AchievementFrameComparisonSummaryFriend",
	}
	
	for _, frame in pairs(frames) do
		_G[frame]:StripTextures(true)
	end
	
	local noname_frames = {
		"AchievementFrameStats",
		"AchievementFrameSummary",
		"AchievementFrameAchievements",
		"AchievementFrameComparison"
	}
	
	for _, frame in pairs(noname_frames) do
		for i=1, _G[frame]:GetNumChildren() do
			local child = select(i, _G[frame]:GetChildren())
			if child and not child:GetName() then
				child:SetBackdrop(nil)
			end
		end
	end
	
	AchievementFrame:CreateBackdrop("Transparent")
	AchievementFrame.backdrop:Point("TOPLEFT", 0, 6)
	AchievementFrame.backdrop:SetPoint("BOTTOMRIGHT")
	AchievementFrameHeaderTitle:ClearAllPoints()
	AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame.backdrop, "TOPLEFT", -30, -8)
	AchievementFrameHeaderPoints:ClearAllPoints()
	AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0)
	
	--Backdrops
	AchievementFrameCategoriesContainer:CreateBackdrop("Default")
	AchievementFrameCategoriesContainer.backdrop:Point("TOPLEFT", 0, 4)
	AchievementFrameCategoriesContainer.backdrop:Point("BOTTOMRIGHT", -2, -3)
	AchievementFrameAchievementsContainer:CreateBackdrop("Default")
	AchievementFrameAchievementsContainer.backdrop:Point("TOPLEFT", 0, 2)
	AchievementFrameAchievementsContainer.backdrop:Point("BOTTOMRIGHT", -3, -3)
	
	S:HandleCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop)
	S:HandleDropDownBox(AchievementFrameFilterDropDown)
	AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -44, 5)
	
	-- ScrollBars
	S:HandleScrollBar(AchievementFrameCategoriesContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameAchievementsContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameStatsContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameComparisonContainerScrollBar, 5)
	S:HandleScrollBar(AchievementFrameComparisonStatsContainerScrollBar, 5)
	
	--Tabs
	for i = 1, 3 do
		S:HandleTab(_G["AchievementFrameTab"..i])
		_G["AchievementFrameTab"..i]:SetFrameLevel(_G["AchievementFrameTab"..i]:GetFrameLevel() + 2)
	end
	
	local function SkinStatusBar(bar)
		bar:StripTextures()
		bar:SetStatusBarTexture(E["media"].normTex)
		bar:SetStatusBarColor(4/255, 179/255, 30/255)
		bar:CreateBackdrop("Default")
		
		if _G[bar:GetName().."Title"] then
			_G[bar:GetName().."Title"]:SetPoint("LEFT", 4, 0)
		end

		if _G[bar:GetName().."Label"] then
			_G[bar:GetName().."Label"]:SetPoint("LEFT", 4, 0)
		end
		
		if _G[bar:GetName().."Text"] then
			_G[bar:GetName().."Text"]:SetPoint("RIGHT", -4, 0)
		end
	end

	SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar)
	SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar)
	SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar)
	AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	AchievementFrameComparisonSummaryFriendStatusBar.text:SetPoint("CENTER")
	AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -20)
	
	for i=1, 10 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]
		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()
		
		_G[highlight:GetName().."Middle"]:SetTexture(1, 1, 1, 0.3)
		_G[highlight:GetName().."Middle"]:SetAllPoints(frame)
	end
	
	AchievementFrame:HookScript("OnShow", function(self)
		if self.containerSkined then return; end
		for i=1, 20 do
			local frame = _G["AchievementFrameCategoriesContainerButton"..i]
			local lastframe = _G["AchievementFrameCategoriesContainerButton"..i-1]
			
			frame:StripTextures()
			frame:StyleButton()				
		end	
		self.containerSkined = true
	end)
	
	hooksecurefunc('AchievementButton_DisplayAchievement', function(frame)
		if frame.accountWide and frame.bg3 then
			frame.bg3:SetTexture(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
		elseif frame.bg3 then
			frame.bg3:SetTexture(unpack(E.media.bordercolor))
		end			
	end)
	
	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local frame = _G["AchievementFrameSummaryAchievement"..i]
			_G["AchievementFrameSummaryAchievement"..i.."Highlight"]:Kill()
			frame:StripTextures()
			
			
			_G["AchievementFrameSummaryAchievement"..i.."Description"]:SetTextColor(0.6, 0.6, 0.6)

			if not frame.backdrop then
				frame:CreateBackdrop("Default", true)
				frame.backdrop:SetInside()

				_G["AchievementFrameSummaryAchievement"..i.."IconBling"]:Kill()
				_G["AchievementFrameSummaryAchievement"..i.."IconOverlay"]:Kill()
				_G["AchievementFrameSummaryAchievement"..i.."Icon"]:SetTemplate("Default")
				_G["AchievementFrameSummaryAchievement"..i.."Icon"]:Height(_G["AchievementFrameSummaryAchievement"..i.."Icon"]:GetHeight() - 14)
				_G["AchievementFrameSummaryAchievement"..i.."Icon"]:Width(_G["AchievementFrameSummaryAchievement"..i.."Icon"]:GetWidth() - 14)
				_G["AchievementFrameSummaryAchievement"..i.."Icon"]:ClearAllPoints()
				_G["AchievementFrameSummaryAchievement"..i.."Icon"]:Point("LEFT", 6, 0)
				_G["AchievementFrameSummaryAchievement"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
				_G["AchievementFrameSummaryAchievement"..i.."IconTexture"]:SetInside()
			end
			
			if frame.accountWide then
				frame.backdrop:SetBackdropBorderColor(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
			else
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end					
		end				
	end)

	for i=1, 7 do
		local frame = _G["AchievementFrameAchievementsContainerButton"..i]
		_G["AchievementFrameAchievementsContainerButton"..i.."Highlight"]:Kill()
		frame:StripTextures(true)

		--Initiate fucked up method of creating a backdrop
		if not E.PixelMode then
			frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg1:SetDrawLayer("BACKGROUND", 4)
			frame.bg1:SetTexture(E["media"].normTex) --Default TukUI users this is normTex, normTex doesn't exist
			frame.bg1:SetVertexColor(unpack(E['media'].backdropcolor))
			frame.bg1:Point("TOPLEFT", E.mult*4, -E.mult*4)
			frame.bg1:Point("BOTTOMRIGHT", -E.mult*4, E.mult*4)				
			
			frame.bg2 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg2:SetDrawLayer("BACKGROUND", 3)
			frame.bg2:SetTexture(0,0,0)
			frame.bg2:Point("TOPLEFT", E.mult*3, -E.mult*3)
			frame.bg2:Point("BOTTOMRIGHT", -E.mult*3, E.mult*3)
		
			frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg3:SetDrawLayer("BACKGROUND", 2)
			frame.bg3:SetTexture(unpack(E['media'].bordercolor))
			frame.bg3:Point("TOPLEFT", E.mult*2, -E.mult*2)
			frame.bg3:Point("BOTTOMRIGHT", -E.mult*2, E.mult*2)			

			frame.bg4 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg4:SetDrawLayer("BACKGROUND", 1)
			frame.bg4:SetTexture(0,0,0)
			frame.bg4:Point("TOPLEFT", E.mult, -E.mult)
			frame.bg4:Point("BOTTOMRIGHT", -E.mult, E.mult)
		else
			frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg1:SetDrawLayer("BACKGROUND", 4)
			frame.bg1:SetTexture(E["media"].normTex) --Default TukUI users this is normTex, normTex doesn't exist
			frame.bg1:SetVertexColor(unpack(E['media'].backdropcolor))
			frame.bg1:Point("TOPLEFT", E.mult, -E.mult)
			frame.bg1:Point("BOTTOMRIGHT", -E.mult, E.mult)
		
			frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg3:SetDrawLayer("BACKGROUND", 2)
			frame.bg3:SetTexture(unpack(E['media'].bordercolor))
			frame.bg3:SetOutside(E.mult)			
		end

		_G["AchievementFrameAchievementsContainerButton"..i.."Description"]:SetTextColor(0.6, 0.6, 0.6)
		hooksecurefunc(_G["AchievementFrameAchievementsContainerButton"..i.."Description"], "SetTextColor", function(self, r, g, b)
			if r ~= 0.6 or g ~= 0.6 or b ~= 0.6 then
				self:SetTextColor(0.6, 0.6, 0.6)
			end
		end)

		_G["AchievementFrameAchievementsContainerButton"..i.."HiddenDescription"]:SetTextColor(1, 1, 1)
		hooksecurefunc(_G["AchievementFrameAchievementsContainerButton"..i.."HiddenDescription"], "SetTextColor", function(self, r, g, b)
			if r ~= 1 or g ~= 1 or b ~= 1 then
				self:SetTextColor(1, 1, 1)
			end
		end)
		
		_G["AchievementFrameAchievementsContainerButton"..i.."IconBling"]:Kill()
		_G["AchievementFrameAchievementsContainerButton"..i.."IconOverlay"]:Kill()
		_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:SetTemplate('Default')
		_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:Height(_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:GetHeight() - 14)
		_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:Width(_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:GetWidth() - 14)	
		_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:ClearAllPoints()
		_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:Point("LEFT", 6, 0)
		_G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
		_G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]:SetInside()
		
		--_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"].oborder = "Don't use sharp border" --Needed for ElvUI only
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:StripTextures()
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:SetTemplate("Default")
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:Size(12, 12)
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:GetCheckedTexture():Point("TOPLEFT", -4, 4)
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:GetCheckedTexture():Point("BOTTOMRIGHT", 4, -4)
		
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:ClearAllPoints()
		_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
		
		hooksecurefunc(_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"], "SetPoint", function(self, point, attachTo, anchorPoint, xOffset, yOffset)
			if point ~= "BOTTOMLEFT" or attachTo ~= frame or anchorPoint ~= "BOTTOMLEFT" or xOffset ~= 5 or yOffset ~= 5 then
				self:ClearAllPoints()
				self:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)			
			end
		end)
	end

	
	local compares = {
		"Player",
		"Friend"
	}
	
	for _, compare in pairs(compares) do
		for i=1, 9 do
			local frame = "AchievementFrameComparisonContainerButton"..i..compare
			
			_G[frame]:StripTextures()
			_G[frame.."Background"]:Kill()

			if _G[frame.."Description"] then
				_G[frame.."Description"]:SetTextColor(0.6, 0.6, 0.6)
				hooksecurefunc(_G[frame.."Description"], "SetTextColor", function(self, r, g, b)
					if r ~= 0.6 or g ~= 0.6 or b ~= 0.6 then
						self:SetTextColor(0.6, 0.6, 0.6)
					end
				end)				
			end

			--Initiate fucked up method of creating a backdrop
			_G[frame].bg1 = _G[frame]:CreateTexture(nil, "BACKGROUND")
			_G[frame].bg1:SetDrawLayer("BACKGROUND", 4)
			_G[frame].bg1:SetTexture(E["media"].normTex) --Default TukUI users this is normTex, normTex doesn't exist
			_G[frame].bg1:SetVertexColor(unpack(E['media'].backdropcolor))
			_G[frame].bg1:Point("TOPLEFT", E.mult*4, -E.mult*4)
			_G[frame].bg1:Point("BOTTOMRIGHT", -E.mult*4, E.mult*4)				
			
			_G[frame].bg2 = _G[frame]:CreateTexture(nil, "BACKGROUND")
			_G[frame].bg2:SetDrawLayer("BACKGROUND", 3)
			_G[frame].bg2:SetTexture(0,0,0)
			_G[frame].bg2:Point("TOPLEFT", E.mult*3, -E.mult*3)
			_G[frame].bg2:Point("BOTTOMRIGHT", -E.mult*3, E.mult*3)
			
			_G[frame].bg3 = _G[frame]:CreateTexture(nil, "BACKGROUND")
			_G[frame].bg3:SetDrawLayer("BACKGROUND", 2)
			_G[frame].bg3:SetTexture(unpack(E['media'].bordercolor))
			_G[frame].bg3:Point("TOPLEFT", E.mult*2, -E.mult*2)
			_G[frame].bg3:Point("BOTTOMRIGHT", -E.mult*2, E.mult*2)			

			_G[frame].bg4 = _G[frame]:CreateTexture(nil, "BACKGROUND")
			_G[frame].bg4:SetDrawLayer("BACKGROUND", 1)
			_G[frame].bg4:SetTexture(0,0,0)
			_G[frame].bg4:Point("TOPLEFT", E.mult, -E.mult)
			_G[frame].bg4:Point("BOTTOMRIGHT", -E.mult, E.mult)	
			
			
			if compare == "Friend" then
				_G[frame.."Shield"]:Point("TOPRIGHT", _G["AchievementFrameComparisonContainerButton"..i.."Friend"], "TOPRIGHT", -20, -3)
			end
							
			_G[frame.."IconBling"]:Kill()
			_G[frame.."IconOverlay"]:Kill()
			_G[frame.."Icon"]:SetTemplate("Default")
			_G[frame.."Icon"]:Height(_G[frame.."Icon"]:GetHeight() - 14)
			_G[frame.."Icon"]:Width(_G[frame.."Icon"]:GetWidth() - 14)
			_G[frame.."Icon"]:ClearAllPoints()
			_G[frame.."Icon"]:Point("LEFT", 6, 0)
			_G[frame.."IconTexture"]:SetTexCoord(unpack(E.TexCoords))
			_G[frame.."IconTexture"]:SetInside()				
		end
	end
	
	hooksecurefunc('AchievementFrameComparison_DisplayAchievement', function(button)
		local player = button.player;
		local friend = button.friend;
		player.titleBar:Kill()
		friend.titleBar:Kill()
		
		if not player.bg3 or not friend.bg3 then return; end
		
		if player.accountWide then
			player.bg3:SetTexture(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
		else
			player.bg3:SetTexture(unpack(E.media.bordercolor))
		end		
		
		if friend.accountWide then
			friend.bg3:SetTexture(ACHIEVEMENTUI_BLUEBORDER_R, ACHIEVEMENTUI_BLUEBORDER_G, ACHIEVEMENTUI_BLUEBORDER_B)
		else
			friend.bg3:SetTexture(unpack(E.media.bordercolor))
		end				
	end)
	
	for i=1, 20 do
		local frame = _G["AchievementFrameStatsContainerButton"..i]
		frame:StyleButton()
		
		_G["AchievementFrameStatsContainerButton"..i.."BG"]:SetTexture(1, 1, 1, 0.2)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:Kill()
		_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:Kill()
		_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:Kill()
		
		local frame = "AchievementFrameComparisonStatsContainerButton"..i
		_G[frame]:StripTextures()
		_G[frame]:StyleButton()
	
		_G[frame.."BG"]:SetTexture(1, 1, 1, 0.2)
		_G[frame.."HeaderLeft"]:Kill()
		_G[frame.."HeaderRight"]:Kill()
		_G[frame.."HeaderMiddle"]:Kill()			
	end
	
	
	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local frame = _G["AchievementFrameProgressBar"..index]
		if frame then
			if not frame.skinned then
				frame:StripTextures()
				frame:SetStatusBarTexture(E["media"].normTex)
				frame:SetStatusBarColor(4/255, 179/255, 30/255)
				frame:SetFrameLevel(frame:GetFrameLevel() + 3)
				
				frame:Height(frame:GetHeight() - 2)
				
				--Initiate fucked up method of creating a backdrop
				if not E.PixelMode then
					frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg1:SetDrawLayer("BACKGROUND", -7)
					frame.bg1:SetTexture(E["media"].normTex) --Default TukUI users this is normTex, normTex doesn't exist
					frame.bg1:SetVertexColor(unpack(E['media'].backdropcolor))
					frame.bg1:Point("TOPLEFT", -E.mult*3, E.mult*3)
					frame.bg1:Point("BOTTOMRIGHT", E.mult*3, -E.mult*3)				
					
					frame.bg2 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg2:SetDrawLayer("BACKGROUND", -6)
					frame.bg2:SetTexture(unpack(E['media'].bordercolor))
					frame.bg2:Point("TOPLEFT", -E.mult*2, E.mult*2)
					frame.bg2:Point("BOTTOMRIGHT", E.mult*2, -E.mult*2)
				
					frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg3:SetDrawLayer("BACKGROUND", -5)
					frame.bg3:SetTexture(unpack(E['media'].backdropcolor))
					frame.bg3:Point("TOPLEFT", -E.mult, E.mult)
					frame.bg3:Point("BOTTOMRIGHT", E.mult, -E.mult)			
				else
					frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg1:SetDrawLayer("BACKGROUND", 4)
					frame.bg1:SetTexture(E["media"].normTex) --Default TukUI users this is normTex, normTex doesn't exist
					frame.bg1:SetVertexColor(unpack(E['media'].backdropcolor))
					frame.bg1:SetAllPoints()
				
					frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg3:SetDrawLayer("BACKGROUND", 2)
					frame.bg3:SetTexture(unpack(E['media'].bordercolor))
					frame.bg3:Point("TOPLEFT", -E.mult, E.mult)
					frame.bg3:Point("BOTTOMRIGHT", E.mult, -E.mult)				
				end
				
				frame.text:ClearAllPoints()
				frame.text:SetPoint("CENTER", frame, "CENTER", 0, -1)
				frame.text:SetJustifyH("CENTER")
				
				if index > 1 then
					frame:ClearAllPoints()
					frame:Point("TOP", _G["AchievementFrameProgressBar"..index-1], "BOTTOM", 0, -5)
					hooksecurefunc(frame, "SetPoint", function(self, point, attachTo, anchorPoint, xOffset, yOffset, noReset)

						if not noReset then
							self:ClearAllPoints()
							self:SetPoint("TOP", _G["AchievementFrameProgressBar"..index-1], "BOTTOM", 0, -5, true)					
						end
					end)
				end
				
				frame.skinned = true
			end

		end
	end)
	
	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas = 0, 0
		for i = 1, numCriteria do	
			local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i)
			
			if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
				metas = metas + 1;
				local metaCriteria = AchievementButton_GetMeta(metas);				
				if ( objectivesFrame.completed and completed ) then
					metaCriteria.label:SetShadowOffset(0, 0)
					metaCriteria.label:SetTextColor(1, 1, 1, 1);
				elseif ( completed ) then
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(0, 1, 0, 1);
				else
					metaCriteria.label:SetShadowOffset(1, -1)
					metaCriteria.label:SetTextColor(.6, .6, .6, 1);
				end				
			elseif criteriaType ~= 1 then
				textStrings = textStrings + 1;
				local criteria = AchievementButton_GetCriteria(textStrings);				
				if ( objectivesFrame.completed and completed ) then
					criteria.name:SetTextColor(1, 1, 1, 1);
					criteria.name:SetShadowOffset(0, 0);
				elseif ( completed ) then
					criteria.name:SetTextColor(0, 1, 0, 1);
					criteria.name:SetShadowOffset(1, -1);
				else
					criteria.name:SetTextColor(.6, .6, .6, 1);
					criteria.name:SetShadowOffset(1, -1);
				end		
			end
		end
	end)
end

S:RegisterSkin("Blizzard_AchievementUI", LoadSkin)