local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

--[[
	This Skin file handle the "new" Dropdown Menu. Its in:

	Interface\AddOns\Blizzard_Menu\Menu.lua
]]

function S:Blizzard_Menu()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end

	local MenuManagerProxy = Menu.GetManager()

	local IsSkinned
	hooksecurefunc(MenuManagerProxy, 'OpenMenu', function()
		local MenuFrame = MenuManagerProxy:GetOpenMenu()
		if MenuFrame then
			MenuFrame:StripTextures()

			if not IsSkinned then
				MenuFrame:CreateBackdrop('Transparent') -- :SetTemplate errors out

				if MenuFrame.ScrollBar then
					S:HandleTrimScrollBar(MenuFrame.ScrollBar)
				end
				IsSkinned = true
			end

			for i = 1, MenuFrame:GetNumChildren() do
				local child = select(i, MenuFrame:GetChildren())

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
	end)
end

S:AddCallbackForAddon('Blizzard_Menu')
