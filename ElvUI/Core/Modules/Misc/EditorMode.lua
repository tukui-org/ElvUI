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

do	-- if only HideUIPanel wasn't blocked :(
	local eventFrames = {}
	local eventFrame = CreateFrame('Frame')

	local function onEvent(_, event)
		local editMode = _G.EditModeManagerFrame
		if event == 'EDIT_MODE_LAYOUTS_UPDATED' then
			if not editMode:IsEventRegistered(event) then
				eventFrame.updateLayout = true
			end
		else
			local combatLeave = event == 'PLAYER_REGEN_ENABLED'
			_G.GameMenuButtonEditMode:SetEnabled(combatLeave)

			if combatLeave then
				if next(eventFrames) then
					for frame in next, eventFrames do
						HideUIPanel(frame)
						frame:SetScale(1)

						eventFrames[frame] = nil
					end
				end

				if eventFrame.updateLayout then
					editMode:UpdateLayoutInfo(GetLayouts())
					eventFrame.updateLayout = nil
				end

				editMode:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED')
			else
				editMode:UnregisterEvent('EDIT_MODE_LAYOUTS_UPDATED')
			end
		end
	end

	local function handleHide(frame)
		local combat = InCombatLockdown()
		if combat then -- fake hide the editmode system
			eventFrames[frame] = true

			for _, child in next, frame.registeredSystemFrames do
				child:ClearHighlight()
			end
		end

		HideUIPanel(frame, not combat)
		frame:SetScale(combat and 0.00001 or 1)
	end

	local function onProceed()
		local editMode = _G.EditModeManagerFrame
		local dialog = _G.EditModeUnsavedChangesDialog
		if dialog.selectedLayoutIndex then
			editMode:SelectLayout(dialog.selectedLayoutIndex)
		else
			handleHide(editMode, dialog)
		end

		StaticPopupSpecial_Hide(dialog)
	end

	local function onSaveProceed()
		_G.EditModeManagerFrame:SaveLayoutChanges()
		onProceed()
	end

	local function onClose()
		local editMode = _G.EditModeManagerFrame
		if editMode:HasActiveChanges() then
			editMode:ShowRevertWarningDialog()
		else
			handleHide(editMode)
		end
	end

	local function setEnabled(frame, enabled)
		if InCombatLockdown() and enabled then
			frame:Disable()
		end
	end

	function E:SetupEditMode()
		local dialog = _G.EditModeUnsavedChangesDialog
		dialog.ProceedButton:SetScript('OnClick', onProceed)
		dialog.SaveAndProceedButton:SetScript('OnClick', onSaveProceed)

		_G.EditModeManagerFrame.onCloseCallback = onClose

		eventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
		eventFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
		eventFrame:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED')
		eventFrame:SetScript('OnEvent', onEvent)

		hooksecurefunc(_G.GameMenuButtonEditMode, 'SetEnabled', setEnabled)
	end
end

function EM:Initialize()
	E:SetupEditMode()

	-- account settings will be tainted
	local mixin = _G.EditModeManagerFrame.AccountSettings
	if CheckCastFrame() then mixin.RefreshCastBar = E.noop end
	if CheckAuraFrame() then mixin.RefreshAuraFrame = E.noop end
	if CheckBossFrame() then mixin.RefreshBossFrames = E.noop end
	if CheckArenaFrame() then mixin.RefreshArenaFrames = E.noop end

	if CheckRaidFrame() then
		mixin.RefreshRaidFrames = E.noop
		mixin.ResetRaidFrames = E.noop
	end
	if CheckPartyFrame() then
		mixin.RefreshPartyFrames = E.noop
		mixin.ResetPartyFrames = E.noop
	end
	if CheckTargetFrame() and CheckFocusFrame() then
		mixin.RefreshTargetAndFocus = E.noop
		mixin.ResetTargetAndFocus = E.noop
	end

	if CheckActionBar() then
		mixin.RefreshVehicleLeaveButton = E.noop
		mixin.RefreshActionBarShown = E.noop
		mixin.RefreshEncounterBar = E.noop
	end
end

E:RegisterModule(EM:GetName())
