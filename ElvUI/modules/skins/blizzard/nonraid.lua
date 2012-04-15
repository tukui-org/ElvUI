local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.nonraid ~= true then return end
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
		"RaidFrameNotInRaidRaidBrowserButton",
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
		if _G[buttons[i]] then
			S:HandleButton(_G[buttons[i]])
		end
	end
	RaidInfoScrollFrame:StripTextures()
	RaidInfoFrame:CreateBackdrop("Transparent")
	RaidInfoFrame.backdrop:Point( "TOPLEFT", RaidInfoFrame, "TOPLEFT")
	RaidInfoFrame.backdrop:Point( "BOTTOMRIGHT", RaidInfoFrame, "BOTTOMRIGHT")
	S:HandleCloseButton(RaidInfoCloseButton,RaidInfoFrame)
end

S:RegisterSkin('ElvUI', LoadSkin)