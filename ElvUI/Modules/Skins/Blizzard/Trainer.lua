local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, unpack = pairs, unpack

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true then return end

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
	S:HandlePortraitFrame(ClassTrainerFrame, true)

	for i= 1, #ClassTrainerFrame.scrollFrame.buttons do
		local button = _G["ClassTrainerScrollFrameButton"..i]
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
	ClassTrainerFrame:CreateBackdrop("Transparent")
	ClassTrainerFrame.backdrop:Point("TOPLEFT", ClassTrainerFrame, "TOPLEFT")
	ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT")

	local ClassTrainerFrameSkillStepButton = _G.ClassTrainerFrameSkillStepButton
	ClassTrainerFrameSkillStepButton.icon:SetTexCoord(unpack(E.TexCoords))
	ClassTrainerFrameSkillStepButton:CreateBackdrop()
	ClassTrainerFrameSkillStepButton.backdrop:SetOutside(ClassTrainerFrameSkillStepButton.icon)
	ClassTrainerFrameSkillStepButton.icon:SetParent(ClassTrainerFrameSkillStepButton.backdrop)
	_G.ClassTrainerFrameSkillStepButtonHighlight:SetColorTexture(1,1,1,0.3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetColorTexture(1,1,1,0.3)

	local ClassTrainerStatusBar = _G.ClassTrainerStatusBar
	ClassTrainerStatusBar:StripTextures()
	ClassTrainerStatusBar:SetStatusBarTexture(E.media.normTex)
	ClassTrainerStatusBar:CreateBackdrop()
	ClassTrainerStatusBar.rankText:ClearAllPoints()
	ClassTrainerStatusBar.rankText:Point("CENTER", ClassTrainerStatusBar, "CENTER")
	E:RegisterStatusBar(ClassTrainerStatusBar)
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", LoadSkin)
