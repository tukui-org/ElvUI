local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local After = C_Timer.After

local backdrops = {}
local function SkinFrame(frame)
	frame:StripTextures()

	if backdrops[frame] then
		frame.backdrop = backdrops[frame] -- relink it back
	else
		frame:CreateBackdrop('Transparent') -- :SetTemplate errors out
		frame.backdrop:SetInside(nil, 1, 5)

		backdrops[frame] = frame.backdrop -- keep below CreateBackdrop

		if frame.ScrollBar then
			S:HandleTrimScrollBar(frame.ScrollBar)
		end
	end

	if frame.backdrop then
		frame.backdrop:OffsetFrameLevel(nil, frame)
	end
end

-- 12.0: Blizzard invokes the menu-acquired callback synchronously inside its own
-- secure menu layout/ReinitializeAll execution. Doing frame work (StripTextures,
-- CreateBackdrop, ...) there taints that execution, so Blizzard's own secret-number
-- math later in the same pass -- e.g. min(Infinite, ...) at Menu.lua:967 -- errors
-- with "numeric conversion on a secret number value (execution tainted by 'ElvUI')".
-- Deferring by a frame lets the secure pass finish untainted; the callback itself now
-- only schedules a timer and modifies nothing synchronously.
local function SkinFrameDeferred(frame)
	if not frame then return end

	After(0, function()
		SkinFrame(frame)
	end)
end

function S:SkinMenu(manager, ownerRegion, menuDescription, anchor)
	local menu = manager:GetOpenMenu()
	if not menu then return end

	SkinFrameDeferred(menu) -- Initial context menu
	menuDescription:AddMenuAcquiredCallback(SkinFrameDeferred) -- SubMenus
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
