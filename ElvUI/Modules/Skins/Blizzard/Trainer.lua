local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs, unpack = pairs, unpack

function S:Blizzard_TrainerUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trainer) then return end

	--Class Trainer Frame
	local StripAllTextures = {
		_G.ClassTrainerScrollFrameScrollChild,
		_G.ClassTrainerFrameSkillStepButton,
		_G.ClassTrainerFrameBottomInset,
	}

	local buttons = {
		_G.ClassTrainerTrainButton,
	}

	local KillTextures = {
		_G.ClassTrainerFramePortrait,
		_G.ClassTrainerScrollFrameScrollBarBG,
		_G.ClassTrainerScrollFrameScrollBarTop,
		_G.ClassTrainerScrollFrameScrollBarBottom,
		_G.ClassTrainerScrollFrameScrollBarMiddle,
	}

	for _, object in pairs(StripAllTextures) do
		object:StripTextures()
	end

	for _, texture in pairs(KillTextures) do
		texture:Kill()
	end

	for i = 1, #buttons do
		buttons[i]:StripTextures()
		S:HandleButton(buttons[i])
	end

	local ClassTrainerFrame = _G.ClassTrainerFrame
	S:HandlePortraitFrame(ClassTrainerFrame)

	for i= 1, #ClassTrainerFrame.scrollFrame.buttons do
		local button = _G['ClassTrainerScrollFrameButton'..i]
		button:StripTextures()
		button:StyleButton()
		button.icon:SetTexCoord(unpack(E.TexCoords))
		button:CreateBackdrop()
		button.backdrop:SetOutside(button.icon)
		button.icon:SetParent(button.backdrop)
		button.selectedTex:SetColorTexture(1, 1, 1, 0.3)
		button.selectedTex:SetInside()
	end

	S:HandleScrollBar(_G.ClassTrainerScrollFrameScrollBar, 5)
	S:HandleDropDownBox(_G.ClassTrainerFrameFilterDropDown, 155)

	ClassTrainerFrame:Height(ClassTrainerFrame:GetHeight() + 5)
	ClassTrainerFrame:SetTemplate('Transparent')

	local stepButton = _G.ClassTrainerFrameSkillStepButton
	stepButton:SetTemplate()
	stepButton.icon:SetTexCoord(unpack(E.TexCoords))
	stepButton.selectedTex:SetColorTexture(1,1,1,0.3)
	_G.ClassTrainerFrameSkillStepButtonHighlight:SetColorTexture(1,1,1,0.3)

	local ClassTrainerStatusBar = _G.ClassTrainerStatusBar
	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:SetStatusBarTexture(E.media.normTex)
	ClassTrainerStatusBar:CreateBackdrop()
	ClassTrainerStatusBar.rankText:ClearAllPoints()
	ClassTrainerStatusBar.rankText:Point('CENTER', ClassTrainerStatusBar, 'CENTER')
	E:RegisterStatusBar(ClassTrainerStatusBar)
end

S:AddCallbackForAddon('Blizzard_TrainerUI')
