local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local ToggleDropDownMenu = ToggleDropDownMenu
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, SHOW_BATTLEFIELDMINIMAP_PLAYERS, LOCK_BATTLEFIELDMINIMAP, BATTLEFIELDMINIMAP_OPACITY_LABEL
-- GLOBALS: BattlefieldMinimapTabDropDown_TogglePlayers, BattlefieldMinimapTabDropDown_ToggleLock
-- GLOBALS: BattlefieldMinimapTabDropDown_ShowOpacity, BattlefieldMinimap_UpdateOpacity
-- GLOBALS: UIDROPDOWNMENU_MENU_LEVEL

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end

	local BattlefieldMapFrame = _G["BattlefieldMapFrame"]
	BattlefieldMapFrame:SetClampedToScreen(true)
	BattlefieldMapFrame:StripTextures()

	BattlefieldMapFrame.BorderFrame:StripTextures()

	BattlefieldMapFrame:CreateBackdrop('Default')
	BattlefieldMapFrame.backdrop:SetAllPoints() -- Adjust me
	BattlefieldMapFrame:SetFrameStrata('LOW')

	BattlefieldMapFrame:EnableMouse(true)
	BattlefieldMapFrame:SetMovable(true)

	S:HandleCloseButton(BattlefieldMapFrame.BorderFrame.CloseButton)
	BattlefieldMapTab:StripTextures()
	S:HandleTab(BattlefieldMapTab) -- Adjust me

	--[[ Needs to be adjusted

	--Custom dropdown to avoid using regular DropDownMenu code (taints)
	local function BattlefieldMinimapTabDropDown_Initialize()
		local info = UIDropDownMenu_CreateInfo();

		-- Show battlefield players
		info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS;
		info.func = BattlefieldMinimapTabDropDown_TogglePlayers;
		info.checked = BattlefieldMinimapOptions and BattlefieldMinimapOptions.showPlayers or false;
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

		-- Battlefield minimap lock
		info.text = LOCK_BATTLEFIELDMINIMAP;
		info.func = BattlefieldMinimapTabDropDown_ToggleLock;
		info.checked = BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked or false;
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

		-- Opacity
		info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL;
		info.func = BattlefieldMinimapTabDropDown_ShowOpacity;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end

	local ElvUIBattlefieldMinimapTabDropDown = CreateFrame("Frame", "ElvUIBattlefieldMinimapTabDropDown", UIParent, "UIDropDownMenuTemplate")
	ElvUIBattlefieldMinimapTabDropDown:SetID(1)
	ElvUIBattlefieldMinimapTabDropDown:Hide()
	UIDropDownMenu_Initialize(ElvUIBattlefieldMinimapTabDropDown, BattlefieldMinimapTabDropDown_Initialize, "MENU");

	BattlefieldMapFrame:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			BattlefieldMinimapTab:StopMovingOrSizing()
			BattlefieldMinimapTab:SetUserPlaced(true)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, ElvUIBattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		end
	end)

	BattlefieldMapFrame:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" and (BattlefieldMinimapOptions and not BattlefieldMinimapOptions.locked) then
			BattlefieldMinimapTab:StartMoving()
		end
	end)

	hooksecurefunc('BattlefieldMinimap_UpdateOpacity', function()
		local alpha = 1.0 - (BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0);
		BattlefieldMapFrame.backdrop:SetAlpha(alpha)
	end)

	local oldAlpha
	BattlefieldMapFrame:HookScript('OnEnter', function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0;
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMapFrame:HookScript('OnLeave', function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil;
		end
	end)

	--BattlefieldMinimapCloseButton:HookScript('OnEnter', function()
		--oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0;
		--BattlefieldMinimap_UpdateOpacity(0)
	--end)
--
	--BattlefieldMinimapCloseButton:HookScript('OnLeave', function()
		--if oldAlpha then
			--BattlefieldMinimap_UpdateOpacity(oldAlpha)
			--oldAlpha = nil;
		--end
	--end)
	]]
end

S:AddCallbackForAddon("Blizzard_BattlefieldMap", "BattlefieldMap", LoadSkin)