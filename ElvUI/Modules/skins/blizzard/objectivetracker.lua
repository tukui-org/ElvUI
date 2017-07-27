local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local unpack = unpack
local hooksecurefunc = hooksecurefunc
-- GLOBALS: ObjectiveTrackerBlocksFrame, ObjectiveTrackerFrame, BonusObjectiveTrackerProgressBar_PlayFlareAnim
-- GLOBALS: SCENARIO_TRACKER_MODULE, BONUS_OBJECTIVE_TRACKER_MODULE, WORLD_QUEST_TRACKER_MODULE, QUEST_TRACKER_MODULE, DEFAULT_OBJECTIVE_TRACKER_MODULE

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.objectiveTracker ~= true then return end

	ObjectiveTrackerBlocksFrame.QuestHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:FontTemplate()
	ObjectiveTrackerBlocksFrame.AchievementHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:FontTemplate()
	ObjectiveTrackerBlocksFrame.ScenarioHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:FontTemplate()

	BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures()
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:FontTemplate()
	WORLD_QUEST_TRACKER_MODULE.Header:StripTextures()
	WORLD_QUEST_TRACKER_MODULE.Header.Text:FontTemplate()

	local function OnClick(self)
		local textObject = self.text

		if ObjectiveTrackerFrame.collapsed then
			textObject:SetText("+")
		else
			textObject:SetText("-")
		end
	end

	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	S:HandleButton(minimizeButton)
	minimizeButton:Size(16, 14)
	minimizeButton.text = minimizeButton:CreateFontString(nil, "OVERLAY")
	minimizeButton.text:FontTemplate()
	minimizeButton.text:Point("CENTER", minimizeButton, "CENTER", 0, 0)
	minimizeButton.text:SetText("-")
	minimizeButton.text:SetJustifyH("CENTER")
	minimizeButton.text:SetJustifyV("MIDDLE")
	minimizeButton:HookScript('OnClick', OnClick)

	-- Various stuff I experimented with
	--[[
	ObjectiveTrackerBlocksFrame:CreateBackdrop("Transparent")
	ObjectiveTrackerBlocksFrame.backdrop:Point("TOPLEFT", -30, 0)

	local b = CreateFrame("Button", nil, ObjectiveTrackerFrame)
	b.text = b:CreateFontString(nil, 'OVERLAY')
	b.text:Point('CENTER', b, 'CENTER')
	b.text:FontTemplate()
	b.text:SetText(HIDE)
	b:Size(50, 20)
	S:HandleButton(b)
	b:SetTemplate("Transparent")
	b:Point("BOTTOMRIGHT", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, "BOTTOMRIGHT",0, 0)
	b:SetScript("OnClick", function()
		ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:GetScript("OnClick")()

		if ObjectiveTrackerBlocksFrame.QuestHeader:IsVisible() then
			b:Width(50)
			b.text:SetText(HIDE)
			b:ClearAllPoints()
			b:Point("BOTTOMRIGHT", ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, "BOTTOMRIGHT",0, 0)
		else
			b.text:SetText("")
			b:Point("TOPLEFT", ObjectiveTrackerFrame.HeaderMenu.Title, "TOPLEFT", -10, 5)
		end
	end)

	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetTextColor(unpack(E.media.rgbvaluecolor))
	ObjectiveTrackerBlocksFrame.AchievementHeader:CreateBackdrop("Transparent")
	ObjectiveTrackerBlocksFrame.AchievementHeader.backdrop:Point("TOPLEFT", 0, -2)
	ObjectiveTrackerBlocksFrame.AchievementHeader.backdrop:Point("BOTTOMRIGHT", 0, 2)
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetAlpha(0)
	]]

	--Skin ObjectiveTrackerFrame item buttons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(25, 25)
			item:SetTemplate("Transparent")
			item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(E.TexCoords))
			item.icon:SetInside()
			item.Cooldown:SetInside()
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(E["media"].normFont, 14, "OUTLINE")
			item.Count:SetShadowOffset(5, -5)
			E:RegisterCooldown(item.Cooldown)
			item.skinned = true
		end
	end)

	--World Quest Tracker item buttons
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", function(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(25, 25)
			item:SetTemplate("Transparent")
			item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(E.TexCoords))
			item.icon:SetInside()
			item.Cooldown:SetInside()
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(E["media"].normFont, 14, "OUTLINE")
			item.Count:SetShadowOffset(5, -5)
			E:RegisterCooldown(item.Cooldown)
			item.skinned = true
		end
	end)

	--Quest Tracker ProgressBar
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", function(self, block, line, questID)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line];
		if not progressBar.Bar.backdrop then
			progressBar.Bar:CreateBackdrop("Transparent")
			progressBar.Bar:SetStatusBarTexture(E["media"].normTex)
			E:RegisterStatusBar(progressBar.Bar)
			progressBar.Bar:DisableDrawLayer("ARTWORK")
			progressBar.Bar.Label:SetDrawLayer("OVERLAY")
		end
	end)

	--World Quest Tracker/Bonus Objective Tracker ProgressBar
	local function SkinProgressBars(line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar
		local icon = bar.Icon
		local label = bar.Label

		if bar and not progressBar.IsSkinned then
			progressBar:CreateBackdrop("Default")
			progressBar.backdrop:SetOutside(icon)

			if bar.BarFrame then bar.BarFrame:Hide() end
			if bar.BarFrame2 then bar.BarFrame2:Hide() end
			if bar.BarFrame3 then bar.BarFrame3:Hide() end
			if bar.BarGlow then bar.BarGlow:Hide() end
			if bar.Sheen then bar.Sheen:Hide() end
			if bar.IconBG then bar.IconBG:SetAlpha(0) end
			if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
			if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
			if bar.BorderMid then bar.BorderMid:SetAlpha(0) end

			bar:Height(18)
			bar:CreateBackdrop("Transparent")
			bar:SetStatusBarTexture(E["media"].normTex)
			bar:SetBackdropColor(0, 0, 0, 0)
			E:RegisterStatusBar(bar)

			if label then
				label:ClearAllPoints()
				label:Point("CENTER", bar, 0, -1)
			end

			if icon then
				icon:ClearAllPoints()
				icon:Point("LEFT", bar, "RIGHT", E.PixelMode and 3 or 7, 0)
				icon:SetMask("")
				icon:SetTexCoord(unpack(E.TexCoords))

				if not progressBar.backdrop then
					progressBar:CreateBackdrop("Default")
					progressBar.backdrop:SetOutside(icon)
				end
			end

			BonusObjectiveTrackerProgressBar_PlayFlareAnim = E.noop
			progressBar.isSkinned = true
		end

		if bar and icon and progressBar.backdrop then
			progressBar.backdrop:SetShown(icon:IsShown())
		end
	end

	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", function(_, _, line)
		SkinProgressBars(line)
	end)

	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", function(_, _, line)
		SkinProgressBars(line)
	end)

	--Scenario Tracker ProgressBar
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", function(_, _, line)
		if not line.ProgressBar.Bar.backdrop then
			line.ProgressBar.Bar:Height(18)
			line.ProgressBar.Bar:CreateBackdrop("Transparent")
			line.ProgressBar.Bar:SetStatusBarTexture(E["media"].normTex)
			E:RegisterStatusBar(line.ProgressBar.Bar)
			line.ProgressBar.Bar.BarFrame:Hide()
			line.ProgressBar.Bar.IconBG:SetAlpha(0)
			line.ProgressBar.Bar.BarFrame2:Hide()
			line.ProgressBar.Bar.BarFrame3:Hide()

			line.ProgressBar.Bar.Icon:ClearAllPoints()
			line.ProgressBar.Bar.Icon:SetPoint("LEFT", line.ProgressBar.Bar, "RIGHT", E.Border*3, 0)
			line.ProgressBar.Bar.Icon:SetMask("")
			line.ProgressBar.Bar.Icon:SetTexCoord(unpack(E.TexCoords))

			line.ProgressBar:CreateBackdrop("Default")
			line.ProgressBar.backdrop:SetOutside(line.ProgressBar.Bar.Icon)
		end

		line.ProgressBar.backdrop:SetShown(line.ProgressBar.Bar.Icon:IsShown())
	end)

	local function PositionFindGroupButton(block, button)
		if button and button.GetPoint then
			local a, b, c, d, e = button:GetPoint()
			if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
				-- this fires when there is a group button and a item button to the left of it
				button:Point(a, b, c, d-(E.PixelMode and -1 or 1), e);
			elseif b == block and block.groupFinderButton and button == block.groupFinderButton then
				-- this fires when there is a group button
				button:Point(a, b, c, d, e-(E.PixelMode and 2 or -1));
			end
		end
	end
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", PositionFindGroupButton)

	local function SkinFindGroupButton(block, questID)
		if block.hasGroupFinderButton and block.groupFinderButton then
			if block.groupFinderButton and not block.groupFinderButton.skinned then
				S:HandleButton(block.groupFinderButton)
				block.groupFinderButton:Size(20)
				block.groupFinderButton.skinned = true
			end
		end
	end
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", SkinFindGroupButton)
end

S:AddCallback("ObjectiveTracker", LoadSkin)