local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:PetitionFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.petition) then return end

	local parchmentRemover = E.private.skins.parchmentRemoverEnable

	local PetitionFrame = _G.PetitionFrame
	if parchmentRemover then
		PetitionFrame:StripTextures(true)
	else
		local pageBG = PetitionFrame.Bg:GetAtlas()
		PetitionFrame:StripTextures()
		PetitionFrame.Bg:SetAtlas(pageBG)
		PetitionFrame.Bg:SetDrawLayer('BACKGROUND', 1) -- above the ElvUI backdrop
	end

	PetitionFrame:SetTemplate('Transparent')
	_G.PetitionFrameInset:Kill()

	S:HandleTrimScrollBar(PetitionFrame.ScrollBar)

	S:HandleButton(_G.PetitionFrameSignButton)
	S:HandleButton(_G.PetitionFrameRequestButton)
	S:HandleButton(_G.PetitionFrameRenameButton)
	S:HandleButton(_G.PetitionFrameCancelButton)
	S:HandleCloseButton(_G.PetitionFrameCloseButton)

	if parchmentRemover then
		_G.PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
		_G.PetitionFrameCharterName:SetTextColor(1, 1, 1)
		_G.PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
		_G.PetitionFrameMasterName:SetTextColor(1, 1, 1)
		_G.PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

		for i = 1, 9 do
			_G['PetitionFrameMemberName'..i]:SetTextColor(1, 1, 1)
		end

		_G.PetitionFrameInstructions:SetTextColor(1, 1, 1)
	end

	_G.PetitionFrameRenameButton:Point('LEFT', _G.PetitionFrameRequestButton, 'RIGHT', 3, 0)
	_G.PetitionFrameRenameButton:Point('RIGHT', _G.PetitionFrameCancelButton, 'LEFT', -3, 0)
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'PetitionFrame')
