local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables
local hooksecurefunc = hooksecurefunc

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIDropDownMenu_Initialize, ToggleDropDownMenu

local function GetOpacity()
	local BattlefieldMapOptions = _G["BattlefieldMapOptions"]
	return 1 - (BattlefieldMapOptions and BattlefieldMapOptions.opacity or 1)
end

local function InitializeOptionsDropDown()
	_G["BattlefieldMapTab"]:InitializeOptionsDropDown()
end

local function setBackdropAlpha()
	local BattlefieldMapFrame = _G["BattlefieldMapFrame"]
	if BattlefieldMapFrame.backdrop then
		BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, GetOpacity())
	end
end

-- alpha stuff
local oldAlpha = 0
local function setOldAlpha()
	if oldAlpha then
		_G["BattlefieldMapFrame"]:SetGlobalAlpha(oldAlpha)
		oldAlpha = nil
	end
end

local function setRealAlpha()
	oldAlpha = GetOpacity()
	_G["BattlefieldMapFrame"]:SetGlobalAlpha(1)
end

local function refreshAlpha()
	oldAlpha = GetOpacity()
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end

	local BattlefieldMapFrame = _G["BattlefieldMapFrame"]
	local BattlefieldMapOptions = _G["BattlefieldMapOptions"]
	local BattlefieldMapTab = _G["BattlefieldMapTab"]
	local OpacityFrame = _G["OpacityFrame"]

	BattlefieldMapFrame:SetClampedToScreen(true)
	BattlefieldMapFrame:StripTextures()

	refreshAlpha() -- will need this soon
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

	BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			BattlefieldMapTab:StopMovingOrSizing()
			BattlefieldMapTab:SetUserPlaced(true)
		elseif btn == "RightButton" then
			UIDropDownMenu_Initialize(BattlefieldMapTab.OptionsDropDown, InitializeOptionsDropDown, "MENU")
			ToggleDropDownMenu(1, nil, BattlefieldMapTab.OptionsDropDown, BattlefieldMapFrame:GetName(), 0, -4)
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

	hooksecurefunc(BattlefieldMapFrame, "SetGlobalAlpha", setBackdropAlpha)
	hooksecurefunc(BattlefieldMapFrame, "RefreshAlpha", refreshAlpha)

	BattlefieldMapFrame:HookScript('OnShow', setBackdropAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript('OnLeave', setOldAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript('OnEnter', setRealAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript('OnLeave', setOldAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript('OnEnter', setRealAlpha)
end

S:AddCallbackForAddon("Blizzard_BattlefieldMap", "BattlefieldMap", LoadSkin)
