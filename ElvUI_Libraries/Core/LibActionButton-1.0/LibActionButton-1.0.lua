-- License: LICENSE.txt

local MAJOR_VERSION = "LibActionButton-1.0-ElvUI"
local MINOR_VERSION = 67 -- the real minor version is 126

local LibStub = LibStub
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end

local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type, error, tostring, tonumber, assert, select = type, error, tostring, tonumber, assert, select
local setmetatable, wipe, unpack, pairs, ipairs, next, pcall = setmetatable, wipe, unpack, pairs, ipairs, next, pcall
local hooksecurefunc, strmatch, format, tinsert, tremove = hooksecurefunc, strmatch, format, tinsert, tremove

local WoWRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local WoWClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local WoWBCC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
local WoWWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
local WoWCata = (WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC)
local WoWMists = (WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC)

-- GLOBALS: C_Item, C_Spell

local DisableOverlayGlow = WoWClassic or WoWBCC or WoWWrath

local KeyBound = LibStub("LibKeyBound-1.0", true)
local CBH = LibStub("CallbackHandler-1.0")
local LCG = LibStub("LibCustomGlow-1.0", true)
local Masque = LibStub("Masque", true)

local GetCVar = C_CVar.GetCVar
local GetCVarBool = C_CVar.GetCVarBool
local UnpackAuraData = AuraUtil.UnpackAuraData
local EnableActionRangeCheck = C_ActionBar.EnableActionRangeCheck
local GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName
local GetCooldownAuraBySpellID = C_UnitAuras.GetCooldownAuraBySpellID
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
local GetItemActionOnEquipSpellID = C_ActionBar.GetItemActionOnEquipSpellID
local IsAssistedCombatAction = C_ActionBar.IsAssistedCombatAction
local IsConsumableSpell = C_Spell.IsConsumableSpell or IsConsumableSpell
local IsSpellOverlayed = (C_SpellActivationOverlay and C_SpellActivationOverlay.IsSpellOverlayed) or IsSpellOverlayed
local GetSpellLossOfControlCooldown = C_Spell.GetSpellLossOfControlCooldown or GetSpellLossOfControlCooldown

local C_Container_GetItemCooldown = C_Container.GetItemCooldown
local C_EquipmentSet_PickupEquipmentSet = C_EquipmentSet.PickupEquipmentSet
local C_LevelLink_IsActionLocked = C_LevelLink and C_LevelLink.IsActionLocked
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo

local GetTime = GetTime
local HasAction = HasAction
local ClearCursor = ClearCursor
local CopyTable = CopyTable
local CreateFrame = CreateFrame
local UnitIsFriend = UnitIsFriend
local FlyoutHasSpell = FlyoutHasSpell
local GetActionCharges = GetActionCharges
local GetActionCooldown = GetActionCooldown
local GetActionCount = GetActionCount
local GetActionInfo = GetActionInfo
local GetActionText = GetActionText
local GetActionTexture = GetActionTexture
local GetBindingKey = GetBindingKey
local GetBindingText = GetBindingText
local GetCallPetSpellInfo = GetCallPetSpellInfo
local GetCursorInfo = GetCursorInfo
local GetFlyoutInfo = GetFlyoutInfo
local GetFlyoutSlotInfo = GetFlyoutSlotInfo
local GetItemCooldown = GetItemCooldown
local GetMacroInfo = GetMacroInfo
local GetMacroSpell = GetMacroSpell
local InCombatLockdown = InCombatLockdown
local IsActionInRange = IsActionInRange
local IsAttackAction = IsAttackAction
local IsAutoRepeatAction = IsAutoRepeatAction
local IsConsumableAction = IsConsumableAction
local IsCurrentAction = IsCurrentAction
local IsEquippedAction = IsEquippedAction
local IsItemAction = IsItemAction
local IsLoggedIn = IsLoggedIn
local IsMouseButtonDown = IsMouseButtonDown
local IsStackableAction = IsStackableAction
local IsUsableAction = IsUsableAction
local PickupAction = PickupAction
local PickupCompanion = PickupCompanion
local PickupMacro = PickupMacro
local PickupPetAction = PickupPetAction
local SetBinding = SetBinding
local SetBindingClick = SetBindingClick
local SetClampedTextureRotation = SetClampedTextureRotation
local GetActionLossOfControlCooldown = GetActionLossOfControlCooldown

local ATTACK_BUTTON_FLASH_TIME = ATTACK_BUTTON_FLASH_TIME
local COOLDOWN_TYPE_LOSS_OF_CONTROL = COOLDOWN_TYPE_LOSS_OF_CONTROL
local COOLDOWN_TYPE_NORMAL = COOLDOWN_TYPE_NORMAL
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME
local RANGE_INDICATOR = RANGE_INDICATOR

local GameFontHighlightSmallOutline = GameFontHighlightSmallOutline
local NumberFontNormalSmallGray = NumberFontNormalSmallGray
local NumberFontNormal = NumberFontNormal

local UIParent = UIParent
local GameTooltip = GameTooltip
local SpellFlyout = SpellFlyout
local FlyoutButtonMixin = FlyoutButtonMixin
local UseCustomFlyout = FlyoutButtonMixin and not ActionButton_UpdateFlyout -- Enable custom flyouts

-- unwrapped functions that return tables now
local GetSpellCharges = function(spell)
	local c = C_Spell.GetSpellCharges(spell)
	if c then
		return c.currentCharges, c.maxCharges, c.cooldownStartTime, c.cooldownDuration
	end
end

local GetSpellCooldown = C_Spell.GetSpellCooldown and function(spell)
	local c = C_Spell.GetSpellCooldown(spell)
	if c then
		return c.startTime, c.duration, c.isEnabled, c.modRate
	end
end or GetSpellCooldown

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:UnregisterAllEvents()

lib.buttonRegistry = lib.buttonRegistry or {}
lib.activeButtons = lib.activeButtons or {}
lib.actionButtons = lib.actionButtons or {}
lib.nonActionButtons = lib.nonActionButtons or {}
lib.activeAlerts = lib.activeAlerts or {}
lib.activeAssist = lib.activeAssist or {}

-- usable state for retail using slot
lib.slotByButton = lib.slotByButton or {}
lib.buttonsBySlot = lib.buttonsBySlot or {}

local AuraButtons = lib.AuraButtons or { auras = {}, buttons = {} }
lib.AuraButtons = AuraButtons

lib.ChargeCooldowns = lib.ChargeCooldowns or {}
lib.NumChargeCooldowns = lib.NumChargeCooldowns or 0

lib.FlyoutInfo = lib.FlyoutInfo or {}
lib.FlyoutButtons = lib.FlyoutButtons or {}

lib.ACTION_HIGHLIGHT_MARKS = lib.ACTION_HIGHLIGHT_MARKS or setmetatable({}, { __index = ACTION_HIGHLIGHT_MARKS })

lib.callbacks = lib.callbacks or CBH:New(lib)

local Generic = CreateFrame("CheckButton")
local Generic_MT = {__index = Generic}

local Action = setmetatable({}, {__index = Generic})
local Action_MT = {__index = Action}

--local PetAction = setmetatable({}, {__index = Generic})
--local PetAction_MT = {__index = PetAction}

local Spell = setmetatable({}, {__index = Generic})
local Spell_MT = {__index = Spell}

local Item = setmetatable({}, {__index = Generic})
local Item_MT = {__index = Item}

local Macro = setmetatable({}, {__index = Generic})
local Macro_MT = {__index = Macro}

local Toy = setmetatable({}, {__index = Generic})
local Toy_MT = {__index = Toy}

local Custom = setmetatable({}, {__index = Generic})
local Custom_MT = {__index = Custom}

local type_meta_map = {
	empty  = Generic_MT,
	action = Action_MT,
	--pet    = PetAction_MT,
	spell  = Spell_MT,
	item   = Item_MT,
	macro  = Macro_MT,
	toy    = Toy_MT,
	custom = Custom_MT
}

local GetFlyoutHandler
local InitializeEventHandler, OnEvent, ForAllButtons
local ButtonRegistry, ActiveButtons, ActionButtons, NonActionButtons = lib.buttonRegistry, lib.activeButtons, lib.actionButtons, lib.nonActionButtons

local Update, UpdateButtonState, UpdateUsable, UpdateCount, UpdateCooldown, UpdateCooldownNumberHidden, UpdateTooltip, UpdateNewAction, UpdateSpellHighlight, ClearNewActionHighlight
local StartFlash, StopFlash, UpdateFlash, UpdateHotkeys, UpdateRangeTimer, UpdateOverlayGlow
local UpdateFlyout, ShowGrid, HideGrid, UpdateGrid, SetupSecureSnippets, WrapOnClick
local ShowOverlayGlow, HideOverlayGlow
local EndChargeCooldown
local UpdateRange -- Sezz

local UpdateTargetAuras -- Simpy
local TARGETAURA_ENABLED = true
local TARGETAURA_DURATION = 0

local RangeFont
do -- properly support range symbol when it's shown ~Simpy
	local locale = GetLocale()
	local stockFont, stockFontSize, stockFontOutline
	if locale == 'koKR' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\2002.TTF]], 11, 'MONOCHROME, THICKOUTLINE'
	elseif locale == 'zhTW' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\arheiuhk_bd.TTF]], 11, 'MONOCHROME, THICKOUTLINE'
	elseif locale == 'zhCN' then
		stockFont, stockFontSize, stockFontOutline = [[Fonts\FRIZQT__.TTF]], 11, 'MONOCHROME, OUTLINE'
	else
		stockFont, stockFontSize, stockFontOutline = [[Fonts\ARIALN.TTF]], 12, 'MONOCHROME, THICKOUTLINE'
	end

	RangeFont = {
		font = {
			font = stockFont,
			size = stockFontSize,
			flags = stockFontOutline,
		},
		color = { 0.9, 0.9, 0.9 }
	}
end

local function GameTooltip_GetOwnerForbidden()
	if GameTooltip:IsForbidden() then
		return nil
	end

	return GameTooltip:GetOwner()
end

local DefaultConfig = {
	outOfRangeColoring = "button",
	tooltip = "enabled",
	enabled = true,
	showGrid = false,
	targetReticle = true,
	useColoring = true,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 },
		usable = { 1.0, 1.0, 1.0 },
		notUsable = { 0.4, 0.4, 0.4 },
	},
	hideElements = {
		count = false,
		macro = false,
		hotkey = false,
		equipped = false,
		border = false,
		borderIfEmpty = false,
	},
	keyBoundTarget = false,
	keyBoundClickButton = "LeftButton",
	clickOnDown = false,
	cooldownCount = nil, -- nil: use cvar, true/false: enable/disable
	flyoutDirection = "UP",
	disableCountDownNumbers = false,
	useDrawBling = true,
	useDrawSwipeOnCharges = true,
	handleOverlay = true,
	text = {
		hotkey = {
			font = {
				font = false, -- "Fonts\\ARIALN.TTF",
				size = 14,
				flags = "OUTLINE",
			},
			color = { 0.75, 0.75, 0.75 },
			position = {
				anchor = "TOPRIGHT",
				relAnchor = "TOPRIGHT",
				offsetX = -2,
				offsetY = -4,
			},
			justifyH = "RIGHT",
		},
		count = {
			font = {
				font = false, -- "Fonts\\ARIALN.TTF",
				size = 16,
				flags = "OUTLINE",
			},
			color = { 1, 1, 1 },
			position = {
				anchor = "BOTTOMRIGHT",
				relAnchor = "BOTTOMRIGHT",
				offsetX = -2,
				offsetY = 4,
			},
			justifyH = "RIGHT",
		},
		macro = {
			font = {
				font = false, -- "Fonts\\FRIZQT__.TTF",
				size = 12,
				flags = "OUTLINE",
			},
			color = { 1, 1, 1 },
			position = {
				anchor = "BOTTOM",
				relAnchor = "BOTTOM",
				offsetX = 0,
				offsetY = 2,
			},
			justifyH = "CENTER",
		},
	},
}

--- Create a new action button.
-- @param id Internal id of the button (not used by LibActionButton-1.0, only for tracking inside the calling addon)
-- @param name Name of the button frame to be created (not used by LibActionButton-1.0 aside from naming the frame)
-- @param header Header that drives these action buttons (if any)
function lib:CreateButton(id, name, header, config)
	if type(name) ~= "string" then
		error("Usage: CreateButton(id, name. header): Buttons must have a valid name!", 2)
	end
	if not header then
		error("Usage: CreateButton(id, name, header): Buttons without a secure header are not yet supported!", 2)
	end

	if not KeyBound then
		KeyBound = LibStub("LibKeyBound-1.0", true)
	end

	local button = setmetatable(CreateFrame("CheckButton", name, header, "ActionButtonTemplate, SecureActionButtonTemplate"), Generic_MT)
	button:RegisterForDrag("LeftButton", "RightButton")
	if WoWRetail then
		button:RegisterForClicks("AnyDown", "AnyUp")
	else
		button:RegisterForClicks("AnyUp")
	end

	button.cooldown:SetFrameStrata(button:GetFrameStrata())
	button.cooldown:SetFrameLevel(button:GetFrameLevel() + 1)

	local AuraCooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	AuraCooldown:SetDrawBling(false)
	AuraCooldown:SetDrawSwipe(false)
	AuraCooldown:SetDrawEdge(false)
	button.AuraCooldown = AuraCooldown

	-- Frame Scripts
	button:SetScript("OnEnter", Generic.OnEnter)
	button:SetScript("OnLeave", Generic.OnLeave)
	button:SetScript("PreClick", Generic.PreClick)
	button:SetScript("PostClick", Generic.PostClick)
	button:SetScript("OnEvent", Generic.OnButtonEvent)

	button.id = id
	button.header = header
	-- Mapping of state -> action
	button.state_types = {}
	button.state_actions = {}

	-- Store the LAB Version that created this button for debugging
	button.__LAB_Version = MINOR_VERSION

	-- just in case we're not run by a header, default to state 0
	button:SetAttribute("state", 0)

	SetupSecureSnippets(button)
	WrapOnClick(button)

	-- if there is no button yet, initialize events later
	local InitializeEvents = not next(ButtonRegistry)

	-- Store the button in the registry, needed for event and OnUpdate handling
	ButtonRegistry[button] = true

	-- setup button configuration
	button:UpdateConfig(config)

	-- run an initial update
	button:UpdateAction()
	UpdateHotkeys(button)

	button:SetAttribute("LABUseCustomFlyout", UseCustomFlyout)

	-- nil out inherited functions from the flyout mixin, we override these in a metatable
	if UseCustomFlyout then
		button.GetPopupDirection = nil
		button.IsPopupOpen = nil
	end

	-- initialize events
	if InitializeEvents then
		InitializeEventHandler()
	end

	-- somewhat of a hack for the Flyout buttons to not error.
	button.action = 0

	lib.callbacks:Fire("OnButtonCreated", button)

	return button
end

function lib:GetSpellFlyoutFrame()
	return lib.flyoutHandler
end

function SetupSecureSnippets(button)
	button:SetAttribute("_custom", Custom.RunCustom)
	-- secure UpdateState(self, state)

	-- button state for push casting
	if C_Spell.IsPressHoldReleaseSpell then -- retail only
		button:SetAttribute("UpdateReleaseCasting", [[
			local type, action = ...

			local spellID
			if type == 'action' then
				local actionType, id, subType = GetActionInfo(action)
				if actionType == 'spell' then
					spellID = id
				elseif actionType == 'macro' and subType == 'spell' then
					spellID = id
				end
			elseif type == 'spell' then
				spellID = action
			end

			-- IsPressHoldReleaseSpell is on _G here not on C_Spell
			if spellID and IsPressHoldReleaseSpell(spellID) then
				self:SetAttribute('pressAndHoldAction', true)
				self:SetAttribute('typerelease', 'actionrelease')
			elseif self:GetAttribute('typerelease') then
				self:SetAttribute('typerelease', nil)
			end
		]])
	end

	-- update the type and action of the button based on the state
	button:SetAttribute("UpdateState", [[
		local state = ...
		self:SetAttribute("state", state)
		local type, action = (self:GetAttribute(format("labtype-%s", state)) or "empty"), self:GetAttribute(format("labaction-%s", state))

		self:SetAttribute("type", type)
		if type ~= "empty" and type ~= "custom" then
			local action_field = (type == "pet") and "action" or type
			self:SetAttribute(action_field, action)
			self:SetAttribute("action_field", action_field)
		end

		local updateReleaseCasting = self:GetAttribute("UpdateReleaseCasting")
		if updateReleaseCasting then
			self:RunAttribute("UpdateReleaseCasting", type, action)
		end

		local onStateChanged = self:GetAttribute("OnStateChanged")
		if onStateChanged then
			self:Run(onStateChanged, state, type, action)
		end
	]])

	-- this function is invoked by the header when the state changes
	button:SetAttribute("_childupdate-state", [[
		self:RunAttribute("UpdateState", message)
		self:CallMethod("UpdateAction")
	]])

	-- secure PickupButton(self, kind, value, ...)
	-- utility function to place a object on the cursor
	button:SetAttribute("PickupButton", [[
		local kind, value = ...
		if kind == "empty" then
			return "clear"
		elseif kind == "action" or kind == "pet" then
			local actionType = (kind == "pet") and "petaction" or kind
			return actionType, value
		elseif kind == "spell" or kind == "item" or kind == "macro" then
			return "clear", kind, value
		else
			print("LibActionButton-1.0: Unknown type: " .. tostring(kind))
			return false
		end
	]])

	button:SetAttribute("OnDragStart", [[
		if (self:GetAttribute("buttonlock") and not IsModifiedClick("PICKUPACTION")) or self:GetAttribute("LABdisableDragNDrop") then return false end
		local state = self:GetAttribute("state")
		local type = self:GetAttribute("type")
		-- if the button is empty, we can't drag anything off it
		if type == "empty" or type == "custom" then
			return false
		end
		-- Get the value for the action attribute
		local action_field = self:GetAttribute("action_field")
		local action = self:GetAttribute(action_field)

		-- non-action fields need to change their type to empty
		if type ~= "action" and type ~= "pet" then
			self:SetAttribute(format("labtype-%s", state), "empty")
			self:SetAttribute(format("labaction-%s", state), nil)
			-- update internal state
			self:RunAttribute("UpdateState", state)
			-- send a notification to the insecure code
			self:CallMethod("ButtonContentsChanged", state, "empty", nil)
		end
		-- return the button contents for pickup
		return self:RunAttribute("PickupButton", type, action)
	]])

	button:SetAttribute("OnReceiveDrag", [[
		if self:GetAttribute("LABdisableDragNDrop") then return false end
		local kind, value, subtype, extra = ...
		if not kind or not value then return false end
		local state = self:GetAttribute("state")
		local buttonType, buttonAction = self:GetAttribute("type"), nil
		if buttonType == "custom" then return false end
		-- action buttons can do their magic themself
		-- for all other buttons, we'll need to update the content now
		if buttonType ~= "action" and buttonType ~= "pet" then
			-- with "spell" types, the 4th value contains the actual spell id
			if kind == "spell" then
				if extra then
					value = extra
				else
					print("no spell id?", ...)
				end
			elseif kind == "item" and value then
				value = format("item:%d", value)
			end

			-- Get the action that was on the button before
			if buttonType ~= "empty" then
				buttonAction = self:GetAttribute(self:GetAttribute("action_field"))
			end

			-- TODO: validate what kind of action is being fed in here
			-- We can only use a handful of the possible things on the cursor
			-- return false for all those we can't put on buttons

			self:SetAttribute(format("labtype-%s", state), kind)
			self:SetAttribute(format("labaction-%s", state), value)
			-- update internal state
			self:RunAttribute("UpdateState", state)
			-- send a notification to the insecure code
			self:CallMethod("ButtonContentsChanged", state, kind, value)
		else
			-- get the action for (pet-)action buttons
			buttonAction = self:GetAttribute("action")
		end
		return self:RunAttribute("PickupButton", buttonType, buttonAction)
	]])

	button:SetScript("OnDragStart", nil)
	-- Wrapped OnDragStart(self, button, kind, value, ...)
	button.header:WrapScript(button, "OnDragStart", [[
		return self:RunAttribute("OnDragStart")
	]])
	-- Wrap twice, because the post-script is not run when the pre-script causes a pickup (doh)
	-- we also need some phony message, or it won't work =/
	button.header:WrapScript(button, "OnDragStart", [[
		return "message", "update"
	]], [[
		self:RunAttribute("UpdateState", self:GetAttribute("state"))
	]])

	button:SetScript("OnReceiveDrag", nil)
	-- Wrapped OnReceiveDrag(self, button, kind, value, ...)
	button.header:WrapScript(button, "OnReceiveDrag", [[
		return self:RunAttribute("OnReceiveDrag", kind, value, ...)
	]])
	-- Wrap twice, because the post-script is not run when the pre-script causes a pickup (doh)
	-- we also need some phony message, or it won't work =/
	button.header:WrapScript(button, "OnReceiveDrag", [[
		return "message", "update"
	]], [[
		self:RunAttribute("UpdateState", self:GetAttribute("state"))
	]])

	if UseCustomFlyout then
		button.header:SetFrameRef("flyoutHandler", GetFlyoutHandler())
	end
end

function WrapOnClick(button, unwrapheader)
	-- unwrap OnClick until we got our old script out
	if unwrapheader and unwrapheader.UnwrapScript then
		local wrapheader
		repeat
			wrapheader = unwrapheader:UnwrapScript(button, "OnClick")
		until (not wrapheader or wrapheader == unwrapheader)
	end

	-- Wrap OnClick, to catch changes to actions that are applied with a click on the button.
	button.header:WrapScript(button, "OnClick", [[
		if self:GetAttribute("type") == "action" then
			local type, action = GetActionInfo(self:GetAttribute("action"))

			if type == "flyout" and self:GetAttribute("LABUseCustomFlyout") then
				local flyoutHandler = owner:GetFrameRef("flyoutHandler")
				if not down and flyoutHandler then
					flyoutHandler:SetAttribute("flyoutParentHandle", self)
					flyoutHandler:RunAttribute("HandleFlyout", action)
				end

				self:CallMethod("UpdateFlyout")
				return false
			end

			-- hide the flyout
			local flyoutHandler = owner:GetFrameRef("flyoutHandler")
			if flyoutHandler then
				flyoutHandler:Hide()
			end

			-- if this is a pickup click, disable on-down casting
			-- it should get re-enabled in the post handler, or the OnDragStart handler, whichever occurs
			if button ~= "Keybind" and ((self:GetAttribute("unlockedpreventdrag") and not self:GetAttribute("buttonlock")) or IsModifiedClick("PICKUPACTION")) and not self:GetAttribute("LABdisableDragNDrop") then
				local useOnkeyDown = self:GetAttribute("useOnKeyDown")
				if useOnkeyDown ~= false then
					self:SetAttribute("LABToggledOnDown", true)
					self:SetAttribute("LABToggledOnDownBackup", useOnkeyDown)
					self:SetAttribute("useOnKeyDown", false)
				end
			end

			return (button == "Keybind") and "LeftButton" or nil, format("%s|%s", tostring(type), tostring(action))
		end

		-- hide the flyout, the extra down/ownership check is needed to not hide the button we're currently pressing too early
		local flyoutHandler = owner:GetFrameRef("flyoutHandler")
		if flyoutHandler and (not down or self:GetParent() ~= flyoutHandler) then
			flyoutHandler:Hide()
		end

		if button == "Keybind" then
			return "LeftButton"
		end
	]], [[
		local type, action = GetActionInfo(self:GetAttribute("action"))
		if message ~= format("%s|%s", tostring(type), tostring(action)) then
			self:RunAttribute("UpdateState", self:GetAttribute("state"))
		end

		-- re-enable ondown casting if needed
		if self:GetAttribute("LABToggledOnDown") then
			self:SetAttribute("useOnKeyDown", self:GetAttribute("LABToggledOnDownBackup"))
			self:SetAttribute("LABToggledOnDown", nil)
			self:SetAttribute("LABToggledOnDownBackup", nil)
		end
	]])
end

-- prevent pickup calling spells ~Simpy
function Generic:OnButtonEvent(event, key, down, spellID)
	if event == "UNIT_SPELLCAST_RETICLE_TARGET" then
		if (self.abilityID == spellID) and not self.TargetReticleAnimFrame:IsShown() then
			self.TargetReticleAnimFrame.HighlightAnim:Play()
			self.TargetReticleAnimFrame:Show()
		end
	elseif event == "UNIT_SPELLCAST_RETICLE_CLEAR" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" or event == "UNIT_SPELLCAST_FAILED" then
		if self.TargetReticleAnimFrame:IsShown() then
			self.TargetReticleAnimFrame:Hide()
		end
	elseif event == "GLOBAL_MOUSE_UP" then
		self:UnregisterEvent(event)

		UpdateFlyout(self)
	end
end

-----------------------------------------------------------
--- retail range event api ~Simpy

local function WatchRange(button, slot)
	if not lib.buttonsBySlot[slot] then
		lib.buttonsBySlot[slot] = {}
	end

	lib.buttonsBySlot[slot][button] = true
	lib.slotByButton[button] = slot

	if WoWRetail then -- activate the event for slot
		EnableActionRangeCheck(slot, true)
	end
end

local function ClearRange(button, slot)
	local buttons = lib.buttonsBySlot[slot]
	if buttons then
		buttons[button] = nil

		if not next(buttons) then -- deactivate event for slot (unused)
			if WoWRetail then
				EnableActionRangeCheck(slot, false)
			end

			lib.buttonsBySlot[slot] = nil
		end
	end
end

local function SetupRange(button, hasTexture)
	if hasTexture and button._state_type == 'action' then
		local action = button._state_action
		if action then
			local slot = lib.slotByButton[button]
			if not slot then -- new action
				WatchRange(button, action)
			elseif slot ~= action then -- changed action
				WatchRange(button, action) -- add new action
				ClearRange(button, slot) -- clear previous action
			end
		end
	else -- remove old action
		local slot = lib.slotByButton[button]
		if slot then
			lib.slotByButton[button] = nil

			ClearRange(button, slot)
		end
	end
end

-----------------------------------------------------------
--- utility

local function UpdateAbilityInfo(self)
	local isTypeAction = self._state_type == 'action'
	if isTypeAction then
		local actionType, actionID, subType = GetActionInfo(self._state_action)
		local actionSpell, actionMacro, actionFlyout = actionType == 'spell', actionType == 'macro', actionType == 'flyout'
		local macroSpell = actionMacro and ((subType == 'spell' and actionID) or (subType ~= 'spell' and GetMacroSpell(actionID))) or nil
		local spellID = (actionSpell and actionID) or macroSpell

		local spell = spellID and C_Spell.GetSpellInfo(spellID)
		local spellName = (spell and spell.name) or nil

		self.isFlyoutButton = actionFlyout
		self.abilityName = spellName
		self.abilityID = spellID

		AuraButtons.buttons[self] = spellName

		if spellName then
			if not AuraButtons.auras[spellName] then
				AuraButtons.auras[spellName] = {}
			end

			tinsert(AuraButtons.auras[spellName], self)
		end
	else
		self.isFlyoutButton = nil
		self.abilityName = nil
		self.abilityID = nil
	end
end

function lib:GetAllButtons()
	local buttons = {}
	for button in next, ButtonRegistry do
		buttons[button] = true
	end
	return buttons
end

function Generic:ClearSetPoint(...)
	self:ClearAllPoints()
	self:SetPoint(...)
end

function Generic:NewHeader(header)
	local oldheader = self.header
	self.header = header
	self:SetParent(header)
	SetupSecureSnippets(self)
	WrapOnClick(self, oldheader)
end

-----------------------------------------------------------
--- state management

function Generic:ClearStates()
	for state in pairs(self.state_types) do
		self:SetAttribute(format("labtype-%s", state), nil)
		self:SetAttribute(format("labaction-%s", state), nil)
	end

	wipe(self.state_types)
	wipe(self.state_actions)
end

function Generic:SetStateFromHandlerInsecure(state, kind, action)
	state = tostring(state)
	-- we allow a nil kind for setting a empty state
	if not kind then kind = "empty" end
	if not type_meta_map[kind] then
		error("SetStateAction: unknown action type: " .. tostring(kind), 2)
	end
	if kind ~= "empty" and action == nil then
		error("SetStateAction: an action is required for non-empty states", 2)
	end
	if kind ~= "custom" and action ~= nil and type(action) ~= "number" and type(action) ~= "string" or (kind == "custom" and type(action) ~= "table") then
		error("SetStateAction: invalid action data type, only strings and numbers allowed", 2)
	end

	if kind == "item" then
		if tonumber(action) then
			action = format("item:%s", action)
		else
			local itemString = strmatch(action, "^|c[^|]+|H(item[%d:]+)|h%[")
			if itemString then
				action = itemString
			end
		end
	end

	self.state_types[state] = kind
	self.state_actions[state] = action
end

function Generic:SetState(state, kind, action)
	if not state then state = self:GetAttribute("state") end
	state = tostring(state)

	self:SetStateFromHandlerInsecure(state, kind, action)
	self:UpdateState(state)
end

function Generic:UpdateState(state)
	if not state then
		state = self:GetAttribute("state")
	end

	state = tostring(state)

	self:SetAttribute(format("labtype-%s", state), self.state_types[state])
	self:SetAttribute(format("labaction-%s", state), self.state_actions[state])

	if state ~= tostring(self:GetAttribute("state")) then
		return
	end

	if self.header then
		self.header:SetFrameRef("updateButton", self)
		self.header:Execute([[
			local frame = self:GetFrameRef("updateButton")
			control:RunFor(frame, frame:GetAttribute("UpdateState"), frame:GetAttribute("state"))
		]])
	end

	self:UpdateAction()
end

function Generic:GetAction(state)
	if not state then state = self:GetAttribute("state") end
	state = tostring(state)
	return self.state_types[state] or "empty", self.state_actions[state]
end

function Generic:UpdateAllStates()
	for state in pairs(self.state_types) do
		self:UpdateState(state)
	end
end

function Generic:ButtonContentsChanged(state, kind, value)
	state = tostring(state)
	self.state_types[state] = kind or "empty"
	self.state_actions[state] = value
	lib.callbacks:Fire("OnButtonContentsChanged", self, state, self.state_types[state], self.state_actions[state])
	self:UpdateAction(self)
end

function Generic:DisableDragNDrop(flag)
	if InCombatLockdown() then
		error("LibActionButton-1.0: You can only toggle DragNDrop out of combat!", 2)
	end

	self:SetAttribute("LABdisableDragNDrop", flag and true or nil)
end

function Generic:AddToButtonFacade(group)
	if type(group) ~= "table" or type(group.AddButton) ~= "function" then
		error("LibActionButton-1.0:AddToButtonFacade: You need to supply a proper group to use!", 2)
	end
	group:AddButton(self)
	self.LBFSkinned = true
end

function Generic:AddToMasque(group)
	if type(group) ~= "table" or type(group.AddButton) ~= "function" then
		error("LibActionButton-1.0:AddToMasque: You need to supply a proper group to use!", 2)
	end
	group:AddButton(self, nil, "Action")
	self.MasqueSkinned = true
end

function Generic:UpdateAlpha()
	UpdateCooldown(self)
end

-----------------------------------------------------------
--- flyouts

local DiscoverFlyoutSpells, UpdateFlyoutSpells, UpdateFlyoutHandlerScripts, FlyoutUpdateQueued

if UseCustomFlyout then
	-- params: self, flyoutID
	local FlyoutHandleFunc = [[
		local SPELLFLYOUT_DEFAULT_SPACING = 4
		local SPELLFLYOUT_INITIAL_SPACING = 7
		local SPELLFLYOUT_FINAL_SPACING = 9

		local parent = self:GetAttribute("flyoutParentHandle")
		if not parent then return end

		if self:IsShown() and self:GetParent() == parent then
			self:Hide()
			return
		end

		local flyoutID = ...
		local info = LAB_FlyoutInfo[flyoutID]
		if not info then print("LAB: Flyout missing with ID " .. flyoutID) return end

		local oldParent = self:GetParent()
		self:SetParent(parent)

		local direction = parent:GetAttribute("flyoutDirection") or "UP"

		local usedSlots = 0
		local prevButton
		for slotID, slotInfo in ipairs(info.slots) do
			if slotInfo.isKnown then
				usedSlots = usedSlots + 1
				local slotButton = self:GetFrameRef("flyoutButton" .. usedSlots)

				-- set secure action attributes
				slotButton:SetAttribute("type", "spell")
				slotButton:SetAttribute("spell", slotInfo.spellID)

				-- custom ones for elvui
				slotButton:SetAttribute("spellName", slotInfo.spellName)

				-- set LAB attributes
				slotButton:SetAttribute("labtype-0", "spell")
				slotButton:SetAttribute("labaction-0", slotInfo.spellID)

				-- run LAB updates
				slotButton:CallMethod("SetStateFromHandlerInsecure", 0, "spell", slotInfo.overrideSpellID or slotInfo.spellID)
				slotButton:CallMethod("UpdateAction")

				slotButton:ClearAllPoints()

				if direction == "UP" then
					if prevButton then
						slotButton:SetPoint("BOTTOM", prevButton, "TOP", 0, SPELLFLYOUT_DEFAULT_SPACING)
					else
						slotButton:SetPoint("BOTTOM", self, "BOTTOM", 0, SPELLFLYOUT_INITIAL_SPACING)
					end
				elseif direction == "DOWN" then
					if prevButton then
						slotButton:SetPoint("TOP", prevButton, "BOTTOM", 0, -SPELLFLYOUT_DEFAULT_SPACING)
					else
						slotButton:SetPoint("TOP", self, "TOP", 0, -SPELLFLYOUT_INITIAL_SPACING)
					end
				elseif direction == "LEFT" then
					if prevButton then
						slotButton:SetPoint("RIGHT", prevButton, "LEFT", -SPELLFLYOUT_DEFAULT_SPACING, 0)
					else
						slotButton:SetPoint("RIGHT", self, "RIGHT", -SPELLFLYOUT_INITIAL_SPACING, 0)
					end
				elseif direction == "RIGHT" then
					if prevButton then
						slotButton:SetPoint("LEFT", prevButton, "RIGHT", SPELLFLYOUT_DEFAULT_SPACING, 0)
					else
						slotButton:SetPoint("LEFT", self, "LEFT", SPELLFLYOUT_INITIAL_SPACING, 0)
					end
				end

				slotButton:Show()
				prevButton = slotButton
			end
		end

		-- hide excess buttons
		for i = usedSlots + 1, self:GetAttribute("numFlyoutButtons") do
			local slotButton = self:GetFrameRef("flyoutButton" .. i)
			if slotButton then
				slotButton:Hide()

				-- unset its action, so it stops updating
				slotButton:SetAttribute("labtype-0", "empty")
				slotButton:SetAttribute("labaction-0", nil)

				slotButton:CallMethod("SetStateFromHandlerInsecure", 0, "empty")
				slotButton:CallMethod("UpdateAction")
			end
		end

		if usedSlots == 0 then
			self:Hide()
			return
		end

		-- calculate extent for the long dimension
		-- 3 pixel extra initial padding, button size + padding, and everything at 0.8 scale
		local extent = (3 + (45 + 4) * usedSlots) * 0.8

		self:ClearAllPoints()

		if direction == "UP" then
			self:SetPoint("BOTTOM", parent, "TOP")
			self:SetWidth(45)
			self:SetHeight(extent)
		elseif direction == "DOWN" then
			self:SetPoint("TOP", parent, "BOTTOM")
			self:SetWidth(45)
			self:SetHeight(extent)
		elseif direction == "LEFT" then
			self:SetPoint("RIGHT", parent, "LEFT")
			self:SetWidth(extent)
			self:SetHeight(45)
		elseif direction == "RIGHT" then
			self:SetPoint("LEFT", parent, "RIGHT")
			self:SetWidth(extent)
			self:SetHeight(45)
		end

		self:SetFrameStrata("DIALOG")
		self:Show()

		self:CallMethod("ShowFlyoutInsecure", direction)

		if oldParent and oldParent:GetAttribute("LABUseCustomFlyout") then
			oldParent:CallMethod("UpdateFlyout")
		end
	]]

	local SPELLFLYOUT_INITIAL_SPACING = 7
	local function ShowFlyoutInsecure(self, direction)
		self.Background.End:ClearAllPoints()
		self.Background.Start:ClearAllPoints()
		if direction == "UP" then
			self.Background.End:SetPoint("TOP", 0, SPELLFLYOUT_INITIAL_SPACING)
			SetClampedTextureRotation(self.Background.End, 0)
			SetClampedTextureRotation(self.Background.VerticalMiddle, 0)
			self.Background.Start:SetPoint("TOP", self.Background.VerticalMiddle, "BOTTOM")
			SetClampedTextureRotation(self.Background.Start, 0)
			self.Background.HorizontalMiddle:Hide()
			self.Background.VerticalMiddle:Show()
			self.Background.VerticalMiddle:ClearAllPoints()
			self.Background.VerticalMiddle:SetPoint("TOP", self.Background.End, "BOTTOM")
			self.Background.VerticalMiddle:SetPoint("BOTTOM", 0, 0)
		elseif direction == "DOWN" then
			self.Background.End:SetPoint("BOTTOM", 0, -SPELLFLYOUT_INITIAL_SPACING)
			SetClampedTextureRotation(self.Background.End, 180)
			SetClampedTextureRotation(self.Background.VerticalMiddle, 180)
			self.Background.Start:SetPoint("BOTTOM", self.Background.VerticalMiddle, "TOP")
			SetClampedTextureRotation(self.Background.Start, 180)
			self.Background.HorizontalMiddle:Hide()
			self.Background.VerticalMiddle:Show()
			self.Background.VerticalMiddle:ClearAllPoints()
			self.Background.VerticalMiddle:SetPoint("BOTTOM", self.Background.End, "TOP")
			self.Background.VerticalMiddle:SetPoint("TOP", 0, -0)
		elseif direction == "LEFT" then
			self.Background.End:SetPoint("LEFT", -SPELLFLYOUT_INITIAL_SPACING, 0)
			SetClampedTextureRotation(self.Background.End, 270)
			SetClampedTextureRotation(self.Background.HorizontalMiddle, 180)
			self.Background.Start:SetPoint("LEFT", self.Background.HorizontalMiddle, "RIGHT")
			SetClampedTextureRotation(self.Background.Start, 270)
			self.Background.VerticalMiddle:Hide()
			self.Background.HorizontalMiddle:Show()
			self.Background.HorizontalMiddle:ClearAllPoints()
			self.Background.HorizontalMiddle:SetPoint("LEFT", self.Background.End, "RIGHT")
			self.Background.HorizontalMiddle:SetPoint("RIGHT", -0, 0)
		elseif direction == "RIGHT" then
			self.Background.End:SetPoint("RIGHT", SPELLFLYOUT_INITIAL_SPACING, 0)
			SetClampedTextureRotation(self.Background.End, 90)
			SetClampedTextureRotation(self.Background.HorizontalMiddle, 0)
			self.Background.Start:SetPoint("RIGHT", self.Background.HorizontalMiddle, "LEFT")
			SetClampedTextureRotation(self.Background.Start, 90)
			self.Background.VerticalMiddle:Hide()
			self.Background.HorizontalMiddle:Show()
			self.Background.HorizontalMiddle:ClearAllPoints()
			self.Background.HorizontalMiddle:SetPoint("RIGHT", self.Background.End, "LEFT")
			self.Background.HorizontalMiddle:SetPoint("LEFT", 0, 0)
		end

		if direction == "UP" or direction == "DOWN" then
			self.Background.Start:SetWidth(47)
			self.Background.HorizontalMiddle:SetWidth(47)
			self.Background.VerticalMiddle:SetWidth(47)
			self.Background.End:SetWidth(47)
		else
			self.Background.Start:SetHeight(47)
			self.Background.HorizontalMiddle:SetHeight(47)
			self.Background.VerticalMiddle:SetHeight(47)
			self.Background.End:SetHeight(47)
		end
	end

	function UpdateFlyoutHandlerScripts()
		lib.flyoutHandler:SetAttribute("HandleFlyout", FlyoutHandleFunc)
		lib.flyoutHandler.ShowFlyoutInsecure = ShowFlyoutInsecure
	end

	local function FlyoutOnShowHide(self)
		local parent = self:GetParent()
		if parent and parent.UpdateFlyout then
			parent:UpdateFlyout()
		end
	end

	function GetFlyoutHandler()
		if not lib.flyoutHandler then
			lib.flyoutHandler = CreateFrame("Frame", "LABFlyoutHandlerFrame", UIParent, "SecureHandlerBaseTemplate")
			lib.flyoutHandler.Background = CreateFrame("Frame", nil, lib.flyoutHandler)
			lib.flyoutHandler.Background:SetAllPoints()
			lib.flyoutHandler.Background.End = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.End:SetAtlas("UI-HUD-ActionBar-IconFrame-FlyoutButton", true)
			lib.flyoutHandler.Background.HorizontalMiddle = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.HorizontalMiddle:SetAtlas("_UI-HUD-ActionBar-IconFrame-FlyoutMidLeft", true)
			lib.flyoutHandler.Background.HorizontalMiddle:SetHorizTile(true)
			lib.flyoutHandler.Background.VerticalMiddle = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.VerticalMiddle:SetAtlas("!UI-HUD-ActionBar-IconFrame-FlyoutMid", true)
			lib.flyoutHandler.Background.VerticalMiddle:SetVertTile(true)
			lib.flyoutHandler.Background.Start = lib.flyoutHandler.Background:CreateTexture(nil, "BACKGROUND")
			lib.flyoutHandler.Background.Start:SetAtlas("UI-HUD-ActionBar-IconFrame-FlyoutBottom", true)

			lib.flyoutHandler.Background.Start:SetVertexColor(0.7, 0.7, 0.7)
			lib.flyoutHandler.Background.HorizontalMiddle:SetVertexColor(0.7, 0.7, 0.7)
			lib.flyoutHandler.Background.VerticalMiddle:SetVertexColor(0.7, 0.7, 0.7)
			lib.flyoutHandler.Background.End:SetVertexColor(0.7, 0.7, 0.7)

			lib.flyoutHandler:Hide()

			lib.flyoutHandler:SetScript("OnShow", FlyoutOnShowHide)
			lib.flyoutHandler:SetScript("OnHide", FlyoutOnShowHide)

			lib.flyoutHandler:SetAttribute("numFlyoutButtons", 0)
			UpdateFlyoutHandlerScripts()
		end

		return lib.flyoutHandler
	end

	-- sync flyout information to the restricted environment
	local InSync = false
	local function SyncFlyoutInfoToHandler()
		if InCombatLockdown() or InSync then return end
		InSync = true

		local maxNumSlots = 0

		local data = "LAB_FlyoutInfo = newtable();\n"
		for flyoutID, info in pairs(lib.FlyoutInfo) do
			if info.isKnown then
				local numSlots = 0
				data = data .. ("local info = newtable();LAB_FlyoutInfo[%d] = info;info.slots = newtable();\n"):format(flyoutID)
				for slotID, slotInfo in ipairs(info.slots) do
					data = data .. ("local info = newtable();LAB_FlyoutInfo[%d].slots[%d] = info;info.spellID = %d;info.overrideSpellID = %d;info.isKnown = %s;info.spellName = %s;\n"):format(flyoutID, slotID, slotInfo.spellID, slotInfo.overrideSpellID, slotInfo.isKnown and "true" or "nil", slotInfo.spellName and format('"%s"', slotInfo.spellName) or nil)
					numSlots = numSlots + 1
				end

				if numSlots > maxNumSlots then
					maxNumSlots = numSlots
				end
			end
		end

		-- load generated data into the restricted environment
		GetFlyoutHandler():Execute(data)

		if maxNumSlots > #lib.FlyoutButtons then
			for i = #lib.FlyoutButtons + 1, maxNumSlots do
				local button = lib:CreateButton(i, "LABFlyoutButton" .. i, lib.flyoutHandler, nil)

				button:SetScale(0.8)
				button:Hide()

				button.isFlyout = true

				-- disable drag and drop
				button:SetAttribute("LABdisableDragNDrop", true)

				-- link the button to the header
				lib.flyoutHandler:SetFrameRef("flyoutButton" .. i, button)
				tinsert(lib.FlyoutButtons, button)

				lib.callbacks:Fire("OnFlyoutButtonCreated", button)
			end

			lib.flyoutHandler:SetAttribute("numFlyoutButtons", #lib.FlyoutButtons)
		end

		-- hide flyout frame
		GetFlyoutHandler():Hide()

		-- ensure buttons are cleared, they will be filled when the flyout is shown
		for i = 1, #lib.FlyoutButtons do
			lib.FlyoutButtons[i]:SetState(0, "empty")
		end

		InSync = false
	end

	-- discover all possible flyouts
	function DiscoverFlyoutSpells()
		-- 300 is a safe upper limit in 10.0.2, the highest known spell is 229
		for flyoutID = 1, 300 do
			local success, _, _, numSlots, isKnown = pcall(GetFlyoutInfo, flyoutID)
			if success then
				lib.FlyoutInfo[flyoutID] = { numSlots = numSlots, isKnown = isKnown, slots = {} }
				for slotID = 1, numSlots do
					local spellID, overrideSpellID, isKnownSlot, spellName = GetFlyoutSlotInfo(flyoutID, slotID)

					-- hide empty pet slots from the flyout
					local petIndex, petName = GetCallPetSpellInfo(spellID)
					if petIndex and (not petName or petName == "") then
						isKnownSlot = false
					end

					lib.FlyoutInfo[flyoutID].slots[slotID] = { spellID = spellID, spellName = spellName, overrideSpellID = overrideSpellID, isKnown = isKnownSlot }
				end
			end
		end

		SyncFlyoutInfoToHandler()
	end

	-- update flyout information (mostly the isKnown flag)
	function UpdateFlyoutSpells()
		if InCombatLockdown() then
			FlyoutUpdateQueued = true
			return
		end

		for flyoutID, data in pairs(lib.FlyoutInfo) do
			local success, _, _, numSlots, isKnown = pcall(GetFlyoutInfo, flyoutID)
			if success then
				data.isKnown = isKnown
				for slotID = 1, numSlots do
					local spellID, overrideSpellID, isKnownSlot, spellName = GetFlyoutSlotInfo(flyoutID, slotID)

					-- hide empty pet slots from the flyout
					local petIndex, petName = GetCallPetSpellInfo(spellID)
					if petIndex and (not petName or petName == "") then
						isKnownSlot = false
					end

					data.slots[slotID].spellID = spellID
					data.slots[slotID].spellName = spellName
					data.slots[slotID].overrideSpellID = overrideSpellID
					data.slots[slotID].isKnown = isKnownSlot
				end
			end
		end

		lib.callbacks:Fire("OnFlyoutSpells")

		SyncFlyoutInfoToHandler()
	end
end

-----------------------------------------------------------
--- frame scripts

-- copied (and adjusted) from SecureHandlers.lua
local function PickupAny(kind, target, detail, ...)
	if kind == "clear" then
		ClearCursor()
		kind, target, detail = target, detail, ...
	end

	if kind == 'action' then
		PickupAction(target)
	elseif kind == 'item' then
		C_Item.PickupItem(target)
	elseif kind == 'macro' then
		PickupMacro(target)
	elseif kind == 'petaction' then
		PickupPetAction(target)
	elseif kind == 'spell' then
		C_Spell.PickupSpell(target)
	elseif kind == 'companion' then
		PickupCompanion(target, detail)
	elseif kind == 'equipmentset' then
		C_EquipmentSet_PickupEquipmentSet(target)
	end
end

function Generic:OnEnter()
	if self.config.tooltip ~= "disabled" and (self.config.tooltip ~= "nocombat" or not InCombatLockdown()) then
		UpdateTooltip(self)
	end

	if KeyBound then
		KeyBound:Set(self)
	end

	if self._state_type == "action" and self.NewActionTexture then
		ClearNewActionHighlight(self._state_action, false, false)
		UpdateNewAction(self)
	end

	if FlyoutButtonMixin and UseCustomFlyout then
		FlyoutButtonMixin.OnEnter(self)
	else
		UpdateFlyout(self)
	end

	if not WoWRetail then
		Generic.OnButtonEvent(self, 'OnEnter')
		self:RegisterEvent('MODIFIER_STATE_CHANGED')
	end
end

function Generic:OnLeave()
	if FlyoutButtonMixin and UseCustomFlyout then
		FlyoutButtonMixin.OnLeave(self)
	else
		UpdateFlyout(self)
	end

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end

	if not WoWRetail then
		Generic.OnButtonEvent(self, 'OnLeave')
		self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	end
end

-- Insecure drag handler to allow clicking on the button with an action on the cursor
-- to place it on the button. Like action buttons work.
function Generic:PreClick()
	if self._state_type == "action" or self._state_type == "pet" or InCombatLockdown() or self:GetAttribute("LABdisableDragNDrop") then
		return
	end

	-- check if there is actually something on the cursor
	local kind, value, _subtype = GetCursorInfo()
	if not (kind and value) then return end

	self._old_type = self._state_type
	if self._state_type and self._state_type ~= "empty" then
		self._old_type = self._state_type
		self:SetAttribute("type", "empty")
		--self:SetState(nil, "empty", nil)
	end

	self._receiving_drag = true
end

local function FormatHelper(input)
	if type(input) == "string" then
		return format("%q", input)
	else
		return tostring(input)
	end
end

function Generic:PostClick(button, down)
	UpdateButtonState(self)
	UpdateFlyout(self, down)

	if self._receiving_drag and not InCombatLockdown() then
		if self._old_type then
			self:SetAttribute("type", self._old_type)
			self._old_type = nil
		end

		local oldType, oldAction = self._state_type, self._state_action
		local kind, data, subtype, extra = GetCursorInfo()

		self.header:SetFrameRef("updateButton", self)
		self.header:Execute(format([[
			local frame = self:GetFrameRef("updateButton")
			control:RunFor(frame, frame:GetAttribute("OnReceiveDrag"), %s, %s, %s, %s)
			control:RunFor(frame, frame:GetAttribute("UpdateState"), %s)
		]], FormatHelper(kind), FormatHelper(data), FormatHelper(subtype), FormatHelper(extra), FormatHelper(self:GetAttribute("state"))))

		PickupAny("clear", oldType, oldAction)
	end

	self._receiving_drag = nil

	if self._state_type == "action" and lib.ACTION_HIGHLIGHT_MARKS[self._state_action] then
		ClearNewActionHighlight(self._state_action, false, false)
	end

	if down and IsMouseButtonDown() then
		self:RegisterEvent("GLOBAL_MOUSE_UP")
	end
end

-----------------------------------------------------------
--- configuration

local function Merge(target, source, default)
	for k,v in pairs(default) do
		if type(v) ~= "table" then
			if source and source[k] ~= nil then
				target[k] = source[k]
			else
				target[k] = v
			end
		else
			if type(target[k]) ~= "table" then target[k] = {} else wipe(target[k]) end
			Merge(target[k], type(source) == "table" and source[k], v)
		end
	end

	return target
end

local function UpdateTextElement(button, element, config, defaultFont, fromRange)
	local rangeIndicator = fromRange and element:GetText() == RANGE_INDICATOR
	if rangeIndicator then
		element:SetShown(button.outOfRange)
		element:SetFont(RangeFont.font.font, RangeFont.font.size, RangeFont.font.flags)
	else
		element:SetFont(config.font.font or defaultFont, config.font.size or 11, config.font.flags or "")
	end

	if fromRange and button.outOfRange then
		element:SetVertexColor(unpack(button.config.colors.range))
	elseif rangeIndicator then
		element:SetVertexColor(unpack(RangeFont.color))
	else
		element:SetVertexColor(unpack(config.color))
	end

	element:ClearAllPoints()
	element:SetPoint(config.position.anchor, element:GetParent(), config.position.relAnchor or config.position.anchor, config.position.offsetX or 0, config.position.offsetY or 0)
	element:SetJustifyH(config.justifyH)
end

local function UpdateTextElements(button)
	UpdateTextElement(button, button.HotKey, button.config.text.hotkey, (NumberFontNormalSmallGray:GetFont()))
	UpdateTextElement(button, button.Count, button.config.text.count, (NumberFontNormal:GetFont()))
	UpdateTextElement(button, button.Name, button.config.text.macro, (GameFontHighlightSmallOutline:GetFont()))
end

function Generic:UpdateConfig(config)
	if config and type(config) ~= "table" then
		error("LibActionButton-1.0: UpdateConfig requires a valid configuration!", 2)
	end

	local oldconfig = self.config
	self.config = {}
	-- Merge the two configs
	Merge(self.config, config, DefaultConfig)

	if self.config.outOfRangeColoring == "button" or (oldconfig and oldconfig.outOfRangeColoring == "button") then
		UpdateUsable(self)
	end
	if self.config.outOfRangeColoring == "hotkey" then
		self.outOfRange = nil
	end

	if self.config.hideElements.macro then
		self.Name:Hide()
	else
		self.Name:Show()
	end

	if WoWRetail then
		if self.config.enabled and self.config.targetReticle then
			self:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
			self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
			self:RegisterUnitEvent('UNIT_SPELLCAST_FAILED', 'player')
			self:RegisterUnitEvent('UNIT_SPELLCAST_RETICLE_TARGET', 'player')
			self:RegisterUnitEvent('UNIT_SPELLCAST_RETICLE_CLEAR', 'player')
		else
			self:UnregisterEvent('UNIT_SPELLCAST_STOP')
			self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
			self:UnregisterEvent('UNIT_SPELLCAST_FAILED')
			self:UnregisterEvent('UNIT_SPELLCAST_RETICLE_TARGET')
			self:UnregisterEvent('UNIT_SPELLCAST_RETICLE_CLEAR')
		end
	end

	UpdateCooldownNumberHidden(self)
	UpdateTextElements(self)
	UpdateHotkeys(self)
	UpdateGrid(self)
	Update(self, 'UpdateConfig')

	self:SetAttribute('flyoutDirection', self.config.flyoutDirection)
	self:SetAttribute('useOnKeyDown', self.config.clickOnDown)

	if not WoWRetail then
		self:RegisterForClicks(self.config.clickOnDown and "AnyDown" or "AnyUp")
	end
end

-----------------------------------------------------------
--- event handler

function ForAllButtons(method, onlyWithAction, event)
	assert(type(method) == "function")
	for button in next, (onlyWithAction and ActiveButtons or ButtonRegistry) do
		method(button, event)
	end
end

function InitializeEventHandler()
	lib.eventFrame:SetScript("OnEvent", OnEvent)
	lib.eventFrame:RegisterEvent("CVAR_UPDATE")
	lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	lib.eventFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
	lib.eventFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
	lib.eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	lib.eventFrame:RegisterEvent("UPDATE_BINDINGS")
	lib.eventFrame:RegisterEvent("GAME_PAD_ACTIVE_CHANGED")
	lib.eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	lib.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	lib.eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
	lib.eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
	lib.eventFrame:RegisterEvent("TRADE_CLOSED")

	lib.eventFrame:RegisterUnitEvent("UNIT_AURA", "target")
	lib.eventFrame:RegisterUnitEvent("UNIT_FACTION", "target")
	lib.eventFrame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	lib.eventFrame:RegisterUnitEvent("UNIT_MODEL_CHANGED", "player")

	lib.eventFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
	lib.eventFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
	lib.eventFrame:RegisterEvent("START_AUTOREPEAT_SPELL")
	lib.eventFrame:RegisterEvent("STOP_AUTOREPEAT_SPELL")
	lib.eventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	lib.eventFrame:RegisterEvent("PET_STABLE_UPDATE")
	lib.eventFrame:RegisterEvent("PET_STABLE_SHOW")
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_ICON")

	if not WoWClassic and not WoWBCC then
		if not WoWMists then
			lib.eventFrame:RegisterEvent("ARCHAEOLOGY_CLOSED")
			lib.eventFrame:RegisterEvent("UPDATE_SUMMONPETS_ACTION")
			lib.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
			lib.eventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
		end

		lib.eventFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		lib.eventFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		lib.eventFrame:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	end

	if WoWRetail then
		lib.eventFrame:RegisterEvent("SPELLS_CHANGED")
		lib.eventFrame:RegisterEvent("ACTION_USABLE_CHANGED")
		lib.eventFrame:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
	else
		lib.eventFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
		lib.eventFrame:RegisterEvent("PET_BAR_HIDEGRID") -- Needed for classics show grid.. ACTIONBAR_SHOWGRID fires with PET_BAR_SHOWGRID but ACTIONBAR_HIDEGRID doesn't fire with PET_BAR_HIDEGRID
	end

	-- With those two, do we still need the ACTIONBAR equivalents of them?
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	lib.eventFrame:RegisterEvent("SPELL_UPDATE_USABLE")
	lib.eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	lib.eventFrame:RegisterEvent("LOSS_OF_CONTROL_ADDED")
	lib.eventFrame:RegisterEvent("LOSS_OF_CONTROL_UPDATE")

	if UseCustomFlyout then
		lib.eventFrame:RegisterEvent("PLAYER_LOGIN")
		lib.eventFrame:RegisterEvent("SPELL_FLYOUT_UPDATE")

		if IsLoggedIn() then
			DiscoverFlyoutSpells()
		end
	end
end

function OnEvent(_, event, arg1, arg2, ...)
	if event == "PLAYER_LOGIN" then
		if UseCustomFlyout then
			DiscoverFlyoutSpells()
		end
	elseif event == "CVAR_UPDATE" then
		if arg1 == "countdownForCooldowns" then
			ForAllButtons(UpdateCooldownNumberHidden)
		elseif arg1 == "assistedCombatHighlight" then
			wipe(lib.activeAssist)
		end
	elseif event == "SPELLS_CHANGED" or event == "SPELL_FLYOUT_UPDATE" then
		if UseCustomFlyout then
			UpdateFlyoutSpells()
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		for button in next, ActiveButtons do
			local texture = button:GetTexture()
			if texture then
				button.icon:SetTexture(texture)
			end
		end

		if TARGETAURA_ENABLED then
			UpdateTargetAuras(event)
		end
	elseif event == "UNIT_INVENTORY_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		local tooltipOwner = GameTooltip_GetOwnerForbidden()
		if tooltipOwner and ButtonRegistry[tooltipOwner] then
			tooltipOwner:SetTooltip()
		end
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		for button in next, ButtonRegistry do
			if button._state_type == "action" and (arg1 == 0 or arg1 == tonumber(button._state_action)) then
				ClearNewActionHighlight(button._state_action, true, false)
				Update(button, event)
			end
		end

		if TARGETAURA_ENABLED then
			UpdateTargetAuras(event)
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_VEHICLE_ACTIONBAR" then
		ForAllButtons(Update, nil, event)
	elseif event == "ACTIONBAR_SHOWGRID" then
		ShowGrid()
	elseif event == "ACTIONBAR_HIDEGRID" or event == "PET_BAR_HIDEGRID" then
		HideGrid()
	elseif event == "UPDATE_BINDINGS" or event == "GAME_PAD_ACTIVE_CHANGED" then
		ForAllButtons(UpdateHotkeys, nil, event)
	elseif event == "PLAYER_TARGET_CHANGED" then
		if TARGETAURA_ENABLED then
			UpdateTargetAuras(event)
		end

		if not WoWRetail then
			for button in next, ActiveButtons do
				UpdateRangeTimer(button)
			end
		end
	elseif event == "UNIT_FACTION" then
		if TARGETAURA_ENABLED then
			UpdateTargetAuras(event)
		end
	elseif event == "UNIT_AURA" then
		if TARGETAURA_ENABLED then
			UpdateTargetAuras(event, arg1, arg2)
		end
	elseif (event == "ACTIONBAR_UPDATE_STATE" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE")
		or (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE"  or event == "ARCHAEOLOGY_CLOSED" or event == "TRADE_CLOSED") then
		ForAllButtons(UpdateButtonState, true, event)
	elseif event == "ACTION_RANGE_CHECK_UPDATE" then
		local buttons = lib.buttonsBySlot[arg1]
		if buttons then
			for button in next, buttons do
				UpdateRange(button, nil, arg2, ...) -- inRange, checksRange
			end
		end
	elseif event == "ACTION_USABLE_CHANGED" then
		for _, change in ipairs(arg1) do
			local buttons = change.slot and lib.buttonsBySlot[change.slot]
			if buttons then
				for button in next, buttons do
					UpdateUsable(button, change.usable, change.noMana)
				end
			end
		end
	elseif event == "ACTIONBAR_UPDATE_USABLE" then
		for button in next, ActionButtons do
			UpdateUsable(button)
		end
	elseif event == "SPELL_UPDATE_USABLE" then
		for button in next, NonActionButtons do
			UpdateUsable(button)
		end
	elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
		for button in next, ActiveButtons do
			UpdateUsable(button)
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
		for button in next, ActionButtons do
			UpdateCooldown(button)
			if GameTooltip_GetOwnerForbidden() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		for button in next, NonActionButtons do
			UpdateCooldown(button)
			if GameTooltip_GetOwnerForbidden() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "LOSS_OF_CONTROL_ADDED" then
		for button in next, ActiveButtons do
			UpdateCooldown(button)
			if GameTooltip_GetOwnerForbidden() == button then
				UpdateTooltip(button)
			end
		end
	elseif event == "LOSS_OF_CONTROL_UPDATE" then
		for button in next, ActiveButtons do
			UpdateCooldown(button)
		end
	elseif event == "PLAYER_ENTER_COMBAT" then
		for button in next, ActiveButtons do
			if button:IsAttack() then
				StartFlash(button)
			end
		end
	elseif event == "PLAYER_LEAVE_COMBAT" then
		for button in next, ActiveButtons do
			if button:IsAttack() then
				StopFlash(button)
			end
		end

		if UseCustomFlyout and FlyoutUpdateQueued then
			UpdateFlyoutSpells()
			FlyoutUpdateQueued = nil
		end
	elseif event == "START_AUTOREPEAT_SPELL" then
		for button in next, ActiveButtons do
			if button:IsAutoRepeat() then
				StartFlash(button)
			end
		end
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		for button in next, ActiveButtons do
			if button.flashing and not button:IsAttack() then
				StopFlash(button)
			end
		end
	elseif event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW" then
		ForAllButtons(Update, nil, event)

		if event == "PET_STABLE_UPDATE" and UseCustomFlyout then
			UpdateFlyoutSpells()
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		lib.activeAlerts[arg1] = true

		for button in next, ActiveButtons do
			local spellId = button:GetSpellId()
			if not lib.activeAssist[spellId] then
				if spellId and spellId == arg1 then
					ShowOverlayGlow(button)
				else
					if button._state_type == "action" then
						local actionType, id = GetActionInfo(button._state_action)
						if actionType == "flyout" and FlyoutHasSpell(id, arg1) then
							ShowOverlayGlow(button)
						end
					end
				end
			end
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		lib.activeAlerts[arg1] = nil

		for button in next, ActiveButtons do
			local spellId = button:GetSpellId()
			if not lib.activeAssist[spellId] then
				if spellId and spellId == arg1 then
					HideOverlayGlow(button)
				else
					if button._state_type == "action" then
						local actionType, id = GetActionInfo(button._state_action)
						if actionType == "flyout" and FlyoutHasSpell(id, arg1) then
							HideOverlayGlow(button)
						end
					end
				end
			end
		end
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		for button in next, ActiveButtons do
			if button._state_type == "item" then
				Update(button, event)
			end
		end
	elseif event == "SPELL_UPDATE_CHARGES" then
		ForAllButtons(UpdateCount, true, event)
	elseif event == "UPDATE_SUMMONPETS_ACTION" then
		for button in next, ActiveButtons do
			if button._state_type == "action" then
				local actionType, _id = GetActionInfo(button._state_action)
				if actionType == "summonpet" then
					local texture = GetActionTexture(button._state_action)
					if texture then
						button.icon:SetTexture(texture)
					end
				end
			end
		end
	elseif event == "SPELL_UPDATE_ICON" then
		ForAllButtons(Update, true, event)
	end
end

function Generic:OnUpdate(elapsed)
	if self.flashing then
		self.flashTime = (self.flashTime or 0) - elapsed

		if self.flashTime <= 0 then
			self.Flash:SetShown(not self.Flash:IsShown())

			self.flashTime = self.flashTime + ATTACK_BUTTON_FLASH_TIME
		end
	end

	if not WoWRetail then
		self.rangeTimer = (self.rangeTimer or 0) - elapsed

		if self.rangeTimer <= 0 then
			UpdateRange(self) -- Sezz

			self.rangeTimer = TOOLTIP_UPDATE_TIME
		end
	end
end

local gridCounter = 0
function ShowGrid()
	gridCounter = gridCounter + 1
	if gridCounter >= 1 then
		for button in next, ButtonRegistry do
			if button:IsShown() then
				button:SetAlpha(1.0)
			end
		end
	end
end

function HideGrid()
	if gridCounter > 0 then
		gridCounter = gridCounter - 1
	end
	if gridCounter == 0 then
		for button in next, ButtonRegistry do
			if button:IsShown() and not button:HasAction() and not button.config.showGrid then
				button:SetAlpha(0.0)
			end
		end
	end
end

function UpdateGrid(self)
	if self.config.showGrid then
		self:SetAlpha(1.0)
	elseif gridCounter == 0 and self:IsShown() and not self:HasAction() then
		self:SetAlpha(0.0)
	end
end

function UpdateRange(button, force, inRange, checksRange) -- Sezz: moved from OnUpdate
	local oldRange = button.outOfRange
	button.outOfRange = ((inRange == nil or checksRange == nil) and button:IsInRange() == false) or (checksRange and not inRange)

	if force or (oldRange ~= button.outOfRange) then
		if button.config.outOfRangeColoring == "button" then
			UpdateUsable(button)
		elseif button.config.outOfRangeColoring == "hotkey" and not button.config.hideElements.hotkey then
			UpdateTextElement(button, button.HotKey, button.config.text.hotkey, NumberFontNormalSmallGray:GetFont(), true)
		end

		lib.callbacks:Fire("OnUpdateRange", button)
	end
end

-----------------------------------------------------------
--- Active Aura Cooldowns for Target ~ By Simpy

do
	local current = {}
	local auraInstances = {}

	local function CheckIsMine(sourceUnit)
		return sourceUnit == 'player' or sourceUnit == 'pet' or sourceUnit == 'vehicle'
	end

	local function CheckAuraFilter(aura, filter)
		if not filter then
			return true -- already filtered by GetAuraDataBySpellName
		elseif filter == 'HELPFUL' then
			return aura.isHelpful
		elseif filter == 'HARMFUL' then
			return aura.isHarmful
		end
	end

	local function GetTargetAuraCooldown(aura)
		if not aura then return end

		local _, _, _, _, duration, expiration = UnpackAuraData(aura)
		local start = (duration and duration > 0 and duration <= TARGETAURA_DURATION) and (expiration - duration)
		return start, duration, expiration
	end

	local function CheckTargetAuraCooldown(aura, filter, buttons, previous)
		local allow = CheckAuraFilter(aura, filter)
		if not allow then return end

		local isMine = CheckIsMine(aura.sourceUnit)
		if not isMine then return end

		local start, duration = GetTargetAuraCooldown(aura)
		if not start then return end

		for _, button in next, buttons do
			button.AuraCooldown:SetCooldown(start, duration, 1)

			current[button] = true

			if previous then
				previous[button] = nil
			end
		end
	end

	local function ProcessTargetAuras(which, filter, auras)
		if not auras then return end

		for _, value in next, auras do
			if which == 'add' then
				auraInstances[value.auraInstanceID] = value

				local buttons = AuraButtons.auras[value.name]
				if buttons then
					CheckTargetAuraCooldown(value, filter, buttons)
				end
			else
				local aura
				if which == 'update' then -- update it
					aura = GetAuraDataByAuraInstanceID('target', value)
					auraInstances[value] = aura
				else
					aura = auraInstances[value] -- use cache to remove
					auraInstances[value] = nil -- clear the old one
				end

				local buttons = aura and AuraButtons.auras[aura.name]
				if buttons then
					CheckTargetAuraCooldown(aura, filter, buttons)
				end
			end
		end
	end

	function UpdateTargetAuras(event, arg1, updateInfo)
		local isFriend = UnitIsFriend('player', 'target')
		if event == 'UNIT_AURA' and updateInfo and not updateInfo.isFullUpdate then
			local filter = isFriend and 'HELPFUL' or 'HARMFUL'
			ProcessTargetAuras('add', filter, updateInfo.addedAuras)
			ProcessTargetAuras('update', filter, updateInfo.updatedAuraInstanceIDs)
			ProcessTargetAuras('remove', filter, updateInfo.removedAuraInstanceIDs)
		elseif event ~= 'SetTargetAuraCooldowns' or not arg1 then
			local previous = CopyTable(current, true) -- shallow copy

			wipe(current) -- clear the current ones
			wipe(auraInstances) -- keep this clean

			local filter = isFriend and 'PLAYER|HELPFUL' or 'PLAYER|HARMFUL'
			for spellName, buttons in next, AuraButtons.auras do
				local aura = GetAuraDataBySpellName('target', spellName, filter)
				if aura then -- collect what we can
					auraInstances[aura.auraInstanceID] = aura

					CheckTargetAuraCooldown(aura, nil, buttons, previous)
				end
			end

			for button in next, previous do
				button.AuraCooldown:Clear()
			end
		end
	end
end

function lib:SetTargetAuraDuration(value)
	TARGETAURA_DURATION = value

	UpdateTargetAuras('SetTargetAuraDuration')
end

function lib:SetTargetAuraCooldowns(enabled)
	TARGETAURA_ENABLED = enabled

	UpdateTargetAuras('SetTargetAuraCooldowns', not enabled)
end

-----------------------------------------------------------
--- KeyBound integration

function Generic:GetBindingAction()
	return self.config.keyBoundTarget or ("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton)
end

function Generic:GetHotkey()
	local name = ("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton)
	local key = GetBindingKey(self.config.keyBoundTarget or name)
	if not key and self.config.keyBoundTarget then
		key = GetBindingKey(name)
	end
	if key then
		return KeyBound and KeyBound:ToShortKey(key) or key
	end
end

local function GetKeys(binding, keys)
	keys = keys or ""
	for i = 1, select("#", GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys ~= "" then
			keys = keys .. ", "
		end
		keys = keys .. GetBindingText(hotKey)
	end
	return keys
end

function Generic:GetBindings()
	local keys

	if self.config.keyBoundTarget then
		keys = GetKeys(self.config.keyBoundTarget)
	end

	keys = GetKeys(("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton), keys)

	return keys
end

function Generic:SetKey(key)
	if self.config.keyBoundTarget then
		SetBinding(key, self.config.keyBoundTarget)
	else
		SetBindingClick(key, self:GetName(), self.config.keyBoundClickButton)
	end
	lib.callbacks:Fire("OnKeybindingChanged", self, key)
end

local function ClearBindings(binding)
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

function Generic:ClearBindings()
	if self.config.keyBoundTarget then
		ClearBindings(self.config.keyBoundTarget)
	end

	ClearBindings(("CLICK %s:%s"):format(self:GetName(), self.config.keyBoundClickButton))

	lib.callbacks:Fire("OnKeybindingChanged", self, nil)
end

-----------------------------------------------------------
--- button management

function Generic:UpdateAction(force)
	local actionType, action = self:GetAction()
	if force or actionType ~= self._state_type or action ~= self._state_action then
		-- type changed, update the metatable
		if force or self._state_type ~= actionType then
			local meta = type_meta_map[actionType] or type_meta_map.empty
			setmetatable(self, meta)
			self._state_type = actionType
		end

		self._state_action = action

		-- set action attribute for action buttons
		self.action = self._state_type == "action" and action or nil

		Update(self, 'UpdateAction')
	end
end

function Update(self, which)
	if self:HasAction() then
		ActiveButtons[self] = true
		if self._state_type == "action" then
			ActionButtons[self] = true
			NonActionButtons[self] = nil
		else
			ActionButtons[self] = nil
			NonActionButtons[self] = true
		end

		self:SetAlpha(1.0)

		UpdateButtonState(self)
		UpdateUsable(self)
		UpdateCooldown(self)
		UpdateFlash(self)
	else
		ActiveButtons[self] = nil
		ActionButtons[self] = nil
		NonActionButtons[self] = nil

		if gridCounter == 0 and not self.config.showGrid then
			self:SetAlpha(0.0)
		end

		self.cooldown:Hide()
		self:SetChecked(false)

		if self.chargeCooldown then
			EndChargeCooldown(self.chargeCooldown)
		end

		if self.LevelLinkLockIcon then
			self.LevelLinkLockIcon:SetShown(false)
		end
	end

	-- Add a green border if button is an equipped item
	if self:IsEquipped() and not self.config.hideElements.equipped then
		self.Border:SetVertexColor(0, 1.0, 0, 0.35)
		self.Border:Show()
	else
		self.Border:Hide()
	end

	-- Update Action Text
	if not self:IsConsumableOrStackable() then
		self.Name:SetText(self:GetActionText())
	else
		self.Name:SetText("")
	end

	-- Target Aura ~Simpy
	local previousSpellName = AuraButtons.buttons[self]
	if previousSpellName then
		AuraButtons.buttons[self] = nil

		local auras = AuraButtons.auras[previousSpellName]
		for i, button in next, auras do -- we need to find other buttons of this spell too
			if button == self then
				tremove(auras, i)
				break
			end
		end

		if not next(auras) then
			AuraButtons.auras[previousSpellName] = nil
		end
	end

	-- Update icon and hotkey
	local texture = self:GetTexture()
	if texture then
		self:SetScript("OnUpdate", Generic.OnUpdate)
		self.icon:SetTexture(texture)
		self.icon:Show()

		if WoWRetail then
			if not self.MasqueSkinned then
				self.SlotBackground:Hide()
				if self.config.hideElements.border then
					self.NormalTexture:SetTexture()
					self.icon:RemoveMaskTexture(self.IconMask)
					self.HighlightTexture:SetSize(52, 51)
					self.HighlightTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
					self.CheckedTexture:SetSize(52, 51)
					self.CheckedTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
					self.cooldown:ClearAllPoints()
					self.cooldown:SetAllPoints()
				else
					self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow")
					self.icon:AddMaskTexture(self.IconMask)
					self.HighlightTexture:SetSize(46, 45)
					self.HighlightTexture:SetPoint("TOPLEFT")
					self.CheckedTexture:SetSize(46, 45)
					self.CheckedTexture:SetPoint("TOPLEFT")
					self.cooldown:ClearAllPoints()
					self.cooldown:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -2)
					self.cooldown:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 3)
				end
			end
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
			if not self.LBFSkinned and not self.MasqueSkinned then
				self.NormalTexture:SetTexCoord(0, 0, 0, 0)
			end
		end
	else
		self:SetScript("OnUpdate", nil)
		self.icon:Hide()
		self.cooldown:Hide()

		if WoWRetail then
			if not self.MasqueSkinned then
				self.SlotBackground:Show()
				if self.config.hideElements.borderIfEmpty then
					self.NormalTexture:SetTexture()
				else
					self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow")
				end
			end
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot")
			if not self.LBFSkinned and not self.MasqueSkinned then
				self.NormalTexture:SetTexCoord(-0.15, 1.15, -0.15, 1.17)
			end
		end
	end

	self:UpdateLocal()

	UpdateAbilityInfo(self)

	SetupRange(self, texture) -- we can call this on retail or not, only activates events on retail ~Simpy

	UpdateRange(self, which == 'UpdateConfig') -- Sezz: update range check on state change

	UpdateCount(self)

	UpdateFlyout(self)

	UpdateOverlayGlow(self)

	UpdateNewAction(self)

	UpdateSpellHighlight(self)

	if GameTooltip_GetOwnerForbidden() == self then
		UpdateTooltip(self)
	end

	-- this could've been a spec change, need to call OnStateChanged for action buttons, if present
	local isTypeAction = self._state_type == 'action'
	if isTypeAction and not InCombatLockdown() then
		local updateReleaseCasting = which == "PLAYER_ENTERING_WORLD" and self:GetAttribute("UpdateReleaseCasting")
		if updateReleaseCasting then -- zone in dragon mount on Evokers can bug
			self.header:SetFrameRef("updateButton", self)
			self.header:Execute(([[
				local frame = self:GetFrameRef("updateButton")
				control:RunFor(frame, frame:GetAttribute("UpdateReleaseCasting"), %s, %s)
			]]):format(FormatHelper(self._state_type), FormatHelper(self._state_action)))
		end

		local onStateChanged = self:GetAttribute("OnStateChanged")
		if onStateChanged then
			self.header:SetFrameRef("updateButton", self)
			self.header:Execute(([[
				local frame = self:GetFrameRef("updateButton")
				control:RunFor(frame, frame:GetAttribute("OnStateChanged"), %s, %s, %s)
			]]):format(FormatHelper(self:GetAttribute("state")), FormatHelper(self._state_type), FormatHelper(self._state_action)))
		end
	end

	lib.callbacks:Fire("OnButtonUpdate", self, which)
end

function Generic:UpdateLocal()
-- dummy function the other button types can override for special updating
end

function UpdateButtonState(self)
	if (self:IsCurrentlyActive() or self:IsAutoRepeat()) and (not WoWRetail or not self.TargetReticleAnimFrame:IsShown()) then
		self:SetChecked(true)
	else
		self:SetChecked(false)
	end

	-- one punch button ~Simpy
	local actionID = WoWRetail and self._state_type == "action" and tonumber(self._state_action)
	if actionID and IsAssistedCombatAction(actionID) then
		UpdateAbilityInfo(self) -- lets clean that up
		UpdateCooldown(self) -- update cooldown

		local texture = self:GetTexture()
		if texture then
			self.icon:SetTexture(texture)
			self.icon:Show()
		else
			self.icon:Hide()
		end
	end

	lib.callbacks:Fire("OnButtonState", self)
end

function UpdateUsable(self, isUsable, notEnoughMana)
	-- TODO: make the colors configurable
	-- TODO: allow disabling of the whole recoloring
	if self.config.outOfRangeColoring == "button" and self.outOfRange then
		self.icon:SetVertexColor(unpack(self.config.colors.range))
	else
		if isUsable == nil or notEnoughMana == nil then
			isUsable, notEnoughMana = self:IsUsable()
		end

		if isUsable then
			self.icon:SetVertexColor(unpack(self.config.colors.usable))
		elseif notEnoughMana then
			self.icon:SetVertexColor(unpack(self.config.colors.mana))
		else
			self.icon:SetVertexColor(unpack(self.config.colors.notUsable))
		end
	end

	if WoWRetail and self._state_type == "action" then
		local isLevelLinkLocked = C_LevelLink_IsActionLocked(self._state_action)
		if not self.saturationLocked then
			self.icon:SetDesaturated(isLevelLinkLocked)
		end

		if self.LevelLinkLockIcon then
			self.LevelLinkLockIcon:SetShown(isLevelLinkLocked)
		end
	end

	lib.callbacks:Fire("OnButtonUsable", self)
end

function UpdateCount(self)
	if self.config.hideElements.count or not self:HasAction() then
		self.Count:SetText("")
		return
	end
	if self:IsConsumableOrStackable() then
		local count = self:GetCount()
		if count > (self.maxDisplayCount or 9999) then
			self.Count:SetText("*")
		else
			self.Count:SetText(count)
		end
	else
		local charges, maxCharges, _chargeStart, _chargeDuration = self:GetCharges()
		if charges and maxCharges and maxCharges > 1 then
			self.Count:SetText(charges)
		else
			self.Count:SetText("")
		end
	end
end

function EndChargeCooldown(self)
	self:Hide()
	self:SetParent(UIParent)
	self.parent.chargeCooldown = nil
	self.parent = nil
	tinsert(lib.ChargeCooldowns, self)
end

local function StartChargeCooldown(parent, chargeStart, chargeDuration, chargeModRate)
	if not parent.chargeCooldown then
		local cooldown = tremove(lib.ChargeCooldowns)
		if not cooldown then
			lib.NumChargeCooldowns = lib.NumChargeCooldowns + 1
			cooldown = CreateFrame("Cooldown", "LAB10ChargeCooldown"..lib.NumChargeCooldowns, parent, "CooldownFrameTemplate");
			cooldown:SetScript("OnCooldownDone", EndChargeCooldown)
			cooldown:SetHideCountdownNumbers(true)
			cooldown:SetDrawBling(false)
			cooldown:SetDrawSwipe(false)

			lib.callbacks:Fire("OnChargeCreated", parent, cooldown)
		end
		cooldown:SetParent(parent)
		cooldown:SetAllPoints(parent)
		cooldown:SetFrameStrata(parent:GetFrameStrata())
		cooldown:SetFrameLevel(parent:GetFrameLevel() + 1)
		cooldown:Show()

		parent.chargeCooldown = cooldown
		cooldown.parent = parent
	end

	-- set cooldown
	parent.chargeCooldown:SetCooldown(chargeStart, chargeDuration, chargeModRate)

	-- update charge cooldown skin when masque is used
	if Masque and Masque.UpdateCharge then
		Masque:UpdateCharge(parent)
	end

	if not chargeStart or chargeStart == 0 then
		EndChargeCooldown(parent.chargeCooldown)
	end
end

local function OnCooldownDone(self)
	local button = self:GetParent()

	self:SetScript("OnCooldownDone", nil)

	lib.callbacks:Fire("OnCooldownDone", button, self)
end

local function LocCooldownDone(self)
	local button = self:GetParent()

	self:SetScript("OnCooldownDone", nil)
	UpdateCooldown(button)

	lib.callbacks:Fire("OnCooldownDone", button, self)
end

function UpdateCooldownNumberHidden(self)
	local shouldBeHidden
	if self.config.cooldownCount == nil then
		shouldBeHidden = self.cooldown.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL or GetCVarBool("countdownForCooldowns") ~= true
	else
		shouldBeHidden = not self.config.cooldownCount
	end

	self.cooldown:SetHideCountdownNumbers(shouldBeHidden)
end

function UpdateCooldown(self)
	local locStart, locDuration
	local start, duration, enable, modRate, auraData
	local charges, maxCharges, chargeStart, chargeDuration, chargeModRate

	local passiveCooldownSpellID = self:GetPassiveCooldownSpellID()
	if passiveCooldownSpellID and passiveCooldownSpellID ~= 0 then
		auraData = GetPlayerAuraBySpellID(passiveCooldownSpellID)
	end

	if auraData then
		local currentTime = GetTime()
		local timeUntilExpire = auraData.expirationTime - currentTime
		local howMuchTimeHasPassed = auraData.duration - timeUntilExpire

		locStart =  currentTime - howMuchTimeHasPassed
		locDuration = auraData.expirationTime - currentTime
		start = currentTime - howMuchTimeHasPassed
		duration =  auraData.duration
		modRate = auraData.timeMod
		charges = auraData.charges
		maxCharges = auraData.maxCharges
		chargeStart = currentTime * 0.001
		chargeDuration = duration * 0.001
		chargeModRate = modRate
		enable = 1
	else
		locStart, locDuration = self:GetLossOfControlCooldown()
		start, duration, enable, modRate = self:GetCooldown()
		charges, maxCharges, chargeStart, chargeDuration, chargeModRate = self:GetCharges()
	end

	self.cooldown:SetDrawBling(self.config.useDrawBling and (self:GetEffectiveAlpha() > 0.5))

	local hasLocCooldown = locStart and locDuration and locStart > 0 and locDuration > 0
	local hasCooldown = (enable and enable ~= 0) and (start and duration and start > 0 and duration > 0)
	if hasLocCooldown and (not hasCooldown or ((locStart + locDuration) > (start + duration))) then
		if self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_LOSS_OF_CONTROL then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge-LoC")
			self.cooldown:SetSwipeColor(0.2, 0, 0)
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_LOSS_OF_CONTROL
			UpdateCooldownNumberHidden(self)
		end

		self.cooldown:SetScript("OnCooldownDone", LocCooldownDone)
		self.cooldown:SetCooldown(locStart, locDuration, modRate)

		if self.chargeCooldown then
			EndChargeCooldown(self.chargeCooldown)
		end
	else
		if self.cooldown.currentCooldownType ~= COOLDOWN_TYPE_NORMAL then
			self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			self.cooldown:SetSwipeColor(0, 0, 0)
			self.cooldown.currentCooldownType = COOLDOWN_TYPE_NORMAL
			UpdateCooldownNumberHidden(self)
		end

		if hasCooldown then
			self.cooldown:SetScript("OnCooldownDone", OnCooldownDone)
			self.cooldown:SetCooldown(start, duration, modRate)
		else
			self.cooldown:Clear()
		end

		if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
			StartChargeCooldown(self, chargeStart, chargeDuration, chargeModRate)

			self.chargeCooldown:SetDrawSwipe(self.config.useDrawSwipeOnCharges)
		elseif self.chargeCooldown then
			EndChargeCooldown(self.chargeCooldown)
		end
	end

	lib.callbacks:Fire("OnCooldownUpdate", self, start, duration, modRate)
end

function UpdateRangeTimer(self)
	self.rangeTimer = -1
end

function StartFlash(self)
	local prevFlash = self.flashing

	self.flashing = true

	if prevFlash ~= self.flashing then
		UpdateButtonState(self)
	end
end

function StopFlash(self)
	local prevFlash = self.flashing

	self.flashing = false
	self.flashTime = nil

	if self.Flash:IsShown() then
		self.Flash:Hide()
	end

	if prevFlash ~= self.flashing then
		UpdateButtonState(self)
	end
end

function UpdateFlash(self)
	if (self:IsAttack() and self:IsCurrentlyActive()) or self:IsAutoRepeat() then
		StartFlash(self)
	else
		StopFlash(self)
	end
end

function UpdateTooltip(self)
	if GameTooltip:IsForbidden() then return end

	if (GetCVar("UberTooltips") == "1") then
		GameTooltip:ClearAllPoints();
		_G.GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	if self:SetTooltip() then
		self.UpdateTooltip = UpdateTooltip
	else
		self.UpdateTooltip = nil
	end
end

function UpdateHotkeys(self)
	local key = self:GetHotkey()
	if not key or key == "" or self.config.hideElements.hotkey then
		self.HotKey:SetText(RANGE_INDICATOR)
		self.HotKey:Hide()
	else
		self.HotKey:SetText(key)
		self.HotKey:Show()
	end

	if self.postKeybind then
		self.postKeybind(nil, self)
	end
end

function ShowOverlayGlow(self)
	if LCG and self.config.handleOverlay then
		LCG.ShowOverlayGlow(self)
	end
end

function HideOverlayGlow(self)
	if LCG then
		LCG.HideOverlayGlow(self)
	end
end

function UpdateOverlayGlow(self)
	local spellId = self.config.handleOverlay and self:GetSpellId()
	if lib.activeAssist[spellId] then
		return
	end

	if spellId and IsSpellOverlayed(spellId) then
		ShowOverlayGlow(self)
	else
		HideOverlayGlow(self)
	end
end

function ClearNewActionHighlight(action, preventIdenticalActionsFromClearing, value)
	lib.ACTION_HIGHLIGHT_MARKS[action] = value

	for button in next, ButtonRegistry do
		if button._state_type == "action" and action == tonumber(button._state_action) then
			UpdateNewAction(button)
		end
	end

	if preventIdenticalActionsFromClearing then
		return
	end

	-- iterate through actions and unmark all that are the same type
	local unmarkedType, unmarkedID = GetActionInfo(action)
	for actionKey, markValue in pairs(lib.ACTION_HIGHLIGHT_MARKS) do
		if markValue then
			local actionType, actionID = GetActionInfo(actionKey)
			if actionType == unmarkedType and actionID == unmarkedID then
				ClearNewActionHighlight(actionKey, true, value)
			end
		end
	end
end

hooksecurefunc("MarkNewActionHighlight", function(action)
	lib.ACTION_HIGHLIGHT_MARKS[action] = true
	for button in next, ButtonRegistry do
		if button._state_type == "action" and action == tonumber(button._state_action) then
			UpdateNewAction(button)
		end
	end
end)

hooksecurefunc("ClearNewActionHighlight", function(action, preventIdenticalActionsFromClearing)
	ClearNewActionHighlight(action, preventIdenticalActionsFromClearing, nil)
end)

function UpdateNewAction(self)
	-- special handling for "New Action" markers
	if self.NewActionTexture then
		if self._state_type == "action" and lib.ACTION_HIGHLIGHT_MARKS[self._state_action] then
			self.NewActionTexture:Show()
		else
			self.NewActionTexture:Hide()
		end
	end
end

hooksecurefunc("UpdateOnBarHighlightMarksBySpell", function(spellID)
	lib.ON_BAR_HIGHLIGHT_MARK_TYPE = "spell"
	lib.ON_BAR_HIGHLIGHT_MARK_ID = tonumber(spellID)
end)

hooksecurefunc("UpdateOnBarHighlightMarksByFlyout", function(flyoutID)
	lib.ON_BAR_HIGHLIGHT_MARK_TYPE = "flyout"
	lib.ON_BAR_HIGHLIGHT_MARK_ID = tonumber(flyoutID)
end)

hooksecurefunc("ClearOnBarHighlightMarks", function()
	lib.ON_BAR_HIGHLIGHT_MARK_TYPE = nil
end)

if _G.ActionBarController_UpdateAllSpellHighlights then
	hooksecurefunc("ActionBarController_UpdateAllSpellHighlights", function()
		for button in next, ButtonRegistry do
			UpdateSpellHighlight(button)
		end
	end)
end

function UpdateSpellHighlight(self)
	local shown = false

	local highlightType, id = lib.ON_BAR_HIGHLIGHT_MARK_TYPE, lib.ON_BAR_HIGHLIGHT_MARK_ID
	if highlightType == "spell" and self:GetSpellId() == id then
		shown = true
	elseif highlightType == "flyout" and self._state_type == "action" then
		local actionType, actionId = GetActionInfo(self._state_action)
		if actionType == "flyout" and actionId == id then
			shown = true
		end
	end

	if shown then
		self.SpellHighlightTexture:Show()
		self.SpellHighlightAnim:Play()
	else
		self.SpellHighlightTexture:Hide()
		self.SpellHighlightAnim:Stop()
	end
end

-- Hook UpdateFlyout so we can use the blizzy templates
if _G.ActionButton_UpdateFlyout then -- on Classic only?
	hooksecurefunc("ActionButton_UpdateFlyout", function(self)
		if ButtonRegistry[self] then
			UpdateFlyout(self)
		end
	end)

	function UpdateFlyout(self)
		local hideArrow = true

		-- disabled FlyoutBorder/BorderShadow, those are not handled by LBF and look terrible
		if self.FlyoutBorder then
			self.FlyoutBorder:Hide()
		end
		if self.FlyoutBorderShadow then
			self.FlyoutBorderShadow:Hide()
		end

		if self._state_type == "action" then
			-- based on ActionButton_UpdateFlyout in ActionButton.lua
			local actionType = GetActionInfo(self._state_action)
			if actionType == "flyout" then
				local isFlyoutShown = SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self
				local arrowDistance = isFlyoutShown and 1 or 4

				-- Update arrow
				self.FlyoutArrow:Show()
				self.FlyoutArrow:ClearAllPoints()
				local direction = self:GetAttribute("flyoutDirection")
				if direction == "LEFT" then
					self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 90 or 270)
				elseif direction == "RIGHT" then
					self.FlyoutArrow:SetPoint("RIGHT", self, "RIGHT", arrowDistance, 0)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 270 or 90)
				elseif direction == "DOWN" then
					self.FlyoutArrow:SetPoint("BOTTOM", self, "BOTTOM", 0, -arrowDistance)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 0 or 180)
				else
					self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance)
					SetClampedTextureRotation(self.FlyoutArrow, isFlyoutShown and 180 or 0)
				end

				hideArrow = false
			end
		end

		if hideArrow then
			self.FlyoutArrow:Hide()
		end

		lib.callbacks:Fire("OnFlyoutUpdate", self)
	end
elseif FlyoutButtonMixin and UseCustomFlyout then -- on Retail and Classic
	function Generic:GetPopupDirection()
		return self:GetAttribute("flyoutDirection") or "UP"
	end

	function Generic:IsPopupOpen()
		return (lib.flyoutHandler and lib.flyoutHandler:IsShown() and lib.flyoutHandler:GetParent() == self)
	end

	function UpdateFlyout(self)
		self.BorderShadow:Hide()
		self.Arrow:Hide()

		if self._state_type == "action" then
			-- based on ActionButton_UpdateFlyout in ActionButton.lua
			local actionType = GetActionInfo(self._state_action)
			if actionType == "flyout" then
				self.Arrow:Show()
				self:UpdateArrowTexture()
				self:UpdateArrowRotation()
				self:UpdateArrowPosition()
			end
		end

		lib.callbacks:Fire("OnFlyoutUpdate", self)
	end
else -- for mists right now
	function UpdateFlyout(self, isButtonDownOverride)
		local hideArrow = true

		if self.FlyoutBorderShadow then
			self.FlyoutBorderShadow:Hide()
		end

		if self._state_type == "action" then
			-- based on ActionButton_UpdateFlyout in ActionButton.lua
			local actionType = GetActionInfo(self._state_action)
			if actionType == "flyout" then
				local isMouseOverButton = self:IsMouseOver()

				local isButtonDown
				if (isButtonDownOverride ~= nil) then
					isButtonDown = isButtonDownOverride
				else
					isButtonDown = self:GetButtonState() == "PUSHED"
				end

				local flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowNormal

				if (isButtonDown) then
					flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowPushed

					self.FlyoutArrowContainer.FlyoutArrowNormal:Hide()
					self.FlyoutArrowContainer.FlyoutArrowHighlight:Hide()
				elseif (isMouseOverButton) then
					flyoutArrowTexture = self.FlyoutArrowContainer.FlyoutArrowHighlight

					self.FlyoutArrowContainer.FlyoutArrowNormal:Hide()
					self.FlyoutArrowContainer.FlyoutArrowPushed:Hide()
				else
					self.FlyoutArrowContainer.FlyoutArrowHighlight:Hide()
					self.FlyoutArrowContainer.FlyoutArrowPushed:Hide()
				end

				local isFlyoutShown = (SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or (lib.flyoutHandler and lib.flyoutHandler:IsShown() and lib.flyoutHandler:GetParent() == self)
				local arrowDistance = isFlyoutShown and 1 or 4

				-- Update arrow
				self.FlyoutArrowContainer:Show()
				flyoutArrowTexture:Show()
				flyoutArrowTexture:ClearAllPoints()

				local direction = self:GetAttribute("flyoutDirection")
				if direction == "LEFT" then
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 90 or 270)
					flyoutArrowTexture:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
				elseif direction == "RIGHT" then
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 270 or 90)
					flyoutArrowTexture:SetPoint("RIGHT", self, "RIGHT", arrowDistance, 0)
				elseif direction == "DOWN" then
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 0 or 180)
					flyoutArrowTexture:SetPoint("BOTTOM", self, "BOTTOM", 0, -arrowDistance)
				else
					SetClampedTextureRotation(flyoutArrowTexture, isFlyoutShown and 180 or 0)
					flyoutArrowTexture:SetPoint("TOP", self, "TOP", 0, arrowDistance)
				end

				hideArrow = false
			end
		end

		if hideArrow then
			self.FlyoutArrowContainer:Hide()
		end

		lib.callbacks:Fire("OnFlyoutUpdate", self)
	end
end
Generic.UpdateFlyout = UpdateFlyout

-----------------------------------------------------------
--- WoW API mapping
--- Generic Button
Generic.HasAction               = function(self) return nil end
Generic.GetActionText           = function(self) return "" end
Generic.GetTexture              = function(self) return nil end
Generic.GetCharges              = function(self) return nil end
Generic.GetCount                = function(self) return 0 end
Generic.GetCooldown             = function(self) return nil end
Generic.IsAttack                = function(self) return nil end
Generic.IsEquipped              = function(self) return nil end
Generic.IsCurrentlyActive       = function(self) return nil end
Generic.IsAutoRepeat            = function(self) return nil end
Generic.IsUsable                = function(self) return nil end
Generic.IsConsumableOrStackable = function(self) return nil end
Generic.IsUnitInRange           = function(self, unit) return nil end
Generic.IsInRange               = function(self)
	local unit = self:GetAttribute("unit")
	if unit == "player" then
		unit = nil
	end

	local val = self:IsUnitInRange(unit)
	-- map 1/0 to true false, since the return values are inconsistent between actions and spells
	if val == 1 then val = true elseif val == 0 then val = false end
	return val
end
Generic.SetTooltip              = function(self) return nil end
Generic.GetSpellId              = function(self) return nil end
Generic.GetLossOfControlCooldown = function(self) return 0, 0 end
Generic.GetPassiveCooldownSpellID = function(self) return nil end

-----------------------------------------------------------
--- Action Button
Action.HasAction               = function(self) return HasAction(self._state_action) end
Action.GetActionText           = function(self) return GetActionText(self._state_action) end
Action.GetTexture              = function(self) return GetActionTexture(self._state_action) end
Action.GetCharges              = function(self) return GetActionCharges(self._state_action) end
Action.GetCount                = function(self) return GetActionCount(self._state_action) end
Action.GetCooldown             = function(self) return GetActionCooldown(self._state_action) end
Action.IsAttack                = function(self) return IsAttackAction(self._state_action) end
Action.IsEquipped              = function(self) return IsEquippedAction(self._state_action) end
Action.IsCurrentlyActive       = function(self) return IsCurrentAction(self._state_action) end
Action.IsAutoRepeat            = function(self) return IsAutoRepeatAction(self._state_action) end
Action.IsUsable                = function(self) return IsUsableAction(self._state_action) end
Action.IsConsumableOrStackable = function(self) return IsConsumableAction(self._state_action) or IsStackableAction(self._state_action) or (not IsItemAction(self._state_action) and GetActionCount(self._state_action) > 0) end
Action.IsUnitInRange           = function(self, unit) return IsActionInRange(self._state_action, unit) end
Action.SetTooltip              = function(self) return GameTooltip:SetAction(self._state_action) end
Action.GetSpellId              = function(self)
	if self._state_type == "action" then
		local actionType, id, subType = GetActionInfo(self._state_action)
		if actionType == "spell" then
			return id
		elseif actionType == "macro" then
			if subType == "spell" then
				return id
			else
				return (GetMacroSpell(id))
			end
		end
	end
end

Action.GetLossOfControlCooldown = function(self) return GetActionLossOfControlCooldown(self._state_action) end
Action.GetPassiveCooldownSpellID = function(self)
	local _actionType, actionID = GetActionInfo(self._state_action)
	local onEquipPassiveSpellID
	if actionID and GetItemActionOnEquipSpellID then
		onEquipPassiveSpellID = GetItemActionOnEquipSpellID(self._state_action)
	end
	if onEquipPassiveSpellID then
		return GetCooldownAuraBySpellID(onEquipPassiveSpellID)
	else
		local spellID = self:GetSpellId()
		if spellID then
			return GetCooldownAuraBySpellID(spellID)
		end
	end
end

-- Classic overrides for item count breakage
if WoWClassic then
	-- if the library is present, simply use it to override action counts
	local LibClassicSpellActionCount = LibStub("LibClassicSpellActionCount-1.0", true)
	if LibClassicSpellActionCount then
		Action.GetCount = function(self)
			return LibClassicSpellActionCount:GetActionCount(self._state_action)
		end
	else -- if we don't have the library, only show count for items, like the default UI
		Action.IsConsumableOrStackable = function(self)
			return IsConsumableAction(self._state_action) or IsStackableAction(self._state_action) or (not IsItemAction(self._state_action) and GetActionCount(self._state_action) > 0)
		end
	end
end

if not WoWRetail then
	-- disable loss of control cooldown on classic
	Action.GetLossOfControlCooldown = function(self) return 0,0 end
end

-----------------------------------------------------------
--- Spell Button
Spell.HasAction               = function(self) return true end
Spell.GetActionText           = function(self) return "" end
Spell.GetTexture              = function(self) return C_Spell.GetSpellTexture(self._state_action) end
Spell.GetCharges              = function(self) return GetSpellCharges(self._state_action) end
Spell.GetCount                = function(self) return C_Spell.GetSpellCastCount(self._state_action) end
Spell.GetCooldown             = function(self) return GetSpellCooldown(self._state_action) end
Spell.IsAttack                = function(self) return C_Spell.IsAutoAttackSpell(self._state_action) or nil end
Spell.IsEquipped              = function(self) return nil end
Spell.IsCurrentlyActive       = function(self) return C_Spell.IsCurrentSpell(self._state_action) end
Spell.IsAutoRepeat            = function(self) return C_Spell.IsAutoRepeatSpell(self._state_action) or nil end
Spell.IsUsable                = function(self) return C_Spell.IsSpellUsable(self._state_action) end
Spell.IsConsumableOrStackable = function(self) return IsConsumableSpell(self._state_action) end
Spell.IsUnitInRange           = function(self, unit) return C_Spell.IsSpellInRange(self._state_action, unit) or nil end
Spell.SetTooltip              = function(self) return GameTooltip:SetSpellByID(self._state_action) end
Spell.GetSpellId              = function(self) return self._state_action end
Spell.GetLossOfControlCooldown = function(self) return GetSpellLossOfControlCooldown(self._state_action) end
Spell.GetPassiveCooldownSpellID = function(self)
	if self._state_action then
		return GetCooldownAuraBySpellID(self._state_action)
	end
end

-----------------------------------------------------------
--- Item Button
local function GetItemId(input)
	return input:match("^item:(%d+)")
end

Item.HasAction               = function(self) return true end
Item.GetActionText           = function(self) return "" end
Item.GetTexture              = function(self) return C_Item.GetItemIconByID(self._state_action) end
Item.GetCharges              = function(self) return nil end
Item.GetCount                = function(self) return C_Item.GetItemCount(self._state_action, nil, true) end
Item.GetCooldown             = function(self) return C_Container_GetItemCooldown(GetItemId(self._state_action)) end
Item.IsAttack                = function(self) return nil end
Item.IsEquipped              = function(self) return C_Item.IsEquippedItem(self._state_action) end
Item.IsCurrentlyActive       = function(self) return C_Item.IsCurrentItem(self._state_action) end
Item.IsAutoRepeat            = function(self) return nil end
Item.IsUsable                = function(self) return C_Item.IsUsableItem(self._state_action) end
Item.IsConsumableOrStackable = function(self) return C_Item.IsConsumableItem(self._state_action) end
--Item.IsUnitInRange           = function(self, unit) return IsItemInRange(self._state_action, unit) end
Item.SetTooltip              = function(self) return GameTooltip:SetHyperlink(self._state_action) end
Item.GetSpellId              = function(self) return nil end
Item.GetPassiveCooldownSpellID = function(self) return nil end

-----------------------------------------------------------
--- Macro Button
-- TODO: map results of GetMacroSpell/GetMacroItem to proper results
Macro.HasAction               = function(self) return true end
Macro.GetActionText           = function(self) return (GetMacroInfo(self._state_action)) end
Macro.GetTexture              = function(self) return (select(2, GetMacroInfo(self._state_action))) end
Macro.GetCharges              = function(self) return nil end
Macro.GetCount                = function(self) return 0 end
Macro.GetCooldown             = function(self) return nil end
Macro.IsAttack                = function(self) return nil end
Macro.IsEquipped              = function(self) return nil end
Macro.IsCurrentlyActive       = function(self) return nil end
Macro.IsAutoRepeat            = function(self) return nil end
Macro.IsUsable                = function(self) return nil end
Macro.IsConsumableOrStackable = function(self) return nil end
Macro.IsUnitInRange           = function(self, unit) return nil end
Macro.SetTooltip              = function(self) return nil end
Macro.GetSpellId              = function(self) return nil end
Macro.GetPassiveCooldownSpellID = function(self) return nil end

-----------------------------------------------------------
--- Toy Button
Toy.HasAction               = function(self) return true end
Toy.GetActionText           = function(self) return "" end
Toy.GetTexture              = function(self) return select(3, C_ToyBox_GetToyInfo(self._state_action)) end
Toy.GetCharges              = function(self) return nil end
Toy.GetCount                = function(self) return 0 end
Toy.GetCooldown             = function(self) return GetItemCooldown(self._state_action) end
Toy.IsAttack                = function(self) return nil end
Toy.IsEquipped              = function(self) return nil end
Toy.IsCurrentlyActive       = function(self) return nil end
Toy.IsAutoRepeat            = function(self) return nil end
Toy.IsUsable                = function(self) return nil end
Toy.IsConsumableOrStackable = function(self) return nil end
Toy.IsUnitInRange           = function(self, unit) return nil end
Toy.SetTooltip              = function(self) return GameTooltip:SetToyByItemID(self._state_action) end
Toy.GetSpellId              = function(self) return nil end

-----------------------------------------------------------
--- Custom Button
Custom.HasAction               = function(self) return true end
Custom.GetActionText           = function(self) return "" end
Custom.GetTexture              = function(self) return self._state_action.texture end
Custom.GetCharges              = function(self) return nil end
Custom.GetCount                = function(self) return 0 end
Custom.GetCooldown             = function(self) return nil end
Custom.IsAttack                = function(self) return nil end
Custom.IsEquipped              = function(self) return nil end
Custom.IsCurrentlyActive       = function(self) return nil end
Custom.IsAutoRepeat            = function(self) return nil end
Custom.IsUsable                = function(self) return true end
Custom.IsConsumableOrStackable = function(self) return nil end
Custom.IsUnitInRange           = function(self, unit) return nil end
Custom.SetTooltip              = function(self) return GameTooltip:SetText(self._state_action.tooltip) end
Custom.GetSpellId              = function(self) return nil end
Custom.RunCustom               = function(self, unit, button) return self._state_action.func(self, unit, button) end
Custom.GetPassiveCooldownSpellID = function(self) return nil end

--- WoW Classic overrides
if DisableOverlayGlow then
	UpdateOverlayGlow = function() end
end

-----------------------------------------------------------
--- Update old Buttons
if oldversion and next(lib.buttonRegistry) then
	InitializeEventHandler()
	for button in next, lib.buttonRegistry do
		-- this refreshes the metatable on the button
		Generic.UpdateAction(button, true)
		SetupSecureSnippets(button)
		if oldversion < 12 then
			WrapOnClick(button)
		end
		if oldversion < 23 then
			if button.overlay then
				button.overlay:Hide()

				if ActionButtonSpellAlertManager then
					ActionButtonSpellAlertManager:HideAlert(button)
				else
					ActionButton_HideOverlayGlow(button)
				end

				button.overlay = nil
				UpdateOverlayGlow(button)
			end
		end
	end
end

if oldversion and lib.flyoutHandler then
	UpdateFlyoutHandlerScripts()
end
