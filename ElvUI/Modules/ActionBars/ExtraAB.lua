local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local pairs = pairs
local unpack = unpack
local tinsert = tinsert
local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local ActionButton_UpdateCooldown = ActionButton_UpdateCooldown

local ExtraActionBarHolder, ZoneAbilityHolder
local ExtraButtons = {}

function AB:ExtraButtons_BossStyle(frame)
	local button = frame.button
	if button and not button.IsSkinned then
		button.pushed = true
		button.checked = true

		AB:StyleButton(button, true) -- registers cooldown too
		ActionButton_UpdateCooldown(button) -- the cooldown is already fired sometimes?

		button.icon:SetDrawLayer('ARTWORK')
		button:SetTemplate()

		button.holder = ExtraActionBarHolder
		button:HookScript('OnEnter', AB.ExtraButtons_OnEnter)
		button:HookScript('OnLeave', AB.ExtraButtons_OnLeave)

		local tex = button:CreateTexture(nil, 'OVERLAY')
		tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		tex:SetInside()
		button:SetCheckedTexture(tex)

		button.HotKey:SetText(GetBindingKey(button:GetName()))
		AB:FixKeybindText(button)

		AB:ExtraButtons_BossAlpha(button)

		tinsert(ExtraButtons, button)

		button.IsSkinned = true
	end
end

function AB:ExtraButtons_ZoneStyle()
	local zoneAlpha = AB:ExtraButtons_ZoneAlpha()
	for spellButton in self.SpellButtonContainer:EnumerateActive() do
		if spellButton then
			spellButton:SetAlpha(zoneAlpha)

			if not spellButton.IsSkinned then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				spellButton:StyleButton(nil, true)
				spellButton:SetTemplate()

				spellButton.Icon:SetDrawLayer('ARTWORK')
				spellButton.Icon:SetTexCoord(unpack(E.TexCoords))
				spellButton.Icon:SetInside()

				spellButton.holder = ZoneAbilityHolder
				spellButton:HookScript('OnEnter', AB.ExtraButtons_OnEnter)
				spellButton:HookScript('OnLeave', AB.ExtraButtons_OnLeave)

				if spellButton.Cooldown then
					spellButton.Cooldown.CooldownOverride = 'actionbar'
					E:RegisterCooldown(spellButton.Cooldown)
					spellButton.Cooldown:SetInside(spellButton)
				end

				spellButton.IsSkinned = true
			end
		end
	end
end

function AB:ExtraButtons_BossAlpha(button)
	local bossAlpha = E.db.actionbar.extraActionButton.alpha
	button:SetAlpha(bossAlpha)

	if button.style then
		button.style:SetAlpha(not E.db.actionbar.extraActionButton.clean and bossAlpha or 0)
	end
end

function AB:ExtraButtons_ZoneAlpha()
	local zoneAlpha = E.db.actionbar.zoneActionButton.alpha
	_G.ZoneAbilityFrame.Style:SetAlpha(not E.db.actionbar.zoneActionButton.clean and zoneAlpha or 0)

	return zoneAlpha
end

function AB:ExtraButtons_OnEnter()
	if self.holder and self.holder:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeIn(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1)
	end

	if self.buttonType == 'EXTRAACTIONBUTTON' then
		AB:BindUpdate(self)
	end
end

function AB:ExtraButtons_OnLeave()
	if self.holder and self.holder:GetParent() == AB.fadeParent and not AB.fadeParent.mouseLock then
		E:UIFrameFadeOut(AB.fadeParent, 0.2, AB.fadeParent:GetAlpha(), 1 - AB.db.globalFadeAlpha)
	end
end

function AB:ExtraButtons_GlobalFade()
	ExtraActionBarHolder:SetParent(E.db.actionbar.extraActionButton.inheritGlobalFade and AB.fadeParent or E.UIParent)
	ZoneAbilityHolder:SetParent(E.db.actionbar.zoneActionButton.inheritGlobalFade and AB.fadeParent or E.UIParent)
end

function AB:ExtraButtons_UpdateAlpha()
	if not E.private.actionbar.enable then return end

	for _, button in pairs(ExtraButtons) do
		AB:ExtraButtons_BossAlpha(button)
	end

	local zoneAlpha = AB:ExtraButtons_ZoneAlpha()
	for button in _G.ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
		button:SetAlpha(zoneAlpha)
	end
end

function AB:ExtraButtons_UpdateScale()
	if not E.private.actionbar.enable then return end

	AB:ExtraButtons_ZoneScale()

	local scale = E.db.actionbar.extraActionButton.scale
	_G.ExtraActionBarFrame:SetScale(scale)

	local width, height = _G.ExtraActionBarFrame.button:GetSize()
	ExtraActionBarHolder:SetSize(width * scale, height * scale)
end

function AB:ExtraButtons_ZoneScale()
	if not E.private.actionbar.enable then return end

	local scale = E.db.actionbar.zoneActionButton.scale
	_G.ZoneAbilityFrame.Style:SetScale(scale)
	_G.ZoneAbilityFrame.SpellButtonContainer:SetScale(scale)

	local width, height = _G.ZoneAbilityFrame.SpellButtonContainer:GetSize()
	ZoneAbilityHolder:SetSize(width * scale, height * scale)
end

function AB:ExtraButtons_Reparent()
	if InCombatLockdown() then
		AB.NeedsReparentExtraButtons = true
		AB:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	_G.ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	_G.ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
end

function AB:SetupExtraButton()
	local ExtraAbilityContainer = _G.ExtraAbilityContainer
	local ExtraActionBarFrame = _G.ExtraActionBarFrame
	local ZoneAbilityFrame = _G.ZoneAbilityFrame

	ExtraActionBarHolder = CreateFrame('Frame', nil, E.UIParent)
	ExtraActionBarHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', -150, 300)

	ZoneAbilityHolder = CreateFrame('Frame', nil, E.UIParent)
	ZoneAbilityHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 150, 300)

	ZoneAbilityFrame.SpellButtonContainer.holder = ZoneAbilityHolder
	ZoneAbilityFrame.SpellButtonContainer:HookScript('OnEnter', AB.ExtraButtons_OnEnter)
	ZoneAbilityFrame.SpellButtonContainer:HookScript('OnLeave', AB.ExtraButtons_OnLeave)

	-- try to shutdown the container movement and taints
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraAbilityContainer = nil
	ExtraAbilityContainer.SetSize = E.noop

	AB:ExtraButtons_Reparent()

	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetAllPoints()
	ZoneAbilityFrame.ignoreInLayout = true

	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetAllPoints()
	ExtraActionBarFrame.ignoreInLayout = true

	hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, 'SetSize', AB.ExtraButtons_ZoneScale)
	hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', AB.ExtraButtons_ZoneStyle)
	hooksecurefunc(ExtraAbilityContainer, 'AddFrame', AB.ExtraButtons_BossStyle)

	hooksecurefunc(ZoneAbilityFrame, 'SetParent', function(_, parent)
		if parent ~= ZoneAbilityHolder and not AB.NeedsReparentExtraButtons then
			AB:ExtraButtons_Reparent()
		end
	end)
	hooksecurefunc(ExtraActionBarFrame, 'SetParent', function(_, parent)
		if parent ~= ExtraActionBarHolder and not AB.NeedsReparentExtraButtons then
			AB:ExtraButtons_Reparent()
		end
	end)

	AB:UpdateExtraButtons()

	E:CreateMover(ExtraActionBarHolder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,extraActionButton')
	E:CreateMover(ZoneAbilityHolder, 'ZoneAbility', L["Zone Ability"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,extraActionButton')

	-- Spawn the mover before its available.
	ZoneAbilityHolder:Size(52 * E.db.actionbar.zoneActionButton.scale)
end

function AB:UpdateExtraButtons()
	AB:ExtraButtons_UpdateAlpha()
	AB:ExtraButtons_UpdateScale()
	AB:ExtraButtons_GlobalFade()
end

function AB:UpdateExtraBindings()
	_G.ExtraActionBarFrame.db = E.db.actionbar.extraActionButton

	for _, button in pairs(ExtraButtons) do
		button.HotKey:SetText(GetBindingKey(button:GetName()))
		AB:FixKeybindText(button)
	end
end
