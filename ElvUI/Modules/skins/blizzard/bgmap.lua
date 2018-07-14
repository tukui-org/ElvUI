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
-- GLOBALS: BattlefieldMapTab, BattlefieldMapOptions, OpacityFrame
-- GLOBALS: SHOW_BATTLEFIELDMINIMAP_PLAYERS, LOCK_BATTLEFIELDMINIMAP, BATTLEFIELDMINIMAP_OPACITY_LABEL
-- GLOBALS: UIDROPDOWNMENU_MENU_LEVEL, UIParent

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end

	local function GetOpacity()
		return 1 - (BattlefieldMapOptions and BattlefieldMapOptions.opacity or 1)
	end

	local oldAlpha = GetOpacity()

	local BattlefieldMapFrame = _G["BattlefieldMapFrame"]
	BattlefieldMapFrame:SetClampedToScreen(true)
	BattlefieldMapFrame:StripTextures()

	BattlefieldMapFrame:CreateBackdrop('Default')
	BattlefieldMapFrame:SetFrameStrata('LOW')
	BattlefieldMapFrame.backdrop:SetOutside(BattlefieldMapFrame.ScrollContainer)
	BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, oldAlpha)

	BattlefieldMapFrame.backdrop.backdropTexture:SetTexture(nil)
	hooksecurefunc(BattlefieldMapFrame.backdrop.backdropTexture, "SetTexture", function(self, texture)
		if texture ~= nil then self:SetTexture(nil) end
	end)

	BattlefieldMapFrame:EnableMouse(true)
	BattlefieldMapFrame:SetMovable(true)

	BattlefieldMapFrame.BorderFrame:StripTextures()
	BattlefieldMapFrame.BorderFrame.CloseButton:SetFrameLevel(BattlefieldMapFrame.BorderFrame.CloseButton:GetFrameLevel()+1)
	S:HandleCloseButton(BattlefieldMapFrame.BorderFrame.CloseButton)
	BattlefieldMapTab:Kill()

	-- Custom dropdown to avoid using regular DropDownMenu code (taints)
	local function BattlefieldMapTabDropDown_Initialize()
		local info = UIDropDownMenu_CreateInfo();

		-- Show battlefield players
		info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS;
		info.func = function()
			BattlefieldMapOptions.showPlayers = not BattlefieldMapOptions.showPlayers;
			BattlefieldMapFrame:UpdateUnitsVisibility()
		end
		info.checked = BattlefieldMapOptions and BattlefieldMapOptions.showPlayers or false;
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

		-- Battlefield minimap lock
		info.text = LOCK_BATTLEFIELDMINIMAP;
		info.func = function()
			BattlefieldMapOptions.locked = not BattlefieldMapOptions.locked
		end
		info.checked = BattlefieldMapOptions and BattlefieldMapOptions.locked or false;
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

		-- Opacity
		info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL;
		info.func = BattlefieldMapTab.ShowOpacity;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	end

	local ElvUIBattlefieldMapTabDropDown = CreateFrame("Frame", "ElvUIBattlefieldMapTabDropDown", UIParent, "UIDropDownMenuTemplate")
	ElvUIBattlefieldMapTabDropDown:SetID(1)
	ElvUIBattlefieldMapTabDropDown:Hide()
	UIDropDownMenu_Initialize(ElvUIBattlefieldMapTabDropDown, BattlefieldMapTabDropDown_Initialize, "MENU");

	BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			BattlefieldMapTab:StopMovingOrSizing()
			BattlefieldMapTab:SetUserPlaced(true)
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, ElvUIBattlefieldMapTabDropDown, BattlefieldMapFrame:GetName(), 0, -4)
		end
		if OpacityFrame:IsShown() then
			OpacityFrame:Hide()
		end
	end)

	BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" and (BattlefieldMapOptions and not BattlefieldMapOptions.locked) then
			BattlefieldMapTab:StartMoving()
		end
	end)

	local function setBackdropAlpha()
		if BattlefieldMapFrame.backdrop then
			BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, GetOpacity())
		end
	end

	hooksecurefunc(BattlefieldMapFrame, "SetGlobalAlpha", setBackdropAlpha)
	hooksecurefunc(BattlefieldMapFrame, "RefreshAlpha", function()
		oldAlpha = GetOpacity()
	end)

	local function setOldAlpha()
		if oldAlpha then
			BattlefieldMapFrame:SetGlobalAlpha(oldAlpha)
			oldAlpha = nil
		end
	end

	local function setRealAlpha()
		oldAlpha = GetOpacity()
		BattlefieldMapFrame:SetGlobalAlpha(1)
	end

	BattlefieldMapFrame:HookScript('OnShow', setBackdropAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript('OnLeave', setOldAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript('OnEnter', setRealAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript('OnLeave', setOldAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript('OnEnter', setRealAlpha)
end

S:AddCallbackForAddon("Blizzard_BattlefieldMap", "BattlefieldMap", LoadSkin)