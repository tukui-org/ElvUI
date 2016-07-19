local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.addonManager ~= true then return end
	--Addon List (From AddOnSkins)
	AddonList:StripTextures()
	AddonList:SetTemplate("Transparent")
	AddonListInset:StripTextures()

	S:HandleButton(AddonListEnableAllButton, true)
	S:HandleButton(AddonListDisableAllButton, true)
	S:HandleButton(AddonListOkayButton, true)
	S:HandleButton(AddonListCancelButton, true)

	S:HandleScrollBar(AddonListScrollFrameScrollBar, 5)

	S:HandleCheckBox(AddonListForceLoad)
	AddonListForceLoad:SetSize(26, 26)
	S:HandleDropDownBox(AddonCharacterDropDown)

	S:HandleCloseButton(AddonListCloseButton)

	for i=1, MAX_ADDONS_DISPLAYED do
		S:HandleCheckBox(_G["AddonListEntry"..i.."Enabled"])
		S:HandleButton(_G["AddonListEntry"..i].LoadAddonButton)
	end
end

S:RegisterSkin('ElvUI', LoadSkin)