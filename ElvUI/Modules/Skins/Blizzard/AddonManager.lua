local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.addonManager ~= true then return end

	local AddonList = _G.AddonList
	S:HandlePortraitFrame(AddonList, true)
	S:HandleButton(AddonList.EnableAllButton, true)
	S:HandleButton(AddonList.DisableAllButton, true)
	S:HandleButton(AddonList.OkayButton, true)
	S:HandleButton(AddonList.CancelButton, true)
	S:HandleDropDownBox(_G.AddonCharacterDropDown, 165)
	S:HandleScrollBar(_G.AddonListScrollFrameScrollBar)
	S:HandleCheckBox(_G.AddonListForceLoad)
	_G.AddonListForceLoad:Size(26, 26)

	_G.AddonListScrollFrame:StripTextures()
	_G.AddonListScrollFrame:CreateBackdrop('Transparent')
	_G.AddonListScrollFrame.backdrop:Point('TOPLEFT', -14, 0)
	_G.AddonListScrollFrame.backdrop:Point('BOTTOMRIGHT', 0, -1)

	for i = 1, _G.MAX_ADDONS_DISPLAYED do
		S:HandleCheckBox(_G["AddonListEntry"..i.."Enabled"], nil, nil, true)
		S:HandleButton(_G["AddonListEntry"..i].LoadAddonButton)
	end
end

S:AddCallback("AddonManager", LoadSkin)
