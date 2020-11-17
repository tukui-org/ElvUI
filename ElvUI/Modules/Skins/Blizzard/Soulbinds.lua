local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

-- Credits: siweia - Aurora Classic

local function SkinConduitList(frame)
	local header = frame.CategoryButton.Container
	if not header.styled then
		header:DisableDrawLayer('BACKGROUND')
		header:CreateBackdrop('Transparent')
		header.backdrop:Point('TOPLEFT', 2, 0)
		header.backdrop:Point('BOTTOMRIGHT', 15, 0)
		header.backdrop:SetBackdropColor(1, 0, 0, .35)

		header.styled = true
	end

	for button in frame.pool:EnumerateActive() do
		if not button.styled then
			for _, element in ipairs(button.Hovers) do
				element:SetColorTexture(1, 1, 1, .25)
			end
			button.PendingBackground:SetColorTexture(1, .8, 0, .25)
			button.Spec.IconOverlay:Hide()
			S:HandleIcon(button.Spec.Icon)

			button.styled = true
		end
	end
end

function S:Blizzard_Soulbinds()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.soulbinds) then return end

	local frame = _G.SoulbindViewer
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.CommitConduitsButton)
	frame.CommitConduitsButton:SetFrameLevel(10)
	S:HandleButton(frame.ActivateSoulbindButton)
	frame.ActivateSoulbindButton:SetFrameLevel(10)
	frame.ConduitList.BottomShadowContainer.BottomShadow:SetAlpha(0)

	local scrollBox = frame.ConduitList.ScrollBox
	for i = 1, 3 do
		hooksecurefunc(scrollBox.ScrollTarget.Lists[i], 'UpdateLayout', SkinConduitList)
	end
end

S:AddCallbackForAddon('Blizzard_Soulbinds')

-- ToDo: Find a way to skin me :thinking:
function S:Blizzard_LandingSoulbinds()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.soulbinds) then return end

	hooksecurefunc(_G.LandingPageSoulbindButtonMixin, 'SetSoulbind', function(button, soulbindData)
		if not button.IsSkinned then
			button:StyleButton()

			button.IsSkinned = true
		end
	end)
end

--S:AddCallbackForAddon('Blizzard_LandingSoulbinds')
