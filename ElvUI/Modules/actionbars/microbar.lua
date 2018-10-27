local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

--Cache global variables
--Lua functions
local _G = _G
local assert = assert
--WoW API / Variables
local CreateFrame = CreateFrame
local C_StorePublic_IsEnabled = C_StorePublic.IsEnabled
local UpdateMicroButtonsParent = UpdateMicroButtonsParent
local RegisterStateDriver = RegisterStateDriver
local InCombatLockdown = InCombatLockdown

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ElvUI_MicroBar, MainMenuBarPerformanceBar, MainMenuMicroButton
-- GLOBALS: MICRO_BUTTONS, CharacterMicroButton, GuildMicroButtonTabard
-- GLOBALS: GuildMicroButton, MicroButtonPortrait, CollectionsMicroButtonAlert

local function onLeave()
	if AB.db.microbar.mouseover then
		E:UIFrameFadeOut(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), 0)
	end
end

local watcher = 0
local function onUpdate(self, elapsed)
	if watcher > 0.1 then
		if not self:IsMouseOver() then
			self.IsMouseOvered = nil
			self:SetScript("OnUpdate", nil)
			onLeave()
		end
		watcher = 0
	else
		watcher = watcher + elapsed
	end
end

local function onEnter()
	if AB.db.microbar.mouseover and not ElvUI_MicroBar.IsMouseOvered then
		ElvUI_MicroBar.IsMouseOvered = true
		ElvUI_MicroBar:SetScript("OnUpdate", onUpdate)
		E:UIFrameFadeIn(ElvUI_MicroBar, 0.2, ElvUI_MicroBar:GetAlpha(), AB.db.microbar.alpha)
	end
end

function AB:HandleMicroButton(button)
	assert(button, 'Invalid micro button name.')

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()

	local f = CreateFrame("Frame", nil, button)
	f:SetFrameLevel(1)
	f:SetFrameStrata("BACKGROUND")
	f:SetTemplate("Default", true)
	f:SetOutside(button)
	button.backdrop = f

	button:SetParent(ElvUI_MicroBar)
	button:GetHighlightTexture():Kill()
	button:HookScript('OnEnter', onEnter)
	button:SetHitRectInsets(0, 0, 0, 0)

	if button.Flash then
		button.Flash:SetInside()
		button.Flash:SetTexture(nil)
	end

	pushed:SetTexCoord(0.22, 0.81, 0.26, 0.82)
	pushed:SetInside(f)

	normal:SetTexCoord(0.22, 0.81, 0.21, 0.82)
	normal:SetInside(f)

	if disabled then
		disabled:SetTexCoord(0.22, 0.81, 0.21, 0.82)
		disabled:SetInside(f)
	end
end

function AB:MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:Point("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36);
end

function AB:MainMenuMicroButton_SetPushed()
	MainMenuBarPerformanceBar:Point("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 8, -37);
end

function AB:UpdateMicroButtonsParent()
	for i=1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(ElvUI_MicroBar);
	end
end

-- we use this table to sort the micro buttons on our bar to match Blizzard's button placements.
local __buttonIndex = {
	[8] = "CollectionsMicroButton",
	[9] = "EJMicroButton",
	[10] = (not C_StorePublic_IsEnabled() and GetCurrentRegionName() == "CN") and "HelpMicroButton" or "StoreMicroButton",
	[11] = "MainMenuMicroButton"
}

function AB:UpdateMicroBarVisibility()
	if InCombatLockdown() then
		AB.NeedsUpdateMicroBarVisibility = true
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local visibility = self.db.microbar.visibility
	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	RegisterStateDriver(ElvUI_MicroBar.visibility, "visibility", (self.db.microbar.enabled and visibility) or "hide");
end

function AB:UpdateMicroPositionDimensions()
	if not ElvUI_MicroBar then return end

	local numRows = 1
	local prevButton = ElvUI_MicroBar
	local offset = E:Scale(E.PixelMode and 1 or 3)
	local spacing = E:Scale(offset + self.db.microbar.buttonSpacing)

	for i=1, #MICRO_BUTTONS-1 do
		local button = _G[__buttonIndex[i]] or _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i-self.db.microbar.buttonsPerRow;
		lastColumnButton = _G[__buttonIndex[lastColumnButton]] or _G[MICRO_BUTTONS[lastColumnButton]]

		button:Size(self.db.microbar.buttonSize, self.db.microbar.buttonSize * 1.4);
		button:ClearAllPoints();

		if prevButton == ElvUI_MicroBar then
			button:Point('TOPLEFT', prevButton, 'TOPLEFT', offset, -offset)
		elseif (i - 1) % self.db.microbar.buttonsPerRow == 0 then
			button:Point('TOP', lastColumnButton, 'BOTTOM', 0, -spacing);
			numRows = numRows + 1
		else
			button:Point('LEFT', prevButton, 'RIGHT', spacing, 0);
		end

		prevButton = button
	end

	if AB.db.microbar.mouseover and not ElvUI_MicroBar:IsMouseOver() then
		ElvUI_MicroBar:SetAlpha(0)
	else
		ElvUI_MicroBar:SetAlpha(self.db.microbar.alpha)
	end

	AB.MicroWidth = (((_G["CharacterMicroButton"]:GetWidth() + spacing) * self.db.microbar.buttonsPerRow) - spacing) + (offset * 2)
	AB.MicroHeight = (((_G["CharacterMicroButton"]:GetHeight() + spacing) * numRows) - spacing) + (offset * 2)
	ElvUI_MicroBar:Size(AB.MicroWidth, AB.MicroHeight)

	if ElvUI_MicroBar.mover then
		if self.db.microbar.enabled then
			E:EnableMover(ElvUI_MicroBar.mover:GetName())
		else
			E:DisableMover(ElvUI_MicroBar.mover:GetName())
		end
	end

	self:UpdateMicroBarVisibility()
end

function AB:UpdateMicroButtons()
	GuildMicroButtonTabard:SetInside(GuildMicroButton)

	GuildMicroButtonTabard.background:SetInside(GuildMicroButton)
	GuildMicroButtonTabard.background:SetTexCoord(0.17, 0.87, 0.5, 0.908)

	GuildMicroButtonTabard.emblem:ClearAllPoints()
	GuildMicroButtonTabard.emblem:Point("TOPLEFT", GuildMicroButton, "TOPLEFT", 4, -4)
	GuildMicroButtonTabard.emblem:Point("BOTTOMRIGHT", GuildMicroButton, "BOTTOMRIGHT", -4, 8)

	self:UpdateMicroPositionDimensions()
end

function AB:SetupMicroBar()
	local microBar = CreateFrame('Frame', 'ElvUI_MicroBar', E.UIParent)
	microBar:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -48)
	microBar:EnableMouse(false)

	microBar.visibility = CreateFrame('Frame', nil, E.UIParent, 'SecureHandlerStateTemplate')
	microBar.visibility:SetScript("OnShow", function() microBar:Show() end)
	microBar.visibility:SetScript("OnHide", function() microBar:Hide() end)

	E.FrameLocks["ElvUI_MicroBar"] = true;
	for i=1, #MICRO_BUTTONS do
		self:HandleMicroButton(_G[MICRO_BUTTONS[i]])
	end

	MicroButtonPortrait:SetInside(CharacterMicroButton.backdrop)

	self:SecureHook('MainMenuMicroButton_SetPushed')
	self:SecureHook('MainMenuMicroButton_SetNormal')
	self:SecureHook('UpdateMicroButtonsParent')
	self:SecureHook('MoveMicroButtons', 'UpdateMicroPositionDimensions')
	self:SecureHook('UpdateMicroButtons')
	UpdateMicroButtonsParent(microBar)
	self:MainMenuMicroButton_SetNormal()
	self:UpdateMicroPositionDimensions()

	-- With this method we might don't taint anything. Instead of using :Kill()
	MainMenuBarPerformanceBar:SetAlpha(0)
	MainMenuBarPerformanceBar:SetScale(0.00001)

	CollectionsMicroButtonAlert:EnableMouse(false)
	CollectionsMicroButtonAlert:SetAlpha(0)
	CollectionsMicroButtonAlert:SetScale(0.00001)

	CharacterMicroButtonAlert:EnableMouse(false)
	CharacterMicroButtonAlert:SetAlpha(0)
	CharacterMicroButtonAlert:SetScale(0.00001)

	E:CreateMover(microBar, 'MicrobarMover', L["Micro Bar"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,microbar');
end
