local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs = pairs

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.nonraid ~= true then return end

	local StripAllTextures = {
		_G.RaidInfoFrame,
		_G.RaidInfoInstanceLabel,
		_G.RaidInfoIDLabel,
	}
	local KillTextures = {
		_G.RaidInfoScrollFrameScrollBarBG,
		_G.RaidInfoScrollFrameScrollBarTop,
		_G.RaidInfoScrollFrameScrollBarBottom,
		_G.RaidInfoScrollFrameScrollBarMiddle,
	}
	local buttons = {
		_G.RaidFrameConvertToRaidButton,
		_G.RaidFrameRaidInfoButton,
		_G.RaidInfoExtendButton,
		_G.RaidInfoCancelButton,
	}

	for _, object in pairs(StripAllTextures) do
		object:StripTextures()
	end
	for _, texture in pairs(KillTextures) do
		texture:Kill()
	end
	for i = 1, #buttons do
		S:HandleButton(buttons[i])
	end

	_G.RaidInfoScrollFrame:StripTextures()

	local RaidInfoFrame = _G.RaidInfoFrame
	RaidInfoFrame:CreateBackdrop("Transparent")
	RaidInfoFrame.backdrop:Point( "TOPLEFT", RaidInfoFrame, "TOPLEFT")
	RaidInfoFrame.backdrop:Point( "BOTTOMRIGHT", RaidInfoFrame, "BOTTOMRIGHT")
	S:HandleCloseButton(_G.RaidInfoCloseButton,RaidInfoFrame)
	S:HandleScrollBar(_G.RaidInfoScrollFrameScrollBar)
	S:HandleCheckBox(_G.RaidFrameAllAssistCheckButton)
end

S:AddCallback("RaidInfo", LoadSkin)
