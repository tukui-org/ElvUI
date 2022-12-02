local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local _G = _G
local next = next
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

local GetLayouts = C_EditMode.GetLayouts
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide

local CheckTargetFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.target end
local CheckCastFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.castbar end
local CheckArenaFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.arena end
local CheckPartyFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.party end
local CheckFocusFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.focus end
local CheckRaidFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.raid end
local CheckBossFrame = function() return E.private.unitframe.enable and E.private.unitframe.disabledBlizzardFrames.boss end
local CheckAuraFrame = function() return E.private.auras.disableBlizzard end
local CheckActionBar = function() return E.private.actionbar.enable end

local hideFrames = {}
EM.needsUpdate = false
EM.hideFrames = hideFrames

function EM:LAYOUTS_UPDATED(event, arg1)
	local allow = event ~= 'PLAYER_SPECIALIZATION_CHANGED' or arg1 == 'player'
	if allow and not _G.EditModeManagerFrame:IsEventRegistered(event) then
		EM.needsUpdate = true
	end
end

function EM:PLAYER_REGEN(event)
	local editMode = _G.EditModeManagerFrame
	local combatLeave = event == 'PLAYER_REGEN_ENABLED'
	_G.GameMenuButtonEditMode:SetEnabled(combatLeave)

	if combatLeave then
		if next(hideFrames) then
			for frame in next, hideFrames do
				HideUIPanel(frame)
				frame:SetScale(1)

				hideFrames[frame] = nil
			end
		end

		if EM.needsUpdate then
			editMode:UpdateLayoutInfo(GetLayouts())

			EM.needsUpdate = false
		end

		editMode:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED')
		editMode:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
	else
		editMode:UnregisterEvent('EDIT_MODE_LAYOUTS_UPDATED')
		editMode:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	end
end

function EM:HandleHide(frame)
	local combat = InCombatLockdown()
	if combat then -- fake hide the editmode system
		hideFrames[frame] = true

		for _, child in next, frame.registeredSystemFrames do
			child:ClearHighlight()
		end
	end

	HideUIPanel(frame, not combat)
	frame:SetScale(combat and 0.00001 or 1)
end

function EM:OnProceed()
	local editMode = _G.EditModeManagerFrame
	local dialog = _G.EditModeUnsavedChangesDialog
	if dialog.selectedLayoutIndex then
		editMode:SelectLayout(dialog.selectedLayoutIndex)
	else
		EM:HandleHide(editMode, dialog)
	end

	StaticPopupSpecial_Hide(dialog)
end

function EM:OnSaveProceed()
	_G.EditModeManagerFrame:SaveLayoutChanges()
	EM:OnProceed()
end

function EM:OnClose()
	local editMode = _G.EditModeManagerFrame
	if editMode:HasActiveChanges() then
		editMode:ShowRevertWarningDialog()
	else
		EM:HandleHide(editMode)
	end
end

function EM:SetEnabled(enabled)
	if InCombatLockdown() and enabled then
		self:Disable()
	end
end

function EM:Initialize()
	-- unsaved changes cant open or close the window in combat
	local dialog = _G.EditModeUnsavedChangesDialog
	dialog.ProceedButton:SetScript('OnClick', EM.OnProceed)
	dialog.SaveAndProceedButton:SetScript('OnClick', EM.OnSaveProceed)

	-- the panel itself cant either
	_G.EditModeManagerFrame.onCloseCallback = EM.OnClose

	-- keep the button off during combat
	hooksecurefunc(_G.GameMenuButtonEditMode, 'SetEnabled', EM.SetEnabled)

	-- wait for combat leave to do stuff
	EM:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED', 'LAYOUTS_UPDATED')
	EM:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'LAYOUTS_UPDATED')
	EM:RegisterEvent('PLAYER_REGEN_ENABLED', 'PLAYER_REGEN')
	EM:RegisterEvent('PLAYER_REGEN_DISABLED', 'PLAYER_REGEN')

	-- account settings will be tainted
	local mixin = _G.EditModeManagerFrame.AccountSettings
	if CheckCastFrame() then mixin.RefreshCastBar = E.noop end
	if CheckAuraFrame() then mixin.RefreshAuraFrame = E.noop end
	if CheckBossFrame() then mixin.RefreshBossFrames = E.noop end
	if CheckArenaFrame() then mixin.RefreshArenaFrames = E.noop end
	if CheckRaidFrame() then mixin.RefreshRaidFrames = E.noop end
	if CheckPartyFrame() then mixin.RefreshPartyFrames = E.noop end
	if CheckTargetFrame() and CheckFocusFrame() then
		mixin.RefreshTargetAndFocus = E.noop
	end
	if CheckActionBar() then
		mixin.RefreshVehicleLeaveButton = E.noop
		mixin.RefreshActionBarShown = E.noop
		mixin.RefreshEncounterBar = E.noop
	end
end

E:RegisterModule(EM:GetName())
