local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetBackdropAlpha()
	if _G.BattlefieldMapFrame.backdrop then
		local opacity = 1 - (_G.BattlefieldMapOptions and _G.BattlefieldMapOptions.opacity or 1)
		_G.BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, opacity)
	end
end

local function OnLeave()
	_G.BattlefieldMapFrame.BorderFrame.CloseButton:SetAlpha(0.1)
end

local function OnEnter()
	_G.BattlefieldMapFrame.BorderFrame.CloseButton:SetAlpha(1)
end

local function OnMouseUp(_, btn)
	local tab = _G.BattlefieldMapTab
	if btn == 'LeftButton' then
		tab:StopMovingOrSizing()
	elseif btn == 'RightButton' then
		tab:Click('RightButton')
	end

	local slider = _G.OpacityFrame
	if slider and slider:IsShown() then
		slider:Hide()
	end
end

local function OnMouseDown(_, btn)
	local tab = _G.BattlefieldMapTab
	if btn == 'LeftButton' and (_G.BattlefieldMapOptions and not _G.BattlefieldMapOptions.locked) then
		tab:StartMoving()
	end
end

function S:Blizzard_BattlefieldMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgmap) then return end

	local frame = _G.BattlefieldMapFrame
	frame:StripTextures()
	frame:CreateBackdrop()
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata('LOW')

	local tab = _G.BattlefieldMapTab
	tab:SetHeight(24)
	tab:StripTextures()
	tab:CreateBackdrop()

	tab.Text:SetInside(tab)

	local border = frame.BorderFrame
	border:StripTextures()

	local close = border.CloseButton
	close:SetAlpha(0.1)
	close:SetIgnoreParentAlpha(1)
	close:SetFrameLevel(close:GetFrameLevel() + 1)
	close:ClearAllPoints()
	close:Point('TOPRIGHT', 3, 8)
	S:HandleCloseButton(close)

	hooksecurefunc(frame, 'SetGlobalAlpha', SetBackdropAlpha)
	frame:HookScript('OnShow', SetBackdropAlpha)

	local scroll = frame.ScrollContainer
	scroll:HookScript('OnMouseUp', OnMouseUp)
	scroll:HookScript('OnMouseDown', OnMouseDown)
	scroll:HookScript('OnLeave', OnLeave)
	scroll:HookScript('OnEnter', OnEnter)
	frame.backdrop:SetOutside(scroll)

	close:HookScript('OnLeave', OnLeave)
	close:HookScript('OnEnter', OnEnter)
end

S:AddCallbackForAddon('Blizzard_BattlefieldMap')
