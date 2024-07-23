local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, unpack = pairs, unpack
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

local trackers = {
	_G.ScenarioObjectiveTracker,
	_G.UIWidgetObjectiveTracker,
	_G.CampaignQuestObjectiveTracker,
	_G.QuestObjectiveTracker,
	_G.AdventureObjectiveTracker,
	_G.AchievementObjectiveTracker,
	_G.MonthlyActivitiesObjectiveTracker,
	_G.ProfessionsRecipeTracker,
	_G.BonusObjectiveTracker,
	_G.WorldQuestObjectiveTracker,
}

local function SkinOjectiveTrackerHeaders(header)
	if not header then return end

	if header.Background then
		header.Background:SetAtlas(nil)
	end

	if header.Text then
		header.Text:FontTemplate()
	end
end

local function ColorProgressBars(self, value)
	if not (self.Bar and self.IsSkinned and value) then return end
	S:StatusBarColorGradient(self.Bar, value, 100)
end

local function HotkeyShow(self)
	local item = self:GetParent()
	if item.rangeOverlay then item.rangeOverlay:Show() end
end
local function HotkeyHide(self)
	local item = self:GetParent()
	if item.rangeOverlay then item.rangeOverlay:Hide() end
end
local function HotkeyColor(self, r, g, b)
	local item = self:GetParent()
	if item.rangeOverlay then
		if r == 0.6 and g == 0.6 and b == 0.6 then
			item.rangeOverlay:SetVertexColor(0, 0, 0, 0)
		else
			item.rangeOverlay:SetVertexColor(.8, .1, .1, .5)
		end
	end
end

local function SkinItemButton(item)
	item:SetTemplate('Transparent')
	item:StyleButton()
	item:SetNormalTexture(E.ClearTexture)

	item.icon:SetTexCoord(unpack(E.TexCoords))
	item.icon:SetInside()

	item.Cooldown:SetInside()
	item.Count:ClearAllPoints()
	item.Count:Point('TOPLEFT', 1, -1)
	item.Count:FontTemplate(nil, 14, 'OUTLINE')
	item.Count:SetShadowOffset(5, -5)

	local rangeOverlay = item:CreateTexture(nil, 'OVERLAY')
	rangeOverlay:SetTexture(E.Media.Textures.White8x8)
	rangeOverlay:SetInside()
	item.rangeOverlay = rangeOverlay

	hooksecurefunc(item.HotKey, 'Show', HotkeyShow)
	hooksecurefunc(item.HotKey, 'Hide', HotkeyHide)
	hooksecurefunc(item.HotKey, 'SetVertexColor', HotkeyColor)
	HotkeyColor(item.HotKey, item.HotKey:GetTextColor())
	item.HotKey:SetAlpha(0)

	E:RegisterCooldown(item.Cooldown)
end

local function HandleItemButton(block)
	if InCombatLockdown() then return end -- will break quest item button

	local item = block and block.itemButton
	if not item then return end

	if not item.skinned then
		SkinItemButton(item)
		item.skinned = true
	end

	if item.backdrop then
		item.backdrop:SetFrameLevel(3)
	end
end

local function SkinProgressBars(_, _, line)
	local progressBar = line and line.ProgressBar
	local bar = progressBar and progressBar.Bar
	if not bar then return end

	local icon = bar.Icon
	local label = bar.Label

	if not progressBar.IsSkinned then
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
		bar:StripTextures()
		bar:CreateBackdrop('Transparent')
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		if label then
			label:ClearAllPoints()
			label:Point('CENTER', bar)
			label:FontTemplate(nil, E.db.general.fontSize, E.db.general.fontStyle)
		end

		if icon then
			icon:ClearAllPoints()
			icon:Point('LEFT', bar, 'RIGHT', E.PixelMode and 3 or 7, 0)
			icon:SetMask('')
			icon:SetTexCoord(unpack(E.TexCoords))

			if not progressBar.backdrop then
				progressBar:CreateBackdrop()
				progressBar.backdrop:SetOutside(icon)
				progressBar.backdrop:SetShown(icon:IsShown())
			end
		end

		_G.BonusObjectiveTrackerProgressBar_PlayFlareAnim = E.noop
		progressBar.IsSkinned = true

		ColorProgressBars(progressBar, bar:GetValue())
	elseif icon and progressBar.backdrop then
		progressBar.backdrop:SetShown(icon:IsShown())
	end
end

-- new 11.0
local function ReskinBarTemplate(bar)
	if bar.backdrop then return end

	bar:StripTextures()
	bar:CreateBackdrop()
	bar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(bar)
end

local function HandleProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end

	local icon = bar and bar.Icon
	if icon and not icon.backdrop then
		icon:SetMask('') -- This needs to be before the skinning function
		S:HandleIcon(icon, true)

		icon:ClearAllPoints()
		icon:Point('TOPLEFT', bar, 'TOPRIGHT', 5, 0)
		icon:Point('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 25, 0)
	end
end

local function HandleTimers(tracker, key)
	local timerBar = tracker.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if bar then
		ReskinBarTemplate(bar)
	end
end
-- End of 11.0

local function SkinTimerBars(_, _, line)
	local timerBar = line and line.TimerBar
	local bar = timerBar and timerBar.Bar

	if not timerBar.IsSkinned then
		bar:Height(18)
		bar:StripTextures()
		bar:CreateBackdrop('Transparent')
		bar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(bar)

		timerBar.IsSkinned = true
	end
end

local function PositionFindGroupButton(block, button)
	if InCombatLockdown() then return end -- will break quest item button

	if button and button.GetPoint then
		local a, b, c, d, e = button:GetPoint()
		if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
			-- this fires when there is a group button and a item button to the left of it
			-- we push the item button away from the group button (to the left)
			button:Point(a, b, c, d-(E.PixelMode and -1 or 1), e)
		elseif b == block and block.groupFinderButton and button == block.groupFinderButton then
			-- this fires when there is a group finder button
			-- we push the group finder button down slightly
			button:Point(a, b, c, d, e-(E.PixelMode and 2 or -1))
		end
	end
end

local function SkinFindGroupButton(block)
	local button = block.hasGroupFinderButton and block.groupFinderButton
	if button then
		S:HandleButton(button)
		button:Size(20)

		if button.backdrop then
			button.backdrop:SetFrameLevel(3)
		end
	end
end

local function TrackerStateChanged()
	local minimizeButton = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	if _G.ObjectiveTrackerFrame.collapsed then
		minimizeButton.tex:SetTexture(E.Media.Textures.PlusButton)
	else
		minimizeButton.tex:SetTexture(E.Media.Textures.MinusButton)
	end
end

local function UpdateMinimizeButton(button, collapsed)
	if collapsed then
		button.tex:SetTexture(E.Media.Textures.PlusButton)
	else
		button.tex:SetTexture(E.Media.Textures.MinusButton)
	end
end

function S:Blizzard_ObjectiveTracker()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.objectiveTracker) then return end

	local MainHeader = _G.ObjectiveTrackerFrame.Header
	SkinOjectiveTrackerHeaders(MainHeader)

	-- FIX ME 11.0: Collapse state got changed
	local MainMinimize = MainHeader.MinimizeButton
	MainMinimize:StripTextures(nil, true)
	MainMinimize:Size(16)
	MainMinimize:SetHighlightTexture(130837, 'ADD') -- Interface\Buttons\UI-PlusButton-Hilight
	MainMinimize.tex = MainMinimize:CreateTexture(nil, 'OVERLAY')
	MainMinimize.tex:SetTexture(E.Media.Textures.MinusButton)
	MainMinimize.tex:SetInside()

	for _, tracker in pairs(trackers) do
		SkinOjectiveTrackerHeaders(tracker.Header)

		hooksecurefunc(tracker, 'AddBlock', HandleItemButton)  -- FIX ME 11.0
		hooksecurefunc(tracker, 'GetProgressBar', HandleProgressBar) -- Make me pretty
		hooksecurefunc(tracker, 'GetTimerBar', HandleTimers) -- Make me pretty
	end
end

S:AddCallbackForAddon('Blizzard_ObjectiveTracker')
