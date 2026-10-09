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
local ATLAS = {
	['common-dropdown-icon-checkmark-yellow'] = true,
	['common-dropdown-icon-radialtick-yellow'] = true,
	['common-dropdown-icon-checkmark-yellow-classic'] = true,
	['common-dropdown-icon-checkmark-yellow-classic-2'] = true,
	['common-dropdown-icon-radialtick-yellow-classic'] = true,
}
local TEMPLATES = {
	UnitPopupVoiceMicrophoneVolumeTemplate = true,
	UnitPopupVoiceSpeakerVolumeTemplate = true,
	UnitPopupVoiceUserVolumeTemplate = true,
}

function data:HandleMenu()
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

function data:HandleAttachments() -- self is compositor
	local objects = self.attachments
	if not objects then return end

	local r, g, b = unpack(E.media.rgbvaluecolor)
	for _, widget in next, objects do
		if widget:IsObjectType('Texture') and (widget:GetTexture() == 130940 and widget:GetRotation() == 0) then
			widget:SetTexture(E.Media.Textures.ArrowUp)
			widget:SetRotation(S.ArrowRotation.right)
			widget:SetVertexColor(r, g, b)
			widget:Size(12)
		end
	end
end

-- Voice chat volume sliders
function data:HandleTemplate(_, template) -- self is compositor
	local objects = self.attachments
	if not objects then return end

	local widget = TEMPLATES[template] and objects[#objects]
	if widget and not widget.IsSkinned then
		S:HandleSliderFrame(widget.Slider)

		widget.IsSkinned = true
	end
end

-- Menu rows are pooled - hide the box when Blizzard releases one
function data:HideCheckbox() -- self is compositor
	local box = CHECKBOXES[self.target]
	if box then
		box:Hide()
	end
end

function data:HandleCheckbox(button)
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

	data.HandleMenu(menu) -- Initial context menu

	menuDescription:AddMenuAcquiredCallback(data.HandleMenu) -- SubMenus
end

function data:OpenMenu(ownerRegion, menuDescription, anchor)
	data:SkinMenu(self, ownerRegion, menuDescription, anchor) -- self is manager: Menu.GetManager
end

function data:OpenContext(ownerRegion, menuDescription)
	data:SkinMenu(self, ownerRegion, menuDescription) -- self is manager: Menu.GetManager
end

function S:Blizzard_Menu()
	local manager = _G.Menu.GetManager()
	hooksecurefunc(manager, 'OpenMenu', data.OpenMenu)
	hooksecurefunc(manager, 'OpenContextMenu', data.OpenContext)

	hooksecurefunc(_G.CompositorMixin, 'AttachTexture', data.HandleAttachments)
	hooksecurefunc(_G.CompositorMixin, 'AttachTemplate', data.HandleTemplate)
	hooksecurefunc(_G.CompositorMixin, 'Detach', data.HideCheckbox)

	hooksecurefunc(_G.MenuVariants, 'CreateCheckbox', data.HandleCheckbox)
	hooksecurefunc(_G.MenuVariants, 'CreateRadio', data.HandleCheckbox)

	hooksecurefunc(_G.MenuTemplates, 'SetHierarchyEnabled', data.HierarchyCheckbox)
end
