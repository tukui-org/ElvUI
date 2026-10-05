local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local data = S:AddCallbackForAddon('Blizzard_Menu', nil, nil, nil, nil, nil, 'misc')

local CHECKBOXES = {}
local BACKDROPS = {}
local WIDGETS = {}
local ATLAS = {
	['common-dropdown-icon-checkmark-yellow'] = true,
	['common-dropdown-icon-radialtick-yellow'] = true,
	['common-dropdown-icon-checkmark-yellow-classic'] = true,
	['common-dropdown-icon-checkmark-yellow-classic-2'] = true,
	['common-dropdown-icon-radialtick-yellow-classic'] = true,
}

function data:SkinFrame()
	self:StripTextures()

	if BACKDROPS[self] then
		self.backdrop = BACKDROPS[self] -- relink it back
	else
		self:CreateBackdrop('Transparent') -- :SetTemplate errors out
		self.backdrop:SetInside(nil, 1, 5)

		BACKDROPS[self] = self.backdrop -- keep below CreateBackdrop

		S:HandleTrimScrollBar(self.ScrollBar)
	end

	self.backdrop:OffsetFrameLevel(nil, self)
end

function data:SkinFrameAttachments()
	local objects = self.attachments
	if not objects then return end

	local r, g, b = unpack(E.media.rgbvaluecolor)
	for _, widget in next, objects do
		if widget:IsObjectType('Texture') then
			if widget:GetTexture() == 130940 then
				WIDGETS[widget] = widget:GetRotation()

				widget:SetTexture(E.Media.Textures.ArrowUp)
				widget:SetRotation(S.ArrowRotation.right)
				widget:SetVertexColor(r, g, b)
				widget:Size(12)
			else
				local rotation = WIDGETS[widget]
				if rotation then
					widget:SetRotation(rotation)

					WIDGETS[widget] = nil
				end
			end
		end
	end
end

-- Menu rows are pooled - hide the box when Blizzard releases one
function data:HideCheckbox()
	local box = CHECKBOXES[self.target]
	if box then
		box:Hide()
	end
end

function data:SkinCheckbox(button)
	local tex1, tex2 = button.leftTexture1, button.leftTexture2
	if not tex1 then return end

	local box = CHECKBOXES[button]
	if not box then
		box = CreateFrame('Frame', nil, button)
		box:Size(12)
		box:SetTemplate()

		local r, g, b = unpack(E.media.rgbvaluecolor)
		local mark = box:CreateTexture(nil, 'ARTWORK')
		mark:SetTexture(E.media.normTex)
		mark:SetVertexColor(r, g, b)
		mark:SetInside()

		box.mark = mark
		CHECKBOXES[button] = box
	end

	local mainTex = tex2 or tex1
	local atlas = mainTex:GetAtlas()
	box.mark:SetShown(ATLAS[atlas])

	-- Pooled textures
	tex1:SetTexture(E.ClearTexture)

	if tex2 then
		tex2:SetTexture(E.ClearTexture)
	end

	box:ClearAllPoints()
	box:SetPoint('CENTER', tex1)
	box:Show()
end

-- Talent loadout dropdown hides the radio textures in a later init
function data:HierarchyCheckbox()
	local box = CHECKBOXES[self]
	if box and box:IsShown() and not self.leftTexture1:IsShown() then
		box:Hide()
	end
end

function data:SkinMenu(manager, ownerRegion, menuDescription, anchor)
	local menu = manager:GetOpenMenu()
	if not menu then return end

	data.SkinFrame(menu) -- Initial context menu
	menuDescription:AddMenuAcquiredCallback(data.SkinFrame) -- SubMenus
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

	hooksecurefunc(_G.CompositorMixin, 'AttachTexture', data.SkinFrameAttachments)
	hooksecurefunc(_G.CompositorMixin, 'Detach', data.HideCheckbox)

	hooksecurefunc(_G.MenuVariants, 'CreateCheckbox', data.SkinCheckbox)
	hooksecurefunc(_G.MenuVariants, 'CreateRadio', data.SkinCheckbox)

	hooksecurefunc(_G.MenuTemplates, 'SetHierarchyEnabled', data.HierarchyCheckbox)
end
