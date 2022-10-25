local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:Blizzard_TrainerUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trainer) then return end

	local ClassTrainerFrame = _G.ClassTrainerFrame
	S:HandleFrame(ClassTrainerFrame, true, nil, 11, -12, -32, 76)

	_G.ClassTrainerExpandButtonFrame:StripTextures()

	S:HandleDropDownBox(_G.ClassTrainerFrameFilterDropDown)
	_G.ClassTrainerFrameFilterDropDown:Point('TOPRIGHT', -40, -64)

	_G.ClassTrainerListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ClassTrainerListScrollFrameScrollBar)

	_G.ClassTrainerDetailScrollFrame:StripTextures()
	S:HandleScrollBar(_G.ClassTrainerDetailScrollFrameScrollBar)

	_G.ClassTrainerSkillIcon:StripTextures()

	_G.ClassTrainerCancelButton:Kill()

	_G.ClassTrainerMoneyFrame:ClearAllPoints()
	_G.ClassTrainerMoneyFrame:Point('BOTTOMLEFT', _G.ClassTrainerFrame, 'BOTTOMLEFT', 18, 82)

	S:HandleButton(_G.ClassTrainerTrainButton)
	_G.ClassTrainerTrainButton:Point('BOTTOMRIGHT', -36, 80)

	S:HandleCloseButton(_G.ClassTrainerFrameCloseButton, ClassTrainerFrame.backdrop)

	hooksecurefunc('ClassTrainer_SetSelection', function()
		local skillIcon = _G.ClassTrainerSkillIcon:GetNormalTexture()
		if skillIcon then
			skillIcon:SetInside()
			skillIcon:SetTexCoord(unpack(E.TexCoords))

			_G.ClassTrainerSkillIcon:SetTemplate()
		end
	end)

	for i = 1, _G.CLASS_TRAINER_SKILLS_DISPLAYED do
		local button = _G['ClassTrainerSkill'..i]
		local highlight = _G['ClassTrainerSkill'..i..'Highlight']

		button:SetNormalTexture(E.Media.Textures.PlusButton)
		button.SetNormalTexture = E.noop

		button:GetNormalTexture():Size(16)
		button:GetNormalTexture():Point('LEFT', 5, 0)

		highlight:SetTexture('')
		highlight.SetTexture = E.noop

		S:HandleCollapseTexture(button)
	end

	_G.ClassTrainerCollapseAllButton:SetNormalTexture(E.Media.Textures.PlusButton)
	_G.ClassTrainerCollapseAllButton.SetNormalTexture = E.noop
	_G.ClassTrainerCollapseAllButton:GetNormalTexture():SetPoint('LEFT', 3, 2)
	_G.ClassTrainerCollapseAllButton:GetNormalTexture():Size(15)

	_G.ClassTrainerCollapseAllButton:SetHighlightTexture(E.ClearTexture)
	_G.ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop

	_G.ClassTrainerCollapseAllButton:SetDisabledTexture(E.Media.Textures.PlusButton)
	_G.ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop
	_G.ClassTrainerCollapseAllButton:GetDisabledTexture():SetPoint('LEFT', 3, 2)
	_G.ClassTrainerCollapseAllButton:GetDisabledTexture():Size(15)
	_G.ClassTrainerCollapseAllButton:GetDisabledTexture():SetDesaturated(true)

	S:HandleCollapseTexture(_G.ClassTrainerCollapseAllButton)
end

S:AddCallbackForAddon('Blizzard_TrainerUI')
