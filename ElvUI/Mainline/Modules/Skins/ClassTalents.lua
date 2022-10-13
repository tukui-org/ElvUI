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
	ClassTalentFrame.TalentsTab.SearchBox.backdrop:SetPoint('TOPLEFT', -4, -5)
	ClassTalentFrame.TalentsTab.SearchBox.backdrop:SetPoint('BOTTOMRIGHT', 0, 5)
	ClassTalentFrame.TalentsTab.SearchPreviewContainer:StripTextures()
	ClassTalentFrame.TalentsTab.SearchPreviewContainer:CreateBackdrop('Transparent')

	for i = 1, 2 do
		local tab = select(i, ClassTalentFrame.TabSystem:GetChildren())
		S:HandleTab(tab)
	end

	hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecFrame', function(frame)
		for specContentFrame in frame.SpecContentFramePool:EnumerateActive() do
			if not specContentFrame.isSkinned then
				S:HandleButton(specContentFrame.ActivateButton)

				specContentFrame.isSkinned = true
			end
		end
	end)

	local ImportDialog = _G.ClassTalentLoadoutImportDialog
	if ImportDialog then
		ImportDialog:StripTextures()
		ImportDialog:CreateBackdrop('Transparent')
		S:HandleButton(ImportDialog.AcceptButton)
		S:HandleButton(ImportDialog.CancelButton)

		ImportDialog.ImportControl.InputContainer:StripTextures()
		ImportDialog.ImportControl.InputContainer:CreateBackdrop('Transparent')
		S:HandleEditBox(ImportDialog.NameControl.EditBox)
		ImportDialog.NameControl.EditBox.backdrop:SetPoint('TOPLEFT', -5, -10)
		ImportDialog.NameControl.EditBox.backdrop:SetPoint('BOTTOMRIGHT', 5, 10)
	end

	local CreateDialog = _G.ClassTalentLoadoutCreateDialog
	if CreateDialog then
		CreateDialog:StripTextures()
		CreateDialog:CreateBackdrop('Transparent')
		S:HandleButton(CreateDialog.AcceptButton)
		S:HandleButton(CreateDialog.CancelButton)

		S:HandleEditBox(CreateDialog.NameControl.EditBox)
		CreateDialog.NameControl.EditBox.backdrop:SetPoint('TOPLEFT', -5, -10)
		CreateDialog.NameControl.EditBox.backdrop:SetPoint('BOTTOMRIGHT', 5, 10)
	end

	local EditDialog = _G.ClassTalentLoadoutEditDialog
	if EditDialog then
		EditDialog:StripTextures()
		EditDialog:CreateBackdrop('Transparent')
		S:HandleButton(EditDialog.AcceptButton)
		S:HandleButton(EditDialog.DeleteButton)
		S:HandleButton(EditDialog.CancelButton)

		local editbox = EditDialog.LoadoutName
		if editbox then
			S:HandleEditBox(editbox)
			editbox.backdrop:SetPoint('TOPLEFT', -5, -5)
			editbox.backdrop:SetPoint('BOTTOMRIGHT', 5, 5)
		end

		local check = EditDialog.UsesSharedActionBars
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
