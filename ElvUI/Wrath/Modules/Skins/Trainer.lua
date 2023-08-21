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

		local normal = button:GetNormalTexture()
		if normal then
			normal:Size(16)
			normal:Point('LEFT', 5, 0)
		end

		local highlight = _G['ClassTrainerSkill'..i..'Highlight']
		if highlight then
			highlight:SetTexture('')
			highlight.SetTexture = E.noop
		end

		S:HandleCollapseTexture(button, nil, true)
	end

	-- Buttons
	local ClassTrainerCollapseAllButton = _G.ClassTrainerCollapseAllButton
	S:HandleCollapseTexture(ClassTrainerCollapseAllButton, nil, true)

	ClassTrainerCollapseAllButton:SetHighlightTexture(E.ClearTexture)
end

S:AddCallbackForAddon('Blizzard_TrainerUI')
