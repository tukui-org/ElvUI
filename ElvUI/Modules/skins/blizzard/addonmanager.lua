local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: MAX_ADDONS_DISPLAYED

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.addonManager ~= true then return end

	--Addon List (From AddOnSkins)
	local AddonList = _G["AddonList"]
	AddonList:StripTextures()
	AddonList:SetTemplate("Transparent")

	--Original Size: 500, 478
	AddonList:SetSize(550, 478)

	--Original Size: 449,99, 382
	--Adjusting the ScrollFrame will also positon the ScrollBar.
	AddonListScrollFrame:SetSize(499, 382)

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

S:AddCallback("AddonManager", LoadSkin)
