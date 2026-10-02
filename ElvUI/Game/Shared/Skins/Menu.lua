local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local data = S:AddCallbackForAddon('Blizzard_Menu', nil, nil, nil, nil, nil, 'misc')

local backdrops = {}
local function SkinFrame(frame)
	frame:StripTextures()

	if backdrops[frame] then
		frame.backdrop = backdrops[frame] -- relink it back
	else
		frame:CreateBackdrop('Transparent') -- :SetTemplate errors out
		frame.backdrop:SetInside(nil, 1, 5)

		backdrops[frame] = frame.backdrop -- keep below CreateBackdrop

		S:HandleTrimScrollBar(frame.ScrollBar)
	end

	frame.backdrop:OffsetFrameLevel(nil, frame)
end

local widgets = {}
local function SkinFrameAttachments(frame)
	if not frame.attachments then return end

	local r, g, b = unpack(E.media.rgbvaluecolor)
	for _, widget in next, frame.attachments do
		if widget:IsObjectType('Texture') then
			if widget:GetTexture() == 130940 then
				widget:SetTexture(E.Media.Textures.ArrowUp)
				widget:SetRotation(S.ArrowRotation.right)
				widget:SetVertexColor(r, g, b)
				widget:Size(12)

				widgets[widget] = true
			elseif widgets[widget] then
				widget:SetRotation(S.ArrowRotation.up)
				widgets[widget] = nil
			end
		end
	end
end

function data:SkinMenu(manager, ownerRegion, menuDescription, anchor)
	local menu = manager:GetOpenMenu()
	if not menu then return end

	SkinFrame(menu) -- Initial context menu
	menuDescription:AddMenuAcquiredCallback(SkinFrame) -- SubMenus
end

function data:OpenMenu(ownerRegion, menuDescription, anchor)
	data:SkinMenu(self, ownerRegion, menuDescription, anchor) -- self is manager (Menu.GetManager)
end

function data:OpenContextMenu(ownerRegion, menuDescription)
	data:SkinMenu(self, ownerRegion, menuDescription) -- self is manager (Menu.GetManager)
end

function S:Blizzard_Menu()
	local manager = _G.Menu.GetManager()
	hooksecurefunc(manager, 'OpenMenu', data.OpenMenu)
	hooksecurefunc(manager, 'OpenContextMenu', data.OpenContextMenu)
	hooksecurefunc(_G.CompositorMixin, 'AttachTexture', SkinFrameAttachments)
end
