local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local backdrops = {}
local function SkinFrame(frame)
	frame:StripTextures()

	if backdrops[frame] then
		frame.backdrop = backdrops[frame] -- relink it back
	else
		frame:CreateBackdrop('Transparent') -- :SetTemplate errors out
		backdrops[frame] = frame.backdrop -- keep below CreateBackdrop

		if frame.ScrollBar then
			S:HandleTrimScrollBar(frame.ScrollBar)
		end
	end

	if frame.backdrop then
		frame.backdrop:OffsetFrameLevel(nil, frame)

		if E:NoSecretValues(frame) then
			frame.backdrop:NudgePoint(nil, 8, nil, 'BOTTOMRIGHT')
		end
	end
end

function S:SkinMenu(manager, ownerRegion, menuDescription, anchor)
	local menu = manager:GetOpenMenu()
	if not menu then return end

	SkinFrame(menu) -- Initial context menu
	menuDescription:AddMenuAcquiredCallback(SkinFrame) -- SubMenus
end

function S:OpenMenu(ownerRegion, menuDescription, anchor)
	S:SkinMenu(self, ownerRegion, menuDescription, anchor) -- self is manager (Menu.GetManager)
end

function S:OpenContextMenu(ownerRegion, menuDescription)
	S:SkinMenu(self, ownerRegion, menuDescription) -- self is manager (Menu.GetManager)
end

function S:Blizzard_Menu()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local manager = _G.Menu.GetManager()
	if manager then
		hooksecurefunc(manager, 'OpenMenu', S.OpenMenu)
		hooksecurefunc(manager, 'OpenContextMenu', S.OpenContextMenu)
	end
end

S:AddCallbackForAddon('Blizzard_Menu')
