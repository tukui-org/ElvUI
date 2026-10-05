local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local CreateFrame = CreateFrame
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

local checkedAtlas = {
	['common-dropdown-icon-checkmark-yellow'] = true,
	['common-dropdown-icon-radialtick-yellow'] = true,
	['common-dropdown-icon-checkmark-yellow-classic'] = true,
	['common-dropdown-icon-checkmark-yellow-classic-2'] = true,
	['common-dropdown-icon-radialtick-yellow-classic'] = true,
}

-- Menu rows are pooled - hide the box when Blizzard releases one
local checkboxes = {}
local function HideCheckbox(compositor)
	local box = checkboxes[compositor.target]
	if box then
		box:Hide()
	end
end

local function SkinCheckbox(_, button)
	local leftTexture1, leftTexture2 = button.leftTexture1, button.leftTexture2
	if not leftTexture1 then return end

	local box = checkboxes[button]
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
		checkboxes[button] = box
	end

	local atlas = (leftTexture2 or leftTexture1):GetAtlas()
	box.mark:SetShown(checkedAtlas[atlas])

	-- Pooled textures
	leftTexture1:SetTexture(E.ClearTexture)
	if leftTexture2 then
		leftTexture2:SetTexture(E.ClearTexture)
	end

	box:ClearAllPoints()
	box:SetPoint('CENTER', leftTexture1)
	box:Show()
end

-- Talent loadout dropdown hides the radio textures in a later init
local function HierarchyCheckbox(button)
	local box = checkboxes[button]
	if box and box:IsShown() and not button.leftTexture1:IsShown() then
		box:Hide()
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
	hooksecurefunc(_G.CompositorMixin, 'Detach', HideCheckbox)
	hooksecurefunc(_G.MenuVariants, 'CreateCheckbox', SkinCheckbox)
	hooksecurefunc(_G.MenuVariants, 'CreateRadio', SkinCheckbox)
	hooksecurefunc(_G.MenuTemplates, 'SetHierarchyEnabled', HierarchyCheckbox)
end
