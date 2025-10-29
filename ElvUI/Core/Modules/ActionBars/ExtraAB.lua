local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local _G = _G
local pairs = pairs
local tinsert = tinsert

local CreateFrame = CreateFrame
local GetBindingKey = GetBindingKey
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

local ActionButton_UpdateCooldown = ActionButton_UpdateCooldown

local extraBtns, extraHooked, ExtraActionBarHolder, ZoneAbilityHolder = {}, {}

function AB:ExtraButtons_AddFrame(frame)
	AB:ExtraButtons_BossStyle(frame.button)
end

function AB:ExtraButtons_BossStyle(button)
	if not button or button.IsSkinned then return end

	AB:StyleButton(button, true) -- registers cooldown too

	-- the cooldown is already fired sometimes?
	if ActionButton_UpdateCooldown then
		ActionButton_UpdateCooldown(button)
	end

	button.icon:SetDrawLayer('ARTWORK', -1)
	button:SetTemplate()

	button.holder = ExtraActionBarHolder
	button:HookScript('OnEnter', AB.ExtraButtons_OnEnter)
	button:HookScript('OnLeave', AB.ExtraButtons_OnLeave)

	button.HotKey:SetText(GetBindingKey(button.commandName))

	AB:FixKeybindText(button)
	AB:FixKeybindColor(button)

	AB:ExtraButtons_BossAlpha(button)

	tinsert(extraBtns, button)

	button.IsSkinned = true
end

function AB:ExtraButtons_ZoneStyle()
	local zoneAlpha = AB:ExtraButtons_ZoneAlpha()
	for spellButton in self.SpellButtonContainer:EnumerateActive() do
		if spellButton then
			spellButton:SetAlpha(zoneAlpha)

			if not spellButton.IsSkinned then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:StyleButton()
				spellButton:SetTemplate()

				spellButton.Icon:SetDrawLayer('ARTWORK', -1)
				spellButton.Icon:SetTexCoords()
				spellButton.Icon:SetInside()

				spellButton.holder = ZoneAbilityHolder
				spellButton:HookScript('OnEnter', AB.ExtraButtons_OnEnter)
				spellButton:HookScript('OnLeave', AB.ExtraButtons_OnLeave)

				if spellButton.Cooldown then
					E:RegisterCooldown(spellButton.Cooldown, 'actionbar')
					spellButton.Cooldown:SetInside(spellButton)
				end

				spellButton.IsSkinned = true
			end
		end
	end
end

function AB:ExtraButtons_BossAlpha(button)
	local bossAlpha = E.db.actionbar.extraActionButton.alpha
	button:SetAlpha(bossAlpha or 1)

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
	if ExtraActionBarHolder then
		ExtraActionBarHolder:SetParent(E.db.actionbar.extraActionButton.inheritGlobalFade and AB.fadeParent or E.UIParent)
	end

	if ZoneAbilityHolder then
		ZoneAbilityHolder:SetParent(E.db.actionbar.zoneActionButton.inheritGlobalFade and AB.fadeParent or E.UIParent)
	end
end

function AB:ExtraButtons_UpdateAlpha()
	if not E.private.actionbar.enable then return end

	for _, button in pairs(extraBtns) do
		AB:ExtraButtons_BossAlpha(button)
	end

	if _G.ZoneAbilityFrame then
		local zoneAlpha = AB:ExtraButtons_ZoneAlpha()
		for button in _G.ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
			button:SetAlpha(zoneAlpha)
		end
	end
end

function AB:ExtraButtons_UpdateScale()
	if not E.private.actionbar.enable then return end

	if not E.Retail and InCombatLockdown() then
		AB.NeedsExtraButtonsRescale = true

		AB:RegisterEvent('PLAYER_REGEN_ENABLED')

		return
	end

	if _G.ZoneAbilityFrame then
		AB:ExtraButtons_ZoneScale()
	end

	local ExtraActionBarFrame = _G.ExtraActionBarFrame
	if ExtraActionBarFrame then
		local scale = E.db.actionbar.extraActionButton.scale
		ExtraActionBarFrame:SetScale(scale * E.uiscale)
		ExtraActionBarFrame:SetIgnoreParentScale(true)

		local width, height = ExtraActionBarFrame.button:GetSize()
		ExtraActionBarHolder:SetSize(width * scale, height * scale)
	end
end

function AB:ExtraButtons_ZoneScale()
	if not E.private.actionbar.enable then return end

	if _G.ZoneAbilityFrame then
		local scale = E.db.actionbar.zoneActionButton.scale
		_G.ZoneAbilityFrame.Style:SetScale(scale)
		_G.ZoneAbilityFrame.SpellButtonContainer:SetScale(scale)

		local width, height = _G.ZoneAbilityFrame.SpellButtonContainer:GetSize()
		ZoneAbilityHolder:SetSize(width * scale, height * scale)
	end
end

function AB:ExtraButtons_BossParent(parent)
	if parent ~= ExtraActionBarHolder and not AB.NeedsExtraButtonsReparent then
		AB:ExtraButtons_Reparent()
	end
end

function AB:ExtraButtons_ZoneParent(parent)
	if parent ~= ZoneAbilityHolder and not AB.NeedsExtraButtonsReparent then
		AB:ExtraButtons_Reparent()
	end
end

function AB:ExtraButtons_Reparent()
	if InCombatLockdown() then
		AB.NeedsExtraButtonsReparent = true

		AB:RegisterEvent('PLAYER_REGEN_ENABLED')

		return
	end

	if _G.ZoneAbilityFrame then
		_G.ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	end

	if _G.ExtraActionBarFrame then
		_G.ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	end
end

function AB:ExtraButtons_SetupBoss()
	local ExtraActionBarFrame = _G.ExtraActionBarFrame
	if not ExtraActionBarFrame then return end

	if not extraHooked[ExtraActionBarFrame] then
		hooksecurefunc(ExtraActionBarFrame, 'SetParent', AB.ExtraButtons_BossParent)

		extraHooked[ExtraActionBarFrame] = true
	end

	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetAllPoints()

	if E.Retail then
		ExtraActionBarFrame.ignoreInLayout = true
	else
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil
	end
end

function AB:ExtraButtons_SetupZone()
	local ZoneAbilityFrame = _G.ZoneAbilityFrame
	if not ZoneAbilityFrame then return end

	if not extraHooked[ZoneAbilityFrame] then
		ZoneAbilityFrame.SpellButtonContainer.holder = ZoneAbilityHolder
		ZoneAbilityFrame.SpellButtonContainer:HookScript('OnEnter', AB.ExtraButtons_OnEnter)
		ZoneAbilityFrame.SpellButtonContainer:HookScript('OnLeave', AB.ExtraButtons_OnLeave)

		hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, 'SetSize', AB.ExtraButtons_ZoneScale)
		hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', AB.ExtraButtons_ZoneStyle)
		hooksecurefunc(ZoneAbilityFrame, 'SetParent', AB.ExtraButtons_ZoneParent)

		extraHooked[ZoneAbilityFrame] = true
	end

	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetAllPoints()
	ZoneAbilityFrame.ignoreInLayout = true

	if ZoneAbilityHolder then
		ZoneAbilityHolder:Size(52 * E.db.actionbar.zoneActionButton.scale)
	end
end

function AB:ExtraButtons_SetupAbility()
	local ExtraAbilityContainer = _G.ExtraAbilityContainer
	if ExtraAbilityContainer then
		if not extraHooked[ExtraAbilityContainer] then
			-- try to shutdown the container movement and taints
			ExtraAbilityContainer:KillEditMode()
			ExtraAbilityContainer:SetScript('OnShow', nil)
			ExtraAbilityContainer:SetScript('OnUpdate', nil)
			ExtraAbilityContainer.OnUpdate = nil -- remove BaseLayoutMixin.OnUpdate
			ExtraAbilityContainer.IsLayoutFrame = nil -- dont let it get readded

			hooksecurefunc(ExtraAbilityContainer, 'AddFrame', AB.ExtraButtons_AddFrame)

			extraHooked[ExtraAbilityContainer] = true
		end
	else
		for i = 1, _G.ExtraActionBarFrame:GetNumChildren() do
			local button = _G['ExtraActionButton'..i]
			if button then
				button.commandName = 'EXTRAACTIONBUTTON'..i -- to support KB like retail

				AB:ExtraButtons_BossStyle(button)
			end
		end
	end
end

function AB:CreateExtraHolders()
	if not ExtraActionBarHolder then
		ExtraActionBarHolder = CreateFrame('Frame', 'ElvUI_ExtraActionBarHolder', E.UIParent)
		ExtraActionBarHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', -150, 300)
		E.FrameLocks[ExtraActionBarHolder] = true

		E:CreateMover(ExtraActionBarHolder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,extraActionButton')
	end

	if not ZoneAbilityHolder then
		ZoneAbilityHolder = CreateFrame('Frame', 'ElvUI_ZoneAbilityHolder', E.UIParent)
		ZoneAbilityHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 150, 300)
		E.FrameLocks[ZoneAbilityHolder] = true

		E:CreateMover(ZoneAbilityHolder, 'ZoneAbility', L["Zone Ability"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraButtons,extraActionButton')
	end
end

function AB:SetupExtraButtons()
	AB:CreateExtraHolders()			-- make the holders
	AB:ExtraButtons_Reparent()		-- reparent to the holders (keep before setup)
	AB:ExtraButtons_SetupBoss()		-- attach boss
	AB:ExtraButtons_SetupZone()		-- attach zone
	AB:ExtraButtons_SetupAbility()	-- attach abilities
	AB:UpdateExtraButtons()			-- update the settings
end

function AB:UpdateExtraButtons()
	AB:ExtraButtons_UpdateAlpha()
	AB:ExtraButtons_UpdateScale()
	AB:ExtraButtons_GlobalFade()
end

function AB:UpdateExtraBindings()
	_G.ExtraActionBarFrame.db = E.db.actionbar.extraActionButton

	for _, button in pairs(extraBtns) do
		button.HotKey:SetText(GetBindingKey(button.commandName))

		AB:FixKeybindText(button)
		AB:FixKeybindColor(button)
	end
end
