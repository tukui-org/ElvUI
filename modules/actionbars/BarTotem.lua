local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

if E.myclass ~= "SHAMAN" then return end

local bar = CreateFrame('Frame', 'ElvUI_BarTotem', E.UIParent)
bar.buttons = {}

local bordercolors = {
	{.23,.45,.13},   -- Earth
	{.58,.23,.10},   -- Fire
	{.19,.48,.60},   -- Water
	{.42,.18,.74},   -- Air
}

local SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 3 / 256,
		bottom	= 33 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 67 / 128,
		right	= 97 / 128,
		top		= 100 / 256,
		bottom	= 130 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 39 / 128,
		right	= 69 / 128,
		top		= 209 / 256,
		bottom	= 239 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 36 / 256,
		bottom	= 66 / 256,
	},
}

function AB:StyleTotemFlyout(flyout)
	-- remove blizzard flyout texture
	flyout.top:SetTexture(nil)
	flyout.middle:SetTexture(nil)
	flyout:SetFrameStrata('MEDIUM')
	
	-- Skin buttons
	local last
	for _,button in ipairs(flyout.buttons) do
		button:SetTemplate("Default")
		bar.buttons[button] = true
		local icon = select(1,button:GetRegions())
		icon:SetTexCoord(.09,.91,.09,.91)
		icon:SetDrawLayer("ARTWORK")
		icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
		icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)		
		if not InCombatLockdown() then
			button:ClearAllPoints()
			button:Point("BOTTOM",last,"TOP",0,4)
		end
		if button:IsVisible() then last = button end
		button:SetBackdropBorderColor(flyout.parent:GetBackdropBorderColor())
		button:StyleButton()
	end
	
	flyout.buttons[1]:SetPoint("BOTTOM",flyout,"BOTTOM")
	
	if flyout.type == "slot" then
		local tcoords = SLOT_EMPTY_TCOORDS[flyout.parent:GetID()]
		flyout.buttons[1].icon:SetTexCoord(tcoords.left,tcoords.right,tcoords.top,tcoords.bottom)
	end
	
	-- Skin Close button
	local close = MultiCastFlyoutFrameCloseButton
	close:SetTemplate("Default")	
	close:GetHighlightTexture():SetTexture([[Interface\Buttons\ButtonHilight-Square]])
	close:GetHighlightTexture():Point("TOPLEFT",close,"TOPLEFT",1,-1)
	close:GetHighlightTexture():Point("BOTTOMRIGHT",close,"BOTTOMRIGHT",-1,1)
	close:GetNormalTexture():SetTexture(nil)
	close:ClearAllPoints()
	close:Point("BOTTOMLEFT",last,"TOPLEFT",0,4)
	close:Point("BOTTOMRIGHT",last,"TOPRIGHT",0,4)	
	close:SetBackdropBorderColor(last:GetBackdropBorderColor())
	close:Height(8)
	
	flyout:ClearAllPoints()
	flyout:Point("BOTTOM",flyout.parent,"TOP",0,4)
	
	bar.buttons[close] = true
	bar.buttons[flyout] = true
	self:AdjustTotemSettings()
end
AB:SecureHook('MultiCastFlyoutFrame_ToggleFlyout', 'StyleTotemFlyout')

function AB:StyleTotemOpenButton(button, _, parent)
	button:GetHighlightTexture():SetAlpha(0)
	button:GetNormalTexture():SetAlpha(0)

	button:Height(20)
	button:ClearAllPoints()
	button:Point("BOTTOMLEFT", parent, "TOPLEFT", 0, -3)
	button:Point("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -3)
	if not button.visibleBut then
		button.visibleBut = CreateFrame("Frame",nil,button)
		button.visibleBut:Height(8)
		button.visibleBut:Width(parent:GetWidth())
		button.visibleBut:SetPoint("CENTER")
		button.visibleBut.highlight = button.visibleBut:CreateTexture(nil,"HIGHLIGHT")
		button.visibleBut.highlight:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
		button.visibleBut.highlight:Point("TOPLEFT",button.visibleBut,"TOPLEFT",1,-1)
		button.visibleBut.highlight:Point("BOTTOMRIGHT",button.visibleBut,"BOTTOMRIGHT",-1,1)
		button.visibleBut:SetTemplate("Default")
	end	

	bar.buttons[button] = true
	self:AdjustTotemSettings()
	button.visibleBut:SetBackdropBorderColor(parent:GetBackdropBorderColor())
end
AB:SecureHook('MultiCastFlyoutFrameOpenButton_Show', 'StyleTotemOpenButton')

function AB:StyleTotemSlotButton(button, index)
	button:SetTemplate("Default")
	button.overlayTex:SetTexture(nil)
	button.background:SetDrawLayer("ARTWORK")
	button.background:ClearAllPoints()
	button.background:Point("TOPLEFT",button,"TOPLEFT",2, -2)
	button.background:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2, 2)
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 4) + 1]))
	button:StyleButton()
	bar.buttons[button] = true
	self:AdjustTotemSettings()
end
hooksecurefunc("MultiCastSlotButton_Update",function(self, slot) AB:StyleTotemSlotButton(self,tonumber( string.match(self:GetName(),"MultiCastSlotButton(%d)"))) end)

function AB:StyleTotemActionButton(button, _, index)
	local icon = select(1,button:GetRegions())
	local combat = InCombatLockdown()
	icon:SetTexCoord(.09,.91,.09,.91)
	icon:SetDrawLayer("ARTWORK")
	icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
	icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
	button.overlayTex:SetTexture(nil)
	button.overlayTex:Hide()
	button:GetNormalTexture():SetAlpha(0)
	if button.slotButton and not combat then
		button:ClearAllPoints()
		button:SetAllPoints(button.slotButton)
		button:SetFrameLevel(button.slotButton:GetFrameLevel()+1)
	end
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 4) + 1]))
	button:SetBackdropColor(0,0,0,0)
	button:StyleButton()
	button.noBackdrop = true
	bar.buttons[button] = true
	self:StyleButton(button, true)
	self:AdjustTotemSettings()
end
AB:SecureHook("MultiCastActionButton_Update", "StyleTotemActionButton")

function AB:StyleTotemSpellButton(button, index)
	if not button then return end
	local icon = select(1,button:GetRegions())
	icon:SetTexCoord(.09,.91,.09,.91)
	icon:SetDrawLayer("ARTWORK")
	icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
	icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
	button:SetTemplate("Default")
	button:GetNormalTexture():SetTexture(nil)
	_G[button:GetName().."Highlight"]:SetTexture(nil)
	_G[button:GetName().."NormalTexture"]:SetTexture(nil)
	button:StyleButton()
	bar.buttons[button] = true
	self:AdjustTotemSettings()
end
hooksecurefunc("MultiCastSummonSpellButton_Update", function(self) AB:StyleTotemSpellButton(self,0) end)
hooksecurefunc("MultiCastRecallSpellButton_Update", function(self) AB:StyleTotemSpellButton(self,5) end)

function AB:TotemOnEnter()
	UIFrameFadeIn(bar, 0.2, bar:GetAlpha(), 1)
end

function AB:TotemOnLeave()
	UIFrameFadeOut(bar, 0.2, bar:GetAlpha(), 0)
end

function AB:AdjustTotemSettings()
	local combat = InCombatLockdown()
	if self.db['barTotem'].enabled and not combat then
		bar:Show()
	elseif not combat then
		bar:Hide()
	end
	for button, _ in pairs(bar.buttons) do
		if self.db['barTotem'].mouseover == true then
			bar:SetAlpha(0)
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'TotemOnEnter')
				self:HookScript(bar, 'OnLeave', 'TotemOnLeave')	
			end
			
			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'TotemOnEnter')
				self:HookScript(button, 'OnLeave', 'TotemOnLeave')					
			end			
		else
			bar:SetAlpha(1)
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter')
				self:Unhook(bar, 'OnLeave')	
			end
			
			if self.hooks[button] then
				self:Unhook(button, 'OnEnter')	
				self:Unhook(button, 'OnLeave')		
			end		
		end
	end
end

function AB:CreateTotemBar()
	bar:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 250)

	MultiCastActionBarFrame:SetParent(bar)
	MultiCastActionBarFrame:ClearAllPoints()
	MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -2, -2)
	MultiCastActionBarFrame:SetScript("OnUpdate", nil)
	MultiCastActionBarFrame:SetScript("OnShow", nil)
	MultiCastActionBarFrame:SetScript("OnHide", nil)
	MultiCastActionBarFrame.SetParent = E.noop
	MultiCastActionBarFrame.SetPoint = E.noop
	MultiCastRecallSpellButton.SetPoint = E.noop
	
	bar:Width(MultiCastActionBarFrame:GetWidth())
	bar:Height(MultiCastActionBarFrame:GetHeight())

	bar.buttons[MultiCastActionBarFrame] = true
	self:CreateMover(bar, 'TotemAB', 'barTotem', -5)
	self:AdjustTotemSettings()
end

