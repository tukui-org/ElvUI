local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.nonraid ~= true then return end
	local StripAllTextures = {
		"RaidInfoFrame",
		"RaidInfoInstanceLabel",
		"RaidInfoIDLabel",
	}

	local KillTextures = {
		"RaidInfoScrollFrameScrollBarBG",
		"RaidInfoScrollFrameScrollBarTop",
		"RaidInfoScrollFrameScrollBarBottom",
		"RaidInfoScrollFrameScrollBarMiddle",
	}
	local buttons = {
		"RaidFrameConvertToRaidButton",
		"RaidFrameRaidInfoButton",
		"RaidInfoExtendButton",
		"RaidInfoCancelButton",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	for i = 1, #buttons do
		S:HandleButton(_G[buttons[i]])
	end
	RaidInfoScrollFrame:StripTextures()
	RaidInfoFrame:CreateBackdrop("Transparent")
	RaidInfoFrame.backdrop:Point( "TOPLEFT", RaidInfoFrame, "TOPLEFT")
	RaidInfoFrame.backdrop:Point( "BOTTOMRIGHT", RaidInfoFrame, "BOTTOMRIGHT")
	S:HandleCloseButton(RaidInfoCloseButton,RaidInfoFrame)
	S:HandleScrollBar(RaidInfoScrollFrameScrollBar)
	S:HandleCheckBox(RaidFrameAllAssistCheckButton)
end

S:RegisterSkin('ElvUI', LoadSkin)