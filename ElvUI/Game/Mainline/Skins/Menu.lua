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

local function SkinFrameAttachments(frame)
	if not frame.attachments then return end
	local r, g, b = unpack(E.media.rgbvaluecolor)

	for _, widget in ipairs(frame.attachments) do
		local widgetType = widget:GetObjectType()
		if widgetType == 'Texture' then
			if widget:GetTexture() == 130940 then
				widget:SetTexture(E.Media.Textures.ArrowUp)
				widget:SetVertexColor(r, g, b, 1)
				widget:SetRotation(S.ArrowRotation.right)
				widget:Size(12)
			end
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

	hooksecurefunc(CompositorMixin, 'AttachTexture', SkinFrameAttachments)
end

S:AddCallbackForAddon('Blizzard_Menu')
