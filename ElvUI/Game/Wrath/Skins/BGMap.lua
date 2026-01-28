local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetBackdropAlpha()
	local frame = _G.BattlefieldMapFrame
	if frame and frame.backdrop then
		local options = _G.BattlefieldMapOptions
		local opacity = 1 - (options and options.opacity or 1)
		frame.backdrop:SetBackdropColor(0, 0, 0, opacity)
	end
end

local function GetCloseButton(frame)
	if not frame then
		frame = _G.BattlefieldMapFrame
	end

	local border = frame and frame.BorderFrame
	return border and border.CloseButton
end

local function OnLeave()
	local close = GetCloseButton()
	if close then
		close:SetAlpha(0.1)
	end
end

local function OnEnter()
	local close = GetCloseButton()
	if close then
		close:SetAlpha(1)
	end
end

function S:Blizzard_BattlefieldMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgmap) then return end

	local frame = _G.BattlefieldMapFrame
	frame:StripTextures()
	frame:CreateBackdrop()
	frame:SetFrameStrata('LOW')
	frame:HookScript('OnShow', SetBackdropAlpha)
	hooksecurefunc(frame, 'SetGlobalAlpha', SetBackdropAlpha)

	local scroll = frame.ScrollContainer
	if scroll then
		if frame.backdrop then
			frame.backdrop:SetOutside(scroll)
		end

		scroll:HookScript('OnLeave', OnLeave)
		scroll:HookScript('OnEnter', OnEnter)
	end

	local tab = _G.BattlefieldMapTab
	if tab then
		tab:SetHeight(24)
		tab:StripTextures()
		tab:CreateBackdrop()

		if tab.Text then
			tab.Text:SetInside(tab)
		end
	end

	local close = GetCloseButton(frame)
	if close then
		S:HandleCloseButton(close)

		close:SetAlpha(0.25)
		close:SetIgnoreParentAlpha(1)
		close:OffsetFrameLevel(1)
		close:ClearAllPoints()
		close:Point('TOPRIGHT', 3, 5)
		close:HookScript('OnLeave', OnLeave)
		close:HookScript('OnEnter', OnEnter)
	end
end

S:AddCallbackForAddon('Blizzard_BattlefieldMap')
