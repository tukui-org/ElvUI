local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function GetOpacity()
	return 1 - (_G.BattlefieldMapOptions and _G.BattlefieldMapOptions.opacity or 1)
end

local function InitializeOptionsDropDown()
	_G.BattlefieldMapTab:InitializeOptionsDropDown()
end

local function setBackdropAlpha()
	if _G.BattlefieldMapFrame.backdrop then
		_G.BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, GetOpacity())
	end
end

-- alpha stuff
local oldAlpha = 0
local function setOldAlpha()
	if oldAlpha then
		_G.BattlefieldMapFrame:SetGlobalAlpha(oldAlpha)
		oldAlpha = nil
	end
end

local function setRealAlpha()
	oldAlpha = GetOpacity()
	_G.BattlefieldMapFrame:SetGlobalAlpha(1)
end

local function refreshAlpha()
	oldAlpha = GetOpacity()
end

function S:Blizzard_BattlefieldMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgmap) then return end

	local BattlefieldMapFrame = _G.BattlefieldMapFrame
	local BattlefieldMapTab = _G.BattlefieldMapTab

	BattlefieldMapFrame:SetClampedToScreen(true)
	BattlefieldMapFrame:StripTextures()

	refreshAlpha() -- will need this soon
	BattlefieldMapFrame:CreateBackdrop()
	BattlefieldMapFrame:SetFrameStrata('LOW')
	BattlefieldMapFrame.backdrop:SetOutside(BattlefieldMapFrame.ScrollContainer)
	BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, oldAlpha)

	BattlefieldMapFrame:EnableMouse(true)
	BattlefieldMapFrame:SetMovable(true)

	BattlefieldMapFrame.BorderFrame:StripTextures()
	BattlefieldMapFrame.BorderFrame.CloseButton:SetFrameLevel(BattlefieldMapFrame.BorderFrame.CloseButton:GetFrameLevel()+1)
	S:HandleCloseButton(BattlefieldMapFrame.BorderFrame.CloseButton)
	BattlefieldMapTab:Kill()

	BattlefieldMapFrame.ScrollContainer:HookScript('OnMouseUp', function(_, btn)
		if btn == 'LeftButton' then
			BattlefieldMapTab:StopMovingOrSizing()
			if not _G.BattlefieldMapOptions.position then _G.BattlefieldMapOptions.position = {} end
			_G.BattlefieldMapOptions.position.x, _G.BattlefieldMapOptions.position.y = BattlefieldMapTab:GetCenter()
		elseif btn == 'RightButton' then
			_G.UIDropDownMenu_Initialize(BattlefieldMapTab.OptionsDropDown, InitializeOptionsDropDown, 'MENU')
			_G.ToggleDropDownMenu(1, nil, BattlefieldMapTab.OptionsDropDown, BattlefieldMapFrame:GetName(), 0, -4)
		end

		if _G.OpacityFrame:IsShown() then
			_G.OpacityFrame:Hide()
		end
	end)

	BattlefieldMapFrame.ScrollContainer:HookScript('OnMouseDown', function(_, btn)
		if btn == 'LeftButton' and (_G.BattlefieldMapOptions and not _G.BattlefieldMapOptions.locked) then
			BattlefieldMapTab:StartMoving()
		end
	end)

	hooksecurefunc(BattlefieldMapFrame, 'SetGlobalAlpha', setBackdropAlpha)
	hooksecurefunc(BattlefieldMapFrame, 'RefreshAlpha', refreshAlpha)

	BattlefieldMapFrame:HookScript('OnShow', setBackdropAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript('OnLeave', setOldAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript('OnEnter', setRealAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript('OnLeave', setOldAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript('OnEnter', setRealAlpha)
end

S:AddCallbackForAddon('Blizzard_BattlefieldMap')
