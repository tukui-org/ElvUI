local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local hooksecurefunc = hooksecurefunc

local function SkinFrame(frame)
	frame:StripTextures()

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent') -- :SetTemplate errors out

		if frame.ScrollBar then
			S:HandleTrimScrollBar(frame.ScrollBar)
		end
	end

	for _, child in next, { frame:GetChildren() } do
		local minLevel = child.MinLevel
		if minLevel and not minLevel.IsSkinned then
			S:HandleExitBox(minLevel)
			minLevel.IsSkinned = true
		end

		local maxLevel = child.MaxLevel
		if maxLevel and not maxLevel.IsSkinned then
			S:HandleExitBox(maxLevel)
			maxLevel.IsSkinned = true
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
