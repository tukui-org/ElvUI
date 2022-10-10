local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

function S:Blizzard_ClassTalentUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.talent) then return end

	local ClassTalentFrame = _G.ClassTalentFrame
	S:HandlePortraitFrame(ClassTalentFrame)
	ClassTalentFrame.TalentsTab.BlackBG:SetAlpha(0)
	ClassTalentFrame.TalentsTab.BottomBar:SetAlpha(0)

	S:HandleButton(ClassTalentFrame.TalentsTab.ApplyButton)
	S:HandleDropDownBox(ClassTalentFrame.TalentsTab.LoadoutDropDown.DropDownControl.DropDownMenu)

	S:HandleEditBox(ClassTalentFrame.TalentsTab.SearchBox)
	ClassTalentFrame.TalentsTab.SearchPreviewContainer:StripTextures()
	ClassTalentFrame.TalentsTab.SearchPreviewContainer:CreateBackdrop('Transparent')

	for i = 1, 2 do
		local tab = select(i, ClassTalentFrame.TabSystem:GetChildren())
		S:HandleTab(tab)
	end

	hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecFrame', function(self)
		for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
			if not specContentFrame.isSkinned then
				S:HandleButton(specContentFrame.ActivateButton)

				specContentFrame.isSkinned = true
			end
		end
	end)

	local dialog = _G.ClassTalentLoadoutImportDialog
	if dialog then
		dialog:StripTextures()
		dialog:CreateBackdrop('Transparent')
		S:HandleButton(dialog.AcceptButton)
		S:HandleButton(dialog.CancelButton)

		dialog.ImportControl.InputContainer:StripTextures()
		dialog.ImportControl.InputContainer:CreateBackdrop('Transparent')
		S:HandleEditBox(dialog.NameControl.EditBox)
		dialog.NameControl.EditBox.backdrop:SetPoint('TOPLEFT', -5, -10)
		dialog.NameControl.EditBox.backdrop:SetPoint('BOTTOMRIGHT', 5, 10)
	end

	local dialog = _G.ClassTalentLoadoutCreateDialog
	if dialog then
		dialog:StripTextures()
		dialog:CreateBackdrop('Transparent')
		S:HandleButton(dialog.AcceptButton)
		S:HandleButton(dialog.CancelButton)

		S:HandleEditBox(dialog.NameControl.EditBox)
		dialog.NameControl.EditBox.backdrop:SetPoint('TOPLEFT', -5, -10)
		dialog.NameControl.EditBox.backdrop:SetPoint('BOTTOMRIGHT', 5, 10)
	end

	local dialog = _G.ClassTalentLoadoutEditDialog
	if dialog then
		dialog:StripTextures()
		dialog:CreateBackdrop('Transparent')
		S:HandleButton(dialog.AcceptButton)
		S:HandleButton(dialog.DeleteButton)
		S:HandleButton(dialog.CancelButton)

		local editbox = dialog.LoadoutName
		if editbox then
			S:HandleEditBox(editbox)
			editbox.backdrop:SetPoint('TOPLEFT', -5, -5)
			editbox.backdrop:SetPoint('BOTTOMRIGHT', 5, 5)
		end

		local check = dialog.UsesSharedActionBars
		if check then
			S:HandleCheckBox(check.CheckButton)
			check.CheckButton.backdrop:SetInside(6, 6)
		end
	end

	--PVP
	ClassTalentFrame.TalentsTab.PvPTalentList:StripTextures()
	ClassTalentFrame.TalentsTab.PvPTalentList:CreateBackdrop()
	ClassTalentFrame.TalentsTab.PvPTalentList.backdrop:SetFrameStrata(ClassTalentFrame.TalentsTab.PvPTalentList:GetFrameStrata())
	ClassTalentFrame.TalentsTab.PvPTalentList.backdrop:SetFrameLevel(2000)
end

S:AddCallbackForAddon('Blizzard_ClassTalentUI')
