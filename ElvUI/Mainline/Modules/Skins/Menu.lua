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
		backdrops[frame] = frame.backdrop

		frame:CreateBackdrop('Transparent') -- :SetTemplate errors out

		if frame.ScrollBar then
			S:HandleTrimScrollBar(frame.ScrollBar)
		end
	end
end

local function OpenMenu(manager)
	local menu = manager:GetOpenMenu()
	if menu then
		SkinFrame(menu)
	end
end

function S:Blizzard_Menu()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local manager = _G.Menu.GetManager()
	hooksecurefunc(manager, 'OpenMenu', OpenMenu)
	hooksecurefunc(manager, 'OpenContextMenu', OpenMenu)
end

S:AddCallbackForAddon('Blizzard_Menu')
