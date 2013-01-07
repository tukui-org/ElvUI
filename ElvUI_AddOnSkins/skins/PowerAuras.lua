local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

LoadAddOn("PowerAurasOptions")


local function SkinPowerAuras(self, aura, elapsed)
	local returnValue = PowaAuras.OldUpdateAura(self, aura, elapsed)
	
	if (aura == nil) or (aura.off) then
		return false;
	end

	if (aura.Showing) then
		local frame = aura:GetFrame();
		if (frame == nil) then
			return false;
		end
		
		if frame and not frame.backdrop then
			frame:CreateBackdrop('Default')
			frame.backdrop:Hide()
		end
		
		if frame and aura.owntex then
			local texture = aura:GetTexture()
			if not frame.backdrop:IsShown() then
				frame.backdrop:Show()
			end
			texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		elseif frame and frame.backdrop:IsShown() then
			frame.backdrop:Hide()
		end
	end
	
	return returnValue
end

local function PowerAuras_LoadSkin()
	local name = "PowerAurasIconsSkin"
	local function SkinPowerAurasIcons(self)
		PowaAuras.OldUpdateAura = PowaAuras.UpdateAura
		PowaAuras.UpdateAura = SkinPowerAuras
	end
	AS:RegisterSkin(name,SkinPowerAurasIcons)
end


local name = "PowerAurasSkin"
local function SkinPowerAuras(self)
	AS:SkinFrame(PowaOptionsFrame)
	AS:SkinFrame(PowaBarConfigFrame)
	AS:SkinFrame(PowaOptionsFrame)
	AS:SkinFrame(PowaBarConfigFrame)
	AS:SkinFrame(PowaAuraExportDialog)
	AS:SkinFrame(PowaAuraPlayerImportDialog)
	S:HandleEditBox(PowaAuraExportDialogCopyBox)
	S:HandleEditBox(PowaAuraExportDialogSendBox)
	S:HandleEditBox(PowaBarCustomSound)
	S:HandleEditBox(PowaBarCustomSoundEnd)

	S:HandleCloseButton(PowaOptionsFrameCloseButton)
	S:HandleCloseButton(PowaCloseButton)
	S:HandleButton(PowaOptionsRename)
	S:HandleButton(PowaOptionsSelectorNew)
	S:HandleButton(PowaOptionsSelectorDelete)
	S:HandleButton(PowaOptionsSelectorImport)
	S:HandleButton(PowaOptionsSelectorExport)
	S:HandleButton(PowaOptionsSelectorImportSet)
	S:HandleButton(PowaOptionsSelectorExportSet)
	S:HandleButton(PowaOptionsCopy)
	S:HandleButton(PowaOptionsMove)
	S:HandleButton(PowaMainLockButton)
	S:HandleButton(PowaMainTestAllButton)
	S:HandleButton(PowaMainTestButton)
	S:HandleButton(PowaMainHideAllButton)
	S:HandleButton(PowaEditButton)
	S:HandleButton(PowaAuraExportDialogSendButton)
	S:HandleButton(PowaAuraExportDialogCancelButton)
	S:HandleButton(PowaAuraPlayerImportDialogAcceptButton)
	S:HandleButton(PowaAuraPlayerImportDialogCancelButton)
	S:HandleButton(PowaBarAuraTextureSliderMinus)
	S:HandleButton(PowaBarAuraTextureSliderPlus)
	S:HandleButton(PowaBarAuraSizeSliderMinus)
	S:HandleButton(PowaBarAuraSizeSliderPlus)
	S:HandleButton(PowaBarAuraCoordXSliderMinus)
	S:HandleButton(PowaBarAuraCoordXSliderPlus)
	S:HandleButton(PowaBarAuraCoordSliderMinus)
	S:HandleButton(PowaBarAuraCoordSliderPlus)
	S:HandleButton(PowaBarAuraAnimSpeedSliderPlus)
	S:HandleButton(PowaBarAuraAnimSpeedSliderMinus)
	S:HandleButton(PowaBarAuraDurationSliderMinus)
	S:HandleButton(PowaBarAuraDurationSliderPlus)
	S:HandleButton(PowaTimerCoordXSliderMinus)
	S:HandleButton(PowaTimerCoordXSliderPlus)
	S:HandleButton(PowaTimerCoordSliderMinus)
	S:HandleButton(PowaTimerCoordSliderPlus)
	S:HandleButton(PowaTimerSizeSliderMinus)
	S:HandleButton(PowaTimerSizeSliderPlus)
	S:HandleButton(PowaTimerAlphaSliderMinus)
	S:HandleButton(PowaTimerAlphaSliderPlus)
	S:HandleButton(PowaTimerInvertAuraSliderMinus)
	S:HandleButton(PowaTimerInvertAuraSliderPlus)
	S:HandleButton(PowaStacksCoordXSliderMinus)
	S:HandleButton(PowaStacksCoordXSliderPlus)
	S:HandleButton(PowaStacksCoordSliderMinus)
	S:HandleButton(PowaStacksCoordSliderPlus)
	S:HandleButton(PowaStacksSizeSliderMinus)
	S:HandleButton(PowaStacksSizeSliderPlus)
	S:HandleButton(PowaStacksAlphaSliderMinus)
	S:HandleButton(PowaStacksAlphaSliderPlus)

	S:HandleDropDownBox(PowaDropDownBuffType)
	S:HandleDropDownBox(PowaDropDownAnimBegin)
	S:HandleDropDownBox(PowaDropDownAnimEnd)
	S:HandleDropDownBox(PowaDropDownAnim1)
	S:HandleDropDownBox(PowaDropDownAnim2)
	S:HandleDropDownBox(PowaDropDownSound)
	S:HandleDropDownBox(PowaDropDownSound2)
	S:HandleDropDownBox(PowaDropDownSoundEnd)
	S:HandleDropDownBox(PowaDropDownSound2End)
	S:HandleDropDownBox(PowaDropDownTimerTexture)
	S:HandleDropDownBox(PowaBuffTimerRelative)
	S:HandleDropDownBox(PowaDropDownStacksTexture)
	S:HandleDropDownBox(PowaBuffStacksRelative)

	S:HandleCheckBox(PowaShowStacksButton)
	S:HandleCheckBox(PowaExactButton)
	S:HandleCheckBox(PowaIngoreCaseButton)
	S:HandleCheckBox(PowaInverseButton)
	S:HandleCheckBox(PowaInCombatButton)
	S:HandleCheckBox(PowaIsInPartyButton)
	S:HandleCheckBox(PowaIsMountedButton)
	S:HandleCheckBox(PowaTargetButton)
	S:HandleCheckBox(PowaFocusButton)
	S:HandleCheckBox(PowaPartyButton)
	S:HandleCheckBox(PowaOptunitnButton)
	S:HandleCheckBox(PowaTalentGroup1Button)
	S:HandleCheckBox(PowaTalentGroup2Button)
	S:HandleCheckBox(PowaMineButton)
	S:HandleCheckBox(PowaRestingButton)
	S:HandleCheckBox(PowaIsInRaidButton)
	S:HandleCheckBox(PowaInVehicleButton)
	S:HandleCheckBox(PowaTargetFriendButton)
	S:HandleCheckBox(PowaGroupOrSelfButton)
	S:HandleCheckBox(PowaRaidButton)
	S:HandleCheckBox(PowaGroupAnyButton)
	S:HandleCheckBox(PowaPvPButton)
	S:HandleCheckBox(PowaIsAliveButton)
	S:HandleCheckBox(Powa5ManInstanceButton)
	S:HandleCheckBox(Powa5ManHeroicInstanceButton)
	S:HandleCheckBox(Powa10ManInstanceButton)
	S:HandleCheckBox(Powa10ManHeroicInstanceButton)
	S:HandleCheckBox(Powa25ManInstanceButton)
	S:HandleCheckBox(Powa25ManHeroicInstanceButton)
	S:HandleCheckBox(PowaArenaInstanceButton)
	S:HandleCheckBox(PowaBgInstanceButton)
	S:HandleCheckBox(PowaRoleHealerButton)
	S:HandleCheckBox(PowaRoleTankButton)
	S:HandleCheckBox(PowaRoleMeleDpsButton)
	S:HandleCheckBox(PowaRoleRangeDpsButton)
	S:HandleCheckBox(PowaAuraDebugButton)
	S:HandleCheckBox(PowaTexModeButton)
	S:HandleCheckBox(PowaWowTextureButton)
	S:HandleCheckBox(PowaCustomTextureButton)
	S:HandleCheckBox(PowaTextAuraButton)
	S:HandleCheckBox(PowaRandomColorButton)
	S:HandleCheckBox(PowaShowSpinAtBeginning)
	S:HandleCheckBox(PowaOldAnimation)
	S:HandleCheckBox(PowaShowTimerButton)
	S:HandleCheckBox(PowaBuffTimerCentsButton)
	S:HandleCheckBox(PowaBuffTimerLeadingZerosButton)
	S:HandleCheckBox(PowaBuffTimerTransparentButton)
	S:HandleCheckBox(PowaBuffTimerUseOwnColorButton)
	S:HandleCheckBox(PowaBuffTimerUpdatePingButton)
	S:HandleCheckBox(PowaBuffTimerActivationTime)
	S:HandleCheckBox(PowaBuffTimer99)
	S:HandleCheckBox(PowaBuffStacksTransparentButton)
	S:HandleCheckBox(PowaBuffStacksUseOwnColorButton)
	S:HandleCheckBox(PowaBuffStacksUpdatePingButton)
	S:HandleCheckBox(PowaBuffStacksLegacySizing)
	S:HandleCheckBox(PowaOwntexButton)
	
	S:HandleSliderFrame(PowaBarAuraTextureSlider)
	S:HandleSliderFrame(PowaBarAuraAlphaSlider)
	S:HandleSliderFrame(PowaBarAuraSizeSlider)
	S:HandleSliderFrame(PowaBarAuraCoordXSlider)
	S:HandleSliderFrame(PowaBarAuraCoordSlider)
	S:HandleSliderFrame(PowaBarAuraSymSlider)
	S:HandleSliderFrame(PowaBarAuraDeformSlider)
	S:HandleSliderFrame(PowaBarAuraAnimSpeedSlider)
	S:HandleSliderFrame(PowaBarAuraDurationSlider)
	S:HandleSliderFrame(PowaTimerCoordXSlider)
	S:HandleSliderFrame(PowaTimerSizeSlider)
	S:HandleSliderFrame(PowaTimerCoordSlider)
	S:HandleSliderFrame(PowaTimerAlphaSlider)
	S:HandleSliderFrame(PowaTimerInvertAuraSlider)
	S:HandleSliderFrame(PowaStacksCoordXSlider)
	S:HandleSliderFrame(PowaStacksCoordSlider)
	S:HandleSliderFrame(PowaStacksSizeSlider)
	S:HandleSliderFrame(PowaStacksAlphaSlider)
	
	S:HandleEditBox(PowaBarAuraTextureEdit)
	S:HandleEditBox(PowaBarBuffStacks)
	S:HandleEditBox(PowaBarBuffName)
	S:HandleEditBox(PowaBarMultiID)
	S:HandleEditBox(PowaBarTooltipCheck)
	S:HandleEditBox(PowaBarAuraCoordXEdit)
	S:HandleEditBox(PowaBarAuraCoordYEdit)

	for i = 1, 5 do
		S:HandleTab(_G["PowaEditorTab"..i])
		_G["PowaEditorTab"..i]:Height(30)
	end

end

AS:RegisterSkin(name,SkinPowerAuras)

--	AS:SkinFrame(PowerAurasGUIBrowser)
--	AS:SkinFrame(PowerAurasEditor)
--	S:HandleCloseButton(PowerAurasGUIBrowser.CloseButton)
--	S:HandleCloseButton(PowerAurasEditor.CloseButton)

--end)