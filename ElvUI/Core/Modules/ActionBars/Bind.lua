local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')

local _G = _G
local strfind = strfind
local tonumber = tonumber
local next, format = next, format
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local GetBindingKey = GetBindingKey
local GetCurrentBindingSet = GetCurrentBindingSet
local GetMacroInfo = GetMacroInfo
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsMetaKeyDown = IsMetaKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local SetBinding = SetBinding
local UIParent = UIParent

local LoadBindings, SaveBindings = LoadBindings, SaveBindings
local SecureActionButton_OnClick = SecureActionButton_OnClick
local SpellBook_GetSpellBookSlot = SpellBook_GetSpellBookSlot

local GetSpellBookItemName = C_SpellBook.GetSpellBookItemName or GetSpellBookItemName

local BOOKTYPE_SPELL = (Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player) or BOOKTYPE_SPELL or 'spell'

local CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP = CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP
local CHARACTER_SPECIFIC_KEYBINDINGS = CHARACTER_SPECIFIC_KEYBINDINGS
local QUICK_KEYBIND_MODE = QUICK_KEYBIND_MODE
local MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS

local bind = CreateFrame('Frame', 'ElvUI_KeyBinder', E.UIParent)
AB.KeyBinder = bind

function AB:ActivateBindMode()
	if InCombatLockdown() then return end

	bind.active = true
	E:StaticPopupSpecial_Show(bind.Popup)
	AB:RegisterEvent('PLAYER_REGEN_DISABLED', 'DeactivateBindMode', false)
end

function AB:DeactivateBindMode(save)
	if save then
		SaveBindings(GetCurrentBindingSet())
		E:Print(L["Binds Saved"])
	else
		LoadBindings(GetCurrentBindingSet())
		E:Print(L["Binds Discarded"])
	end

	bind.active = false
	self:BindHide()
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	E:StaticPopupSpecial_Hide(bind.Popup)
	AB.bindingsChanged = false
end

function AB:BindHide()
	bind:ClearAllPoints()
	bind:Hide()

	if not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

function AB:BindListener(key)
	AB.bindingsChanged = true
	if key == 'ESCAPE' then
		if bind.button.bindings then
			for i = 1, #bind.button.bindings do
				SetBinding(bind.button.bindings[i])
			end
		end

		E:Print(format(L["All keybindings cleared for |cff00ff00%s|r."], bind.name))
		self:BindUpdate(bind.button, bind.spellmacro)

		if bind.spellmacro~='MACRO' and not _G.GameTooltip:IsForbidden() then
			_G.GameTooltip:Hide()
		end

		return
	end

	if key == 'LSHIFT' or key == 'RSHIFT' or key == 'LCTRL' or key == 'RCTRL'
	or key == 'LALT' or key == 'RALT' or key == 'UNKNOWN' then return end

	--Redirect LeftButton click to open flyout
	local isFlyout = bind.button.isFlyout or bind.button.isFlyoutButton
	if key == 'LeftButton' and isFlyout then
		SecureActionButton_OnClick(bind.button)
	end

	if key == 'MiddleButton' then key = 'BUTTON3' end
	if strfind(key, 'Button%d') then key = key:upper() end

	local allowBinding = not isFlyout or (key ~= 'LeftButton') --Don't attempt to bind left mouse button for flyout buttons
	if allowBinding and bind.button.bindstring then
		local alt = IsAltKeyDown() and 'ALT-' or ''
		local ctrl = IsControlKeyDown() and 'CTRL-' or ''
		local shift = IsShiftKeyDown() and 'SHIFT-' or ''
		local meta = IsMetaKeyDown() and 'META-' or ''

		SetBinding(alt..ctrl..shift..meta..key, bind.button.bindstring)
		E:Print(alt..ctrl..shift..meta..key..L[" |cff00ff00bound to |r"]..bind.name..'.')
	end

	self:BindUpdate(bind.button, bind.spellmacro)

	if bind.spellmacro ~= 'MACRO' and bind.spellmacro ~= 'FLYOUT' and not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

function AB:DisplayBindings(tt)
	tt:SetOwner(bind, 'ANCHOR_TOP')
	tt:Point('BOTTOM', bind, 'TOP', 0, 1)
	tt:AddLine(bind.name, 1, 1, 1)

	local numBinds = #bind.button.bindings
	if numBinds == 0 then
		tt:AddLine(L["No bindings set."], .6, .6, .6)
	else
		tt:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)

		for i = 1, numBinds do
			tt:AddDoubleLine(L["Binding"]..i, bind.button.bindings[i], 1, 1, 1)
		end
	end

	tt:Show()
end

function AB:ShowBinds()
	if self.handlingBinds and not self:IsForbidden() then
		AB:DisplayBindings(self)

		self.handlingBinds = nil
	end
end

function AB:BindTooltip(trigger)
	if GameTooltip:IsForbidden() then return end

	if trigger then -- this is needed for some tooltip magic, also it helps show a tooltip when a spell isnt there
		GameTooltip:AddLine(L["Trigger"])
		GameTooltip:Show()
		GameTooltip.handlingBinds = true
	else
		AB:DisplayBindings(GameTooltip)
	end
end

function AB:BindUpdate(button, spellmacro)
	if not bind.active or InCombatLockdown() or button.isFlyout or button.isFlyoutButton then return end

	local trigger = false

	bind.button = button
	bind.spellmacro = spellmacro
	bind.name = nil

	bind:ClearAllPoints()
	bind:SetAllPoints(button)
	bind:Show()

	_G.ShoppingTooltip1:Hide()

	button.bindstring = nil -- keep this clean

	if spellmacro == 'FLYOUT' then
		bind.name = button.spellName or button:GetAttribute('spellName') -- attribute is from the LAB custom flyout

		if bind.name then
			button.bindstring = 'SPELL '..bind.name
		end
	elseif spellmacro == 'SPELL' then
		if E.Retail then
			local slotIndex = button.slotIndex or button:GetParent().slotIndex
			if slotIndex then
				bind.name = GetSpellBookItemName(slotIndex, BOOKTYPE_SPELL) or nil
			end
		else
			button.id = SpellBook_GetSpellBookSlot(button)
			bind.name = button.id and GetSpellBookItemName(button.id, _G.SpellBookFrame.bookType) or nil
		end

		if bind.name then button.bindstring = 'SPELL '..bind.name end
	elseif spellmacro == 'MACRO' then
		button.id = button.selectionIndex or button:GetID()

		if _G.MacroFrame.selectedTab == 2 then
			button.id = button.id + MAX_ACCOUNT_MACROS
		end

		bind.name = GetMacroInfo(button.id)
		if bind.name then button.bindstring = 'MACRO '..bind.name end
	elseif spellmacro == 'MICRO' then
		bind.name = button.tooltipText
		button.bindstring = button.commandName
		trigger = true
	elseif spellmacro == 'BAG' then
		if button.itemID then
			bind.name = button.name
			button.bindstring = 'ITEM item:'..button.itemID
			trigger = true
		end
	else
		bind.name = button:GetName()
		if not bind.name then return end
		trigger = true

		if button.keyBoundTarget then
			button.bindstring = button.keyBoundTarget
		elseif button.commandName then
			button.bindstring = button.commandName
		elseif button.action then
			local action = tonumber(button.action)
			local modact = 1+(action-1)%12
			if bind.name == 'ExtraActionButton1' then
				button.bindstring = 'EXTRAACTIONBUTTON1'
			elseif action < 25 or action > 72 then
				button.bindstring = 'ACTIONBUTTON'..modact
			elseif action < 73 and action > 60 then
				button.bindstring = 'MULTIACTIONBAR1BUTTON'..modact
			elseif action < 61 and action > 48 then
				button.bindstring = 'MULTIACTIONBAR2BUTTON'..modact
			elseif action < 49 and action > 36 then
				button.bindstring = 'MULTIACTIONBAR4BUTTON'..modact
			elseif action < 37 and action > 24 then
				button.bindstring = 'MULTIACTIONBAR3BUTTON'..modact
			end
		end
	end

	if button.bindstring then
		button.bindings = { GetBindingKey(button.bindstring) }

		-- retail: fix the tooltip not changing correctly for flyouts
		-- 11.0 this is still broken for actual spells, this method doesn't seem to work
		if spellmacro == 'FLYOUT' and not next(button.bindings) then
			trigger = true
		end

		AB:BindTooltip(trigger)
	end
end

function AB:ChangeBindingProfile()
	if bind.Popup.perCharCheck:GetChecked() then
		LoadBindings(2)
		SaveBindings(2)
	else
		LoadBindings(1)
		SaveBindings(1)
	end
end

do
	local function OnEnter(button)
		AB:BindUpdate(button, 'MACRO')
	end

	local function MacroSelectorScrollUpdateChild(button)
		button:HookScript('OnEnter', OnEnter)
	end

	local function MacroSelectorScrollUpdate(frame)
		if frame.MacroSelector then
			frame.MacroSelector.ScrollBox:ForEachFrame(MacroSelectorScrollUpdateChild)
		end

		AB:Unhook(frame, 'Update')
	end

	function AB:ADDON_LOADED(_, addon)
		if addon == 'Blizzard_MacroUI' then
			if _G.MacroFrame.Update then
				AB:SecureHook(_G.MacroFrame, 'Update', MacroSelectorScrollUpdate)
			else
				for i = 1, MAX_ACCOUNT_MACROS do
					_G['MacroButton'..i]:HookScript('OnEnter', OnEnter)
				end
			end

			AB:UnregisterEvent('ADDON_LOADED')
		elseif addon == 'Blizzard_PlayerSpells' then
			AB:FixSpellBookTaint()
		end
	end
end

do
	local function KeybindButtonClick()
		if InCombatLockdown() then return end

		AB:ActivateBindMode()

		HideUIPanel(_G.SettingsPanel)
	end

	local function UpdateScrollBoxChild(element)
		local data = element.data
		if data and data.buttonText == QUICK_KEYBIND_MODE then
			local button = element.Button
			if button and button:GetScript('OnClick') ~= KeybindButtonClick then
				button:SetScript('OnClick', KeybindButtonClick)
				button:SetFormattedText('%s Keybind', E.title)
			end
		end
	end

	local function UpdateScrollBox(scrollBox)
		scrollBox:ForEachFrame(UpdateScrollBoxChild)
	end

	function AB:SettingsDisplayCategory(category)
		local list = category.name ~= 'Keybindings' and self:GetSettingsList()
		if not list or not list.ScrollBox then return end

		UpdateScrollBox(list.ScrollBox)
		hooksecurefunc(list.ScrollBox, 'Update', UpdateScrollBox)

		AB:Unhook(_G.SettingsPanel, 'DisplayCategory')
	end
end

function AB:LoadKeyBinder()
	bind:SetFrameStrata('DIALOG')
	bind:SetFrameLevel(99)
	bind:EnableMouse(true)
	bind:EnableKeyboard(true)
	bind:EnableMouseWheel(true)
	bind.texture = bind:CreateTexture()
	bind.texture:SetAllPoints(bind)
	bind.texture:SetColorTexture(0, 0, 0, .25)
	bind:Hide()

	AB:SecureHook(GameTooltip, 'Hide', AB.ShowBinds) -- helper for BindTooltip

	if E.Retail then
		AB:SecureHook(_G.SettingsPanel, 'DisplayCategory', AB.SettingsDisplayCategory)
	end

	bind:SetScript('OnEnter', function(b) local db = b.button:GetParent().db if db and db.mouseover then AB:Button_OnEnter(b.button) end end)
	bind:SetScript('OnLeave', function(b) AB:BindHide() local db = b.button:GetParent().db if db and db.mouseover then AB:Button_OnLeave(b.button) end end)
	bind:SetScript('OnKeyUp', function(_, key) self:BindListener(key) end)
	bind:SetScript('OnMouseUp', function(_, key) self:BindListener(key) end)
	bind:SetScript('OnMouseWheel', function(_, delta) if delta>0 then self:BindListener('MOUSEWHEELUP') else self:BindListener('MOUSEWHEELDOWN') end end)

	local function ButtonOnEnter(b) AB:BindUpdate(b) end
	for b in next, self.handledbuttons do
		if b:IsProtected() and b:IsObjectType('CheckButton') then
			b:HookScript('OnEnter', ButtonOnEnter)
		end
	end

	--Special Popup
	local Popup = CreateFrame('Frame', 'ElvUIBindPopupWindow', UIParent)
	Popup:SetFrameStrata('DIALOG')
	Popup:EnableMouse(true)
	Popup:SetMovable(true)
	Popup:SetFrameLevel(99)
	Popup:SetClampedToScreen(true)
	Popup:Size(360, 130)
	Popup:SetTemplate('Transparent')
	Popup:RegisterForDrag('AnyUp', 'AnyDown')
	Popup:SetScript('OnMouseDown', Popup.StartMoving)
	Popup:SetScript('OnMouseUp', Popup.StopMovingOrSizing)
	Popup:Hide()

	bind.Popup = Popup

	Popup.header = CreateFrame('Button', 'ElvUIBindPopupWindowHeader', Popup, 'UIPanelButtonTemplate')
	Popup.header:Size(100, 25)
	Popup.header:Point('CENTER', Popup, 'TOP')
	Popup.header:RegisterForClicks('AnyUp', 'AnyDown')
	Popup.header:SetScript('OnMouseDown', function() Popup:StartMoving() end)
	Popup.header:SetScript('OnMouseUp', function() Popup:StopMovingOrSizing() end)
	Popup.header:SetText('Key Binds')

	Popup.desc = Popup:CreateFontString('ElvUIBindPopupWindowDescription', 'ARTWORK')
	Popup.desc:SetFontObject('GameFontHighlight')
	Popup.desc:SetJustifyV('TOP')
	Popup.desc:SetJustifyH('LEFT')
	Popup.desc:Point('TOPLEFT', 18, -32)
	Popup.desc:Point('BOTTOMRIGHT', -18, 48)
	Popup.desc:SetText(L["BINDINGS_HELP"])

	Popup.save = CreateFrame('Button', 'ElvUIBindPopupWindowSaveButton', Popup, 'UIPanelButtonTemplate')
	Popup.save:SetText(L["Save"])
	Popup.save:Width(150)
	Popup.save:SetScript('OnClick', function() AB:DeactivateBindMode(true) end)

	Popup.discard = CreateFrame('Button', 'ElvUIBindPopupWindowDiscardButton', Popup, 'UIPanelButtonTemplate')
	Popup.discard:Width(150)
	Popup.discard:SetText(L["Discard"])
	Popup.discard:SetScript('OnClick', function() AB:DeactivateBindMode(false) end)

	Popup.perCharCheck = CreateFrame('CheckButton', 'ElvUIBindPopupWindowCheckButton', Popup, 'UICheckButtonTemplate')
	_G[Popup.perCharCheck:GetName()..'Text']:SetText(CHARACTER_SPECIFIC_KEYBINDINGS)
	Popup.perCharCheck:SetScript('OnLeave', GameTooltip_Hide)
	Popup.perCharCheck:SetScript('OnShow', function(checkBtn) checkBtn:SetChecked(GetCurrentBindingSet() == 2) end)
	Popup.perCharCheck:SetScript('OnClick', function()
		if AB.bindingsChanged then
			E:StaticPopup_Show('CONFIRM_LOSE_BINDING_CHANGES')
		else
			AB:ChangeBindingProfile()
		end
	end)

	Popup.perCharCheck:SetScript('OnEnter', function(checkBtn)
		_G.GameTooltip:SetOwner(checkBtn, 'ANCHOR_RIGHT')
		_G.GameTooltip:SetText(CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP, nil, nil, nil, nil, 1)
	end)

	--position buttons
	Popup.perCharCheck:Point('BOTTOMLEFT', Popup.discard, 'TOPLEFT', 0, 2)
	Popup.save:Point('BOTTOMRIGHT', -14, 10)
	Popup.discard:Point('BOTTOMLEFT', 14, 10)

	S:HandleCheckBox(Popup.perCharCheck)
	S:HandleButton(Popup.discard)
	S:HandleButton(Popup.header)
	S:HandleButton(Popup.save)
end
