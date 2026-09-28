local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetBackdropAlpha(frame)
	frame.backdrop:SetBackdropColor(0, 0, 0, 1 - _G.BattlefieldMapOptions.opacity)
end

local function OnLeave()
	_G.BattlefieldMapFrame.BorderFrame.CloseButton:SetAlpha(0.1)
end

local function OnEnter()
	_G.BattlefieldMapFrame.BorderFrame.CloseButton:SetAlpha(1)
end

function S:Blizzard_BattlefieldMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgmap) then return end

	local frame = _G.BattlefieldMapFrame
	frame:StripTextures()
	frame:CreateBackdrop()
	frame.backdrop:SetOutside(frame.ScrollContainer)
	frame:SetFrameStrata('LOW')
	frame:HookScript('OnShow', SetBackdropAlpha)
	hooksecurefunc(frame, 'SetGlobalAlpha', SetBackdropAlpha)

	frame.ScrollContainer:HookScript('OnLeave', OnLeave)
	frame.ScrollContainer:HookScript('OnEnter', OnEnter)

	local tab = _G.BattlefieldMapTab
	tab:SetHeight(24)
	tab:StripTextures()
	tab:CreateBackdrop()
	tab.Text:SetInside(tab)

	local close = frame.BorderFrame.CloseButton
	S:HandleCloseButton(close)
	close:SetAlpha(0.25)
	close:SetIgnoreParentAlpha(1)
	close:OffsetFrameLevel(1)
	close:ClearAllPoints()
	close:Point('TOPRIGHT', 3, 5)
	close:HookScript('OnLeave', OnLeave)
	close:HookScript('OnEnter', OnEnter)
end

S:AddCallbackForAddon('Blizzard_BattlefieldMap')
