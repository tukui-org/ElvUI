local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local Skins = E:GetModule('Skins')

local _G = _G
local select, tonumber, pairs = select, tonumber, pairs
local floor = floor
local format = format

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local IsAddOnLoaded = IsAddOnLoaded
local LoadBindings, SaveBindings = LoadBindings, SaveBindings
local GetCurrentBindingSet = GetCurrentBindingSet
local SetBinding = SetBinding
local GetBindingKey = GetBindingKey
local IsAltKeyDown, IsControlKeyDown = IsAltKeyDown, IsControlKeyDown
local IsShiftKeyDown, IsModifiedClick = IsShiftKeyDown, IsModifiedClick
local InCombatLockdown = InCombatLockdown
local SpellBook_GetSpellBookSlot = SpellBook_GetSpellBookSlot
local GetSpellBookItemName = GetSpellBookItemName
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local GetMacroInfo = GetMacroInfo
local SecureActionButton_OnClick = SecureActionButton_OnClick
local GetNumFlyouts, GetFlyoutInfo = GetNumFlyouts, GetFlyoutInfo
local GetFlyoutID = GetFlyoutID
local GameTooltip_Hide = GameTooltip_Hide
local MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS
local CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP = CHARACTER_SPECIFIC_KEYBINDING_TOOLTIP
local CHARACTER_SPECIFIC_KEYBINDINGS = CHARACTER_SPECIFIC_KEYBINDINGS
-- GLOBALS: ElvUIBindPopupWindow, ElvUIBindPopupWindowCheckButton

local bind = CreateFrame('Frame', 'ElvUI_KeyBinder', E.UIParent)

function AB:ActivateBindMode()
	if InCombatLockdown() then
		return
	end

	bind.active = true
	E:StaticPopupSpecial_Show(ElvUIBindPopupWindow)
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
	E:StaticPopupSpecial_Hide(ElvUIBindPopupWindow)
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
		E:Print(format(L["All keybindings cleared for |cff00ff00%s|r."], bind.button.name))
		self:BindUpdate(bind.button, bind.spellmacro)
		if bind.spellmacro~='MACRO' and not _G.GameTooltip:IsForbidden() then
			_G.GameTooltip:Hide()
		end
		return
	end

	--Check if this button can open a flyout menu
	local isFlyout = (bind.button.FlyoutArrow and bind.button.FlyoutArrow:IsShown())

	if key == 'LSHIFT'
	or key == 'RSHIFT'
	or key == 'LCTRL'
	or key == 'RCTRL'
	or key == 'LALT'
	or key == 'RALT'
	or key == 'UNKNOWN'
	then return; end

	--Redirect LeftButton click to open flyout
	if key == 'LeftButton' and isFlyout then
		SecureActionButton_OnClick(bind.button)
	end

	if key == 'MiddleButton' then key = 'BUTTON3'; end
	if key:find('Button%d') then
		key = key:upper()
	end

	local alt = IsAltKeyDown() and 'ALT-' or ''
	local ctrl = IsControlKeyDown() and 'CTRL-' or ''
	local shift = IsShiftKeyDown() and 'SHIFT-' or ''
	local allowBinding = (not isFlyout or (isFlyout and key ~= 'LeftButton')) --Don't attempt to bind left mouse button for flyout buttons

	if not bind.spellmacro or bind.spellmacro == 'PET' or bind.spellmacro == 'STANCE' or bind.spellmacro == 'FLYOUT' then
		if allowBinding then
			SetBinding(alt..ctrl..shift..key, bind.button.bindstring)
		end
	else
		if allowBinding then
			SetBinding(alt..ctrl..shift..key, bind.spellmacro..' '..bind.button.name)
		end
	end
	if allowBinding then
		E:Print(alt..ctrl..shift..key..L[" |cff00ff00bound to |r"]..bind.button.name..'.')
	end
	self:BindUpdate(bind.button, bind.spellmacro)
	if bind.spellmacro~='MACRO' and bind.spellmacro~='FLYOUT' and not _G.GameTooltip:IsForbidden() then
		_G.GameTooltip:Hide()
	end
end

function AB:BindUpdate(button, spellmacro)
	if not bind.active or InCombatLockdown() then return; end
	local GameTooltip = _G.GameTooltip

	bind.button = button
	bind.spellmacro = spellmacro

	bind:ClearAllPoints()
	bind:SetAllPoints(button)
	bind:Show()

	_G.ShoppingTooltip1:Hide()

	if spellmacro == 'FLYOUT' then
		bind.button.name = GetSpellInfo(button.spellID)
		bind.button.bindstring = 'SPELL '..bind.button.name

		GameTooltip:SetOwner(bind, 'ANCHOR_TOP')
		GameTooltip:SetPoint('BOTTOM', bind, 'TOP', 0, 1)
		GameTooltip:AddLine(bind.button.name, 1, 1, 1)
		bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
			if #bind.button.bindings == 0 then
				GameTooltip:AddLine(L["No bindings set."], .6, .6, .6)
			else
				GameTooltip:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					GameTooltip:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
		GameTooltip:Show()

	elseif spellmacro == 'SPELL' then
		bind.button.id = SpellBook_GetSpellBookSlot(bind.button)
		bind.button.name = GetSpellBookItemName(bind.button.id, _G.SpellBookFrame.bookType)

		GameTooltip:AddLine(L["Trigger"])
		GameTooltip:Show()
		GameTooltip:SetScript('OnHide', function(tt)
			tt:SetOwner(bind, 'ANCHOR_TOP')
			tt:SetPoint('BOTTOM', bind, 'TOP', 0, 1)
			tt:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey(spellmacro..' '..bind.button.name)}
			if #bind.button.bindings == 0 then
				tt:AddLine(L["No bindings set."], .6, .6, .6)
			else
				tt:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					tt:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			tt:Show()
			tt:SetScript('OnHide', nil)
		end)
	elseif spellmacro == 'MACRO' then
		bind.button.id = bind.button:GetID()

		if floor(.5+select(2,_G.MacroFrameTab1Text:GetTextColor())*10)/10==.8 then bind.button.id = bind.button.id + MAX_ACCOUNT_MACROS; end

		bind.button.name = GetMacroInfo(bind.button.id)

		GameTooltip:SetOwner(bind, 'ANCHOR_TOP')
		GameTooltip:SetPoint('BOTTOM', bind, 'TOP', 0, 1)
		GameTooltip:AddLine(bind.button.name, 1, 1, 1)

		bind.button.bindings = {GetBindingKey(spellmacro..' '..bind.button.name)}
			if #bind.button.bindings == 0 then
				GameTooltip:AddLine(L["No bindings set."], .6, .6, .6)
			else
				GameTooltip:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					GameTooltip:AddDoubleLine(L["Binding"]..i, bind.button.bindings[i], 1, 1, 1)
				end
			end
		GameTooltip:Show()
	elseif spellmacro=='STANCE' or spellmacro=='PET' then
		bind.button.name = button:GetName()

		if not bind.button.name then return; end

		bind.button.id = tonumber(button:GetID())
		bind.button.bindstring = (spellmacro=='STANCE' and 'SHAPESHIFTBUTTON' or 'BONUSACTIONBUTTON')..bind.button.id

		GameTooltip:SetOwner(bind, 'ANCHOR_NONE')
		GameTooltip:SetPoint('BOTTOM', bind, 'TOP', 0, 1)
		GameTooltip:AddLine(bind.button.name, 1, 1, 1)
		GameTooltip:Show()
		GameTooltip:SetScript('OnHide', function(tt)
			tt:SetOwner(bind, 'ANCHOR_NONE')
			tt:SetPoint('BOTTOM', bind, 'TOP', 0, 1)
			tt:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
			if #bind.button.bindings == 0 then
				tt:AddLine(L["No bindings set."], .6, .6, .6)
			else
				tt:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					tt:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			tt:Show()
			tt:SetScript('OnHide', nil)
		end)
	else
		bind.button.name = button:GetName()

		if not bind.button.name then return; end
		bind.button.action = tonumber(button.action)

		if bind.button.keyBoundTarget then
			bind.button.bindstring = bind.button.keyBoundTarget
		else
			local modact = 1+(bind.button.action-1)%12
			if bind.button.name == 'ExtraActionButton1' then
				bind.button.bindstring = 'EXTRAACTIONBUTTON1'
			elseif bind.button.action < 25 or bind.button.action > 72 then
				bind.button.bindstring = 'ACTIONBUTTON'..modact
			elseif bind.button.action < 73 and bind.button.action > 60 then
				bind.button.bindstring = 'MULTIACTIONBAR1BUTTON'..modact
			elseif bind.button.action < 61 and bind.button.action > 48 then
				bind.button.bindstring = 'MULTIACTIONBAR2BUTTON'..modact
			elseif bind.button.action < 49 and bind.button.action > 36 then
				bind.button.bindstring = 'MULTIACTIONBAR4BUTTON'..modact
			elseif bind.button.action < 37 and bind.button.action > 24 then
				bind.button.bindstring = 'MULTIACTIONBAR3BUTTON'..modact
			end
		end

		GameTooltip:AddLine(L["Trigger"])
		GameTooltip:Show()
		GameTooltip:SetScript('OnHide', function(tt)
			tt:SetOwner(bind, 'ANCHOR_TOP')
			tt:SetPoint('BOTTOM', bind, 'TOP', 0, 4)
			tt:AddLine(bind.button.name, 1, 1, 1)
			bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
			if #bind.button.bindings == 0 then
				tt:AddLine(L["No bindings set."], .6, .6, .6)
			else
				tt:AddDoubleLine(L["Binding"], L["Key"], .6, .6, .6, .6, .6, .6)
				for i = 1, #bind.button.bindings do
					tt:AddDoubleLine(i, bind.button.bindings[i])
				end
			end
			tt:Show()
			tt:SetScript('OnHide', nil)
		end)
	end
end

function AB:RegisterButton(b)
	local stance = _G.StanceButton1:GetScript('OnClick')
	local pet = _G.PetActionButton1:GetScript('OnClick')
	if b.IsProtected and b.IsObjectType and b.GetScript and b:IsObjectType('CheckButton') and b:IsProtected() then
		local script = b:GetScript('OnClick')
		if script==pet then
			b:HookScript('OnEnter', function(s) self:BindUpdate(s, 'PET'); end)
		elseif script==stance then
			b:HookScript('OnEnter', function(s) self:BindUpdate(s, 'STANCE'); end)
		else
			b:HookScript('OnEnter', function(s) self:BindUpdate(s); end)
		end
	end
end

local elapsed = 0
function AB:Tooltip_OnUpdate(tooltip, e)
	if tooltip:IsForbidden() then return; end

	elapsed = elapsed + e
	if (elapsed < .2) then return else elapsed = 0 end

	local compareItems = IsModifiedClick('COMPAREITEMS')
	if not tooltip.comparing and compareItems and tooltip:GetItem() then
		GameTooltip_ShowCompareItem(tooltip)
		tooltip.comparing = true
	elseif tooltip.comparing and not compareItems then
		for _, frame in pairs(tooltip.shoppingTooltips) do frame:Hide() end
		tooltip.comparing = false
	end
end

function AB:UpdateFlyouts()
	for i = 1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			for k=1, numSlots do
				local b = _G.SpellFlyout:IsShown() and _G['SpellFlyoutButton'..k]
				if b and b:IsShown() and not b.hookedFlyout then
					b:HookScript('OnEnter', function(btn) AB:BindUpdate(btn, 'FLYOUT') end)
					b.hookedFlyout = true
				end
			end
		end
	end
end

function AB:RegisterMacro(addon)
	if addon == 'Blizzard_MacroUI' then
		for i=1, MAX_ACCOUNT_MACROS do
			_G['MacroButton'..i]:HookScript('OnEnter', function(btn) AB:BindUpdate(btn, 'MACRO') end)
		end
	end
end

function AB:ChangeBindingProfile()
	if ElvUIBindPopupWindowCheckButton:GetChecked() then
		LoadBindings(2)
		SaveBindings(2)
	else
		LoadBindings(1)
		SaveBindings(1)
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

	self:SecureHookScript(_G.GameTooltip, 'OnUpdate', 'Tooltip_OnUpdate')

	bind:SetScript('OnEnter', function(b) local db = b.button:GetParent().db if db and db.mouseover then AB:Button_OnEnter(b.button) end end)
	bind:SetScript('OnLeave', function(b) AB:BindHide(); local db = b.button:GetParent().db if db and db.mouseover then AB:Button_OnLeave(b.button) end end)
	bind:SetScript('OnKeyUp', function(_, key) self:BindListener(key) end)
	bind:SetScript('OnMouseUp', function(_, key) self:BindListener(key) end)
	bind:SetScript('OnMouseWheel', function(_, delta) if delta>0 then self:BindListener('MOUSEWHEELUP') else self:BindListener('MOUSEWHEELDOWN'); end end)

	for i = 1, 12 do
		local b = _G['SpellButton'..i]
		b:HookScript('OnEnter', function(s) AB:BindUpdate(s, 'SPELL'); end)
	end

	for b in pairs(self.handledbuttons) do
		self:RegisterButton(b)
	end

	if not IsAddOnLoaded('Blizzard_MacroUI') then
		self:SecureHook('LoadAddOn', 'RegisterMacro')
	else
		self:RegisterMacro('Blizzard_MacroUI')
	end

	self:SecureHook('ActionButton_UpdateFlyout', 'UpdateFlyouts')
	self:UpdateFlyouts()

	--Special Popup
	local Popup = CreateFrame('Frame', 'ElvUIBindPopupWindow', _G.UIParent)
	Popup:SetFrameStrata('DIALOG')
	Popup:EnableMouse(true)
	Popup:SetMovable(true)
	Popup:SetFrameLevel(99)
	Popup:SetClampedToScreen(true)
	Popup:SetSize(360, 130)
	Popup:SetTemplate('Transparent')
	Popup:RegisterForDrag('AnyUp', 'AnyDown')
	Popup:SetScript('OnMouseDown', Popup.StartMoving)
	Popup:SetScript('OnMouseUp', Popup.StopMovingOrSizing)
	Popup:Hide()

	Popup.header = CreateFrame('Button', nil, Popup, 'OptionsButtonTemplate')
	Popup.header:SetSize(100, 25)
	Popup.header:SetPoint('CENTER', Popup, 'TOP')
	Popup.header:RegisterForClicks('AnyUp', 'AnyDown')
	Popup.header:SetScript('OnMouseDown', function() Popup:StartMoving() end)
	Popup.header:SetScript('OnMouseUp', function() Popup:StopMovingOrSizing() end)
	Popup.header:SetText('Key Binds')

	Popup.desc = Popup:CreateFontString(nil, 'ARTWORK')
	Popup.desc:SetFontObject('GameFontHighlight')
	Popup.desc:SetJustifyV('TOP')
	Popup.desc:SetJustifyH('LEFT')
	Popup.desc:SetPoint('TOPLEFT', 18, -32)
	Popup.desc:SetPoint('BOTTOMRIGHT', -18, 48)
	Popup.desc:SetText(L["Hover your mouse over any actionbutton or spellbook button to bind it. Press the ESC key to clear the current actionbutton's keybinding."])

	Popup.save = CreateFrame('Button', Popup:GetName()..'SaveButton', Popup, 'OptionsButtonTemplate')
	Popup.save:SetText(L["Save"])
	Popup.save:SetWidth(150)
	Popup.save:SetScript('OnClick', function() AB:DeactivateBindMode(true) end)

	Popup.discard = CreateFrame('Button', Popup:GetName()..'DiscardButton', Popup, 'OptionsButtonTemplate')
	Popup.discard:SetWidth(150)
	Popup.discard:SetText(L["Discard"])
	Popup.discard:SetScript('OnClick', function() AB:DeactivateBindMode(false) end)

	Popup.perCharCheck = CreateFrame('CheckButton', Popup:GetName()..'CheckButton', Popup, 'OptionsCheckButtonTemplate')
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
	Popup.perCharCheck:SetPoint('BOTTOMLEFT', Popup.discard, 'TOPLEFT', 0, 2)
	Popup.save:SetPoint('BOTTOMRIGHT', -14, 10)
	Popup.discard:SetPoint('BOTTOMLEFT', 14, 10)

	Skins:HandleCheckBox(Popup.perCharCheck)
	Skins:HandleButton(Popup.save)
	Skins:HandleButton(Popup.discard)
	Skins:HandleButton(Popup.header)
end
