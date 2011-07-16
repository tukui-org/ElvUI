local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end

local _G = _G
local media = C["media"]
local securehandler = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

function Style(self, totem, flyout)
	local name = self:GetName()
	
	if name:match("MultiCast") then return end 
	
	local action = self.action
	local Button = self
	local Icon = _G[name.."Icon"]
	local Count = _G[name.."Count"]
	local Flash	 = _G[name.."Flash"]
	local HotKey = _G[name.."HotKey"]
	local Border  = _G[name.."Border"]
	local Btname = _G[name.."Name"]
	local normal  = _G[name.."NormalTexture"]
	
	if Flash then
		Flash:SetTexture("")
	end
	
	
	if Border then
		Border:Kill()
	end
	
	if Count then
		Count:ClearAllPoints()
		Count:SetPoint("BOTTOMRIGHT", 0, E.Scale(2))
		Count:SetFont(C["media"].font, C["general"].fontscale, "OUTLINE")
	end
	
	if normal then
		normal:SetTexture(nil)
	end
		
	if self.styled then return end	
	
	if Btname then
		if C["actionbar"].macrotext ~= true then
			Btname:SetText("")
			Btname:Hide()
			Btname.Show = E.dummy
		end
	end
	
	if not self.backdrop then
		if not totem then
			if not flyout then
				self:SetWidth(E.buttonsize)
				self:SetHeight(E.buttonsize)
			end
 
			self:CreateBackdrop("Default", true)
			self.backdrop:SetAllPoints()
		end
		
		if Icon then
			Icon:SetTexCoord(.08, .92, .08, .92)
			Icon:SetPoint("TOPLEFT", Button, 2, -2)
			Icon:SetPoint("BOTTOMRIGHT", Button, -2, 2)
		end
	end
	
	if HotKey then
		HotKey:ClearAllPoints()
		HotKey:SetPoint("TOPRIGHT", 0, E.Scale(-3))
		HotKey:SetFont(C["media"].font, C["general"].fontscale, "THINOUTLINE")
		HotKey:SetShadowColor(0, 0, 0, 0.3)
		HotKey.ClearAllPoints = E.dummy
		HotKey.SetPoint = E.dummy
		if not C["actionbar"].hotkey == true then
			HotKey:SetText("")
			HotKey:Hide()
			HotKey.Show = E.dummy
		end
	end
	
	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end
	
	self.styled = true
end

local function Stylesmallbutton(normal, button, icon, name, pet)
	local Flash	 = _G[name.."Flash"]
	button:SetNormalTexture("")
	
	-- another bug fix reported by Affli in t12 beta
	button.SetNormalTexture = E.dummy
	
	Flash:SetTexture(1, 1, 1, 0.3)
	
	if not _G[name.."Panel"] then
		button:SetWidth(E.petbuttonsize)
		button:SetHeight(E.petbuttonsize)
		
		local panel = CreateFrame("Frame", name.."Panel", button)
		panel:CreatePanel("Default", E.petbuttonsize, E.petbuttonsize, "CENTER", button, "CENTER", 0, 0)
		panel:SetTemplate('Default', true)
		panel:SetBackdropColor(unpack(media.backdropcolor))
		panel:SetFrameStrata(button:GetFrameStrata())
		panel:SetFrameLevel(button:GetFrameLevel() - 1)

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:ClearAllPoints()
		if pet then			
			if E.petbuttonsize < 30 then
				local autocast = _G[name.."AutoCastable"]
				autocast:SetAlpha(0)
			end
			local shine = _G[name.."Shine"]
			shine:Size(E.petbuttonsize, E.petbuttonsize)
			shine:ClearAllPoints()
			shine:SetPoint("CENTER", button, 0, 0)
			icon:Point("TOPLEFT", button, 2, -2)
			icon:Point("BOTTOMRIGHT", button, -2, 2)
		else
			icon:Point("TOPLEFT", button, 2, -2)
			icon:Point("BOTTOMRIGHT", button, -2, 2)
		end
	end
	
	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end
end

function E.StyleShift()
	for i=1, NUM_SHAPESHIFT_SLOTS do
		local name = "ShapeshiftButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture"]
		Stylesmallbutton(normal, button, icon, name)
	end
end

function E.StylePet()
	for i=1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button  = _G[name]
		local icon  = _G[name.."Icon"]
		local normal  = _G[name.."NormalTexture2"]
		Stylesmallbutton(normal, button, icon, name, true)
	end
end

-- rescale cooldown spiral to fix texture.
local buttonNames = { "ActionButton",  "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarLeftButton", "MultiBarRightButton", "ShapeshiftButton", "PetActionButton"}
for _, name in ipairs( buttonNames ) do
	for index = 1, 12 do
		local buttonName = name .. tostring(index)
		local button = _G[buttonName]
		local cooldown = _G[buttonName .. "Cooldown"]
 
		if ( button == nil or cooldown == nil ) then
			break
		end
		
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end
end

local buttons = 0
local function SetupFlyoutButton()
	for i=1, buttons do
		--prevent error if you don't have max ammount of buttons
		if _G["SpellFlyoutButton"..i] and not _G["SpellFlyoutButton"..i].styled then
			Style(_G["SpellFlyoutButton"..i], nil, true)
			_G["SpellFlyoutButton"..i]:StyleButton(true)
			if C["actionbar"].rightbarmouseover == true then
				SpellFlyout:HookScript("OnEnter", function(self) RightBarMouseOver(1) end)
				SpellFlyout:HookScript("OnLeave", function(self) RightBarMouseOver(0) end)
				_G["SpellFlyoutButton"..i]:HookScript("OnEnter", function(self) RightBarMouseOver(1) end)
				_G["SpellFlyoutButton"..i]:HookScript("OnLeave", function(self) RightBarMouseOver(0) end)
			end
		end
	end
end
SpellFlyout:HookScript("OnShow", SetupFlyoutButton)

 
--Hide the Mouseover texture and attempt to find the ammount of buttons to be skinned
local function StyleFlyout(self)
	self.FlyoutBorder:SetAlpha(0)
	self.FlyoutBorderShadow:SetAlpha(0)
	
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)
	
	for i=1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			buttons = numSlots
			break
		end
	end
	
	--Change arrow direction depending on what bar the button is on
	local arrowDistance
	if ((SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or GetMouseFocus() == self) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end
	
	if self:GetParent() and self:GetParent():GetParent() and self:GetParent():GetParent():GetName() and self:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then 
		return 
	end
	
	if self:GetAttribute("flyoutDirection") ~= nil then
		local point, _, _, _, _ = self:GetPoint()
		
		if strfind(point, "TOP") then
			self.FlyoutArrow:ClearAllPoints()
			self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
			SetClampedTextureRotation(self.FlyoutArrow, 270)
			if not InCombatLockdown() then self:SetAttribute("flyoutDirection", "LEFT") end		
		else
			self.FlyoutArrow:ClearAllPoints()
			self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance)
			SetClampedTextureRotation(self.FlyoutArrow, 0)
			if not InCombatLockdown() then self:SetAttribute("flyoutDirection", "UP") end
		end
	end
end

do	
	for i = 1, 12 do
		_G["MultiBarLeftButton"..i]:StyleButton(true)
		_G["MultiBarRightButton"..i]:StyleButton(true)
		_G["MultiBarBottomRightButton"..i]:StyleButton(true)
		_G["MultiBarBottomLeftButton"..i]:StyleButton(true)
		_G["ActionButton"..i]:StyleButton(true)
	end
	 
	for i=1, 10 do
		_G["ShapeshiftButton"..i]:StyleButton(true)
		_G["PetActionButton"..i]:StyleButton(true)
	end
	
	for i=1, 6 do
		_G["VehicleMenuBarActionButton"..i]:StyleButton(true)
		Style(_G["VehicleMenuBarActionButton"..i])
	end
end

hooksecurefunc("ActionButton_Update", Style)
hooksecurefunc("ActionButton_UpdateHotkeys", E.UpdateHotkey)
hooksecurefunc("ActionButton_UpdateFlyout", StyleFlyout)

---------------------------------------------------------------
-- Totem Style, they need a lot more work than "normal" buttons
-- Because of this, we skin it via separate styling codes
-- Special thank's to DarthAndroid
---------------------------------------------------------------

-- don't continue executing code in this file is not playing a shaman.
if not E.myclass == "SHAMAN" then return end

-- Tex Coords for empty buttons
SLOT_EMPTY_TCOORDS = {
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

local function StyleTotemFlyout(flyout)
	-- remove blizzard flyout texture
	flyout.top:SetTexture(nil)
	flyout.middle:SetTexture(nil)
	flyout:SetFrameStrata('MEDIUM')
	
	-- Skin buttons
	local last = nil
	
	for _,button in ipairs(flyout.buttons) do
		button:SetTemplate("Default")
		local icon = select(1,button:GetRegions())
		icon:SetTexCoord(.09,.91,.09,.91)
		icon:SetDrawLayer("ARTWORK")
		icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
		icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)		
		if not InCombatLockdown() then
			button:Size(C["actionbar"].petbuttonsize)
			button:ClearAllPoints()
			button:Point("BOTTOM",last,"TOP",0,4)
		end
		if button:IsVisible() then last = button end
		button:SetBackdropBorderColor(flyout.parent:GetBackdropBorderColor())
		button:StyleButton()
		
		if C["actionbar"].shapeshiftmouseover == true then
			button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
			button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
		end			
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
	
	if C["actionbar"].shapeshiftmouseover == true then
		flyout:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		flyout:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
		close:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		close:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end
end
hooksecurefunc("MultiCastFlyoutFrame_ToggleFlyout",function(self) StyleTotemFlyout(self) end)
	
local function StyleTotemOpenButton(button, parent)
	button:GetHighlightTexture():SetAlpha(0)
	button:GetNormalTexture():SetAlpha(0)

	button:Height(20)
	button:ClearAllPoints()
	button:Point("BOTTOMLEFT", parent, "TOPLEFT", 0, -3)
	button:Point("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -3)
	if not button.visibleBut then
		button.visibleBut = CreateFrame("Frame",nil,button)
		button.visibleBut:Height(8)
		button.visibleBut:Width(C["actionbar"].petbuttonsize)
		button.visibleBut:SetPoint("CENTER")
		button.visibleBut.highlight = button.visibleBut:CreateTexture(nil,"HIGHLIGHT")
		button.visibleBut.highlight:SetTexture([[Interface\Buttons\ButtonHilight-Square]])
		button.visibleBut.highlight:Point("TOPLEFT",button.visibleBut,"TOPLEFT",1,-1)
		button.visibleBut.highlight:Point("BOTTOMRIGHT",button.visibleBut,"BOTTOMRIGHT",-1,1)
		button.visibleBut:SetTemplate("Default")
	end	
	
	if C["actionbar"].shapeshiftmouseover == true then
		button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end	
	button.visibleBut:SetBackdropBorderColor(parent:GetBackdropBorderColor())
end
hooksecurefunc("MultiCastFlyoutFrameOpenButton_Show",function(button,_, parent) StyleTotemOpenButton(button, parent) end)

-- the color we use for border
local bordercolors = {
	{.23,.45,.13},   -- Earth
	{.58,.23,.10},   -- Fire
	{.19,.48,.60},   -- Water
	{.42,.18,.74},   -- Air
}

local function StyleTotemSlotButton(button, index)
	button:SetTemplate("Default")
	button.overlayTex:SetTexture(nil)
	button.background:SetDrawLayer("ARTWORK")
	button.background:ClearAllPoints()
	button.background:Point("TOPLEFT",button,"TOPLEFT",2, -2)
	button.background:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2, 2)
	if not InCombatLockdown() then button:Size(C["actionbar"].petbuttonsize) end
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 4) + 1]))
	button:StyleButton()
	if C["actionbar"].shapeshiftmouseover == true then
		button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end	
end
hooksecurefunc("MultiCastSlotButton_Update",function(self, slot) StyleTotemSlotButton(self,tonumber( string.match(self:GetName(),"MultiCastSlotButton(%d)"))) end)

-- Skin the actual totem buttons
local function StyleTotemActionButton(button, index)
	local icon = select(1,button:GetRegions())
	icon:SetTexCoord(.09,.91,.09,.91)
	icon:SetDrawLayer("ARTWORK")
	icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
	icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
	button.overlayTex:SetTexture(nil)
	button.overlayTex:Hide()
	button:GetNormalTexture():SetAlpha(0)
	if button.slotButton and not InCombatLockdown() then
		button:ClearAllPoints()
		button:SetAllPoints(button.slotButton)
		button:SetFrameLevel(button.slotButton:GetFrameLevel()+1)
	end
	button:SetBackdropBorderColor(unpack(bordercolors[((index-1) % 4) + 1]))
	button:SetBackdropColor(0,0,0,0)
	button:StyleButton(true)
	if C["actionbar"].shapeshiftmouseover == true then
		button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end	
end
hooksecurefunc("MultiCastActionButton_Update",function(actionButton, actionId, actionIndex, slot) StyleTotemActionButton(actionButton,actionIndex) end)

local function FixBackdrop(button)
	if button:GetName() and button:GetName():find("MultiCast") and button:GetNormalTexture() then
		button:GetNormalTexture():SetAlpha(0)
	end
end
hooksecurefunc("ActionButton_ShowGrid", FixBackdrop)

-- Skin the summon and recall buttons
local function StyleTotemSpellButton(button, index)
	if not button then return end
	local icon = select(1,button:GetRegions())
	icon:SetTexCoord(.09,.91,.09,.91)
	icon:SetDrawLayer("ARTWORK")
	icon:Point("TOPLEFT",button,"TOPLEFT",2,-2)
	icon:Point("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
	button:SetTemplate("Default")
	button:GetNormalTexture():SetTexture(nil)
	if not InCombatLockdown() then button:Size(C["actionbar"].petbuttonsize) end
	_G[button:GetName().."Highlight"]:SetTexture(nil)
	_G[button:GetName().."NormalTexture"]:SetTexture(nil)
	button:StyleButton()
	if C["actionbar"].shapeshiftmouseover == true then
		button:HookScript("OnEnter", function() MultiCastActionBarFrame:SetAlpha(1) end)
		button:HookScript("OnLeave", function() MultiCastActionBarFrame:SetAlpha(0) end)
	end	
end
hooksecurefunc("MultiCastSummonSpellButton_Update", function(self) StyleTotemSpellButton(self,0) end)
hooksecurefunc("MultiCastRecallSpellButton_Update", function(self) StyleTotemSpellButton(self,5) end)