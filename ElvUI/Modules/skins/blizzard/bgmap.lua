local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end
	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()
	BattlefieldMinimapTabLeft:Kill()
	BattlefieldMinimapTabMiddle:Kill()
	BattlefieldMinimapTabRight:Kill()

	BattlefieldMinimap:CreateBackdrop('Default')
	BattlefieldMinimap.backdrop:Point('BOTTOMRIGHT', -4, 2)
	BattlefieldMinimap:SetFrameStrata('LOW')
	BattlefieldMinimapCloseButton:ClearAllPoints()
	BattlefieldMinimapCloseButton:Point("TOPRIGHT", -4, 0)
	S:HandleCloseButton(BattlefieldMinimapCloseButton)
	BattlefieldMinimapCloseButton.text:ClearAllPoints()
	BattlefieldMinimapCloseButton.text:Point('CENTER', BattlefieldMinimapCloseButton, 'CENTER', 0, 1)
	BattlefieldMinimapCloseButton:SetFrameStrata('MEDIUM')

	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)

	--Custom dropdown to avoid using regular DropDownMenu code (taints)
	local function BattlefieldMinimapTabDropDown_Initialize()
		local info = L_UIDropDownMenu_CreateInfo();

		-- Show battlefield players
		info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS;
		info.func = BattlefieldMinimapTabDropDown_TogglePlayers;
		info.checked = BattlefieldMinimapOptions and BattlefieldMinimapOptions.showPlayers or false;
		info.isNotRadio = true;
		L_UIDropDownMenu_AddButton(info, L_UIDROPDOWNMENU_MENU_LEVEL);

		-- Battlefield minimap lock
		info.text = LOCK_BATTLEFIELDMINIMAP;
		info.func = BattlefieldMinimapTabDropDown_ToggleLock;
		info.checked = BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked or false;
		info.isNotRadio = true;
		L_UIDropDownMenu_AddButton(info, L_UIDROPDOWNMENU_MENU_LEVEL);

		-- Opacity
		info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL;
		info.func = BattlefieldMinimapTabDropDown_ShowOpacity;
		info.notCheckable = true;
		L_UIDropDownMenu_AddButton(info, L_UIDROPDOWNMENU_MENU_LEVEL);
	end
	local ElvUIBattlefieldMinimapTabDropDown = CreateFrame("Frame", "ElvUIBattlefieldMinimapTabDropDown", UIParent, "L_UIDropDownMenuTemplate")
	ElvUIBattlefieldMinimapTabDropDown:SetID(1)
	ElvUIBattlefieldMinimapTabDropDown:Hide()
	L_UIDropDownMenu_Initialize(ElvUIBattlefieldMinimapTabDropDown, BattlefieldMinimapTabDropDown_Initialize, "MENU");

	BattlefieldMinimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			BattlefieldMinimapTab:StopMovingOrSizing()
			BattlefieldMinimapTab:SetUserPlaced(true)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		elseif btn == "RightButton" then
			L_ToggleDropDownMenu(1, nil, ElvUIBattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		end
	end)

	BattlefieldMinimap:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" and (BattlefieldMinimapOptions and not BattlefieldMinimapOptions.locked) then
			BattlefieldMinimapTab:StartMoving()
		end
	end)


	hooksecurefunc('BattlefieldMinimap_UpdateOpacity', function(opacity)
		local alpha = 1.0 - (BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0);
		BattlefieldMinimap.backdrop:SetAlpha(alpha)
	end)

	local oldAlpha
	BattlefieldMinimap:HookScript('OnEnter', function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0;
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimap:HookScript('OnLeave', function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil;
		end
	end)

	BattlefieldMinimapCloseButton:HookScript('OnEnter', function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0;
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimapCloseButton:HookScript('OnLeave', function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil;
		end
	end)

end

S:AddCallbackForAddon("Blizzard_BattlefieldMinimap", "BattlefieldMinimap", LoadSkin)