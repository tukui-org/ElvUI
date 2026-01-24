local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local _G = _G
local next = next
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

local GetLayouts = C_EditMode.GetLayouts
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide

local hideFrames = {}
EM.needsUpdate = false
EM.hideFrames = hideFrames -- used to temp hide editmode panels

function EM:LAYOUTS_UPDATED(event, arg1)
	local allow = event ~= 'PLAYER_SPECIALIZATION_CHANGED' or arg1 == 'player'
	if allow and not _G.EditModeManagerFrame:IsEventRegistered(event) then
		EM.needsUpdate = true
	end
end

function EM:GetGameMenuEditModeButton() -- MenuButtons is maade in API.lua
	local menu = _G.GameMenuFrame
	return menu and menu.MenuButtons and menu.MenuButtons[_G.HUD_EDIT_MODE_MENU]
end

function EM:PLAYER_REGEN(event)
	local editMode = _G.EditModeManagerFrame
	local combatLeave = event == 'PLAYER_REGEN_ENABLED'

	local button = EM:GetGameMenuEditModeButton()
	if button then
		button:SetEnabled(combatLeave)
	end

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
	local button = EM:GetGameMenuEditModeButton()
	if button then
		hooksecurefunc(button, 'SetEnabled', EM.SetEnabled)
	end

	-- wait for combat leave to do stuff
	EM:RegisterEvent('EDIT_MODE_LAYOUTS_UPDATED', 'LAYOUTS_UPDATED')
	EM:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'LAYOUTS_UPDATED')
	EM:RegisterEvent('PLAYER_REGEN_ENABLED', 'PLAYER_REGEN')
	EM:RegisterEvent('PLAYER_REGEN_DISABLED', 'PLAYER_REGEN')
end

E:RegisterModule(EM:GetName())
