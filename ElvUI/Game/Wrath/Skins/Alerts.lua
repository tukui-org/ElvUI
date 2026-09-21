local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame

local function ForceAlpha(frame, alpha, forced)
	if alpha ~= 1 and forced ~= true then
		frame:SetAlpha(1, true)
	end
end

local function SkinAchievementAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame.Background, 'TOPLEFT', -2, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame.Background, 'BOTTOMRIGHT', -2, 6)
	end

	-- Background
	frame.Background:SetTexture()
	frame.glow:Kill()
	frame.shine:Kill()
	frame.GuildBanner:Kill()
	frame.GuildBorder:Kill()

	-- Text
	frame.Unlocked:FontTemplate(nil, 12)
	frame.Unlocked:SetTextColor(1, 1, 1)
	frame.Name:FontTemplate(nil, 12)

	local icon = frame.Icon
	icon.Overlay:Kill()

	local texture = icon.Texture
	texture:SetTexCoords()
	texture:ClearAllPoints()
	texture:Point('LEFT', frame, 7, 0)

	if not icon.backdrop then
		icon:CreateBackdrop()
		icon.backdrop:SetOutside(texture)
	end
end

local function SkinStorePurchaseAlert(frame)
	frame:SetAlpha(1)

	if not frame.hooked then
		hooksecurefunc(frame, 'SetAlpha', ForceAlpha)
		frame.hooked = true
	end

	if not frame.backdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:Point('TOPLEFT', frame, 'TOPLEFT', -2, -6)
		frame.backdrop:Point('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -2, 6)
	end

	local _, ring = frame:GetRegions() -- the CheckButtonGlow ring is only named Border
	ring:Kill()

	frame.Background:Kill()
	frame.glow:Kill()
	frame.shine:Kill()

	frame.Icon:SetTexCoords()
	frame.Icon:SetDrawLayer('BORDER', 5)

	-- Icon border
	if not frame.Icon.b then
		frame.Icon.b = CreateFrame('Frame', nil, frame)
		frame.Icon.b:SetTemplate()
		frame.Icon.b:SetOutside(frame.Icon)
		frame.Icon:SetParent(frame.Icon.b)
	end
end

function S:AlertSystem()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.alertframes) then return end

	-- AlertFrame only registers ACHIEVEMENT_EARNED and STORE_PRODUCT_DELIVERED on wrath
	hooksecurefunc(_G.AchievementAlertSystem, 'setUpFunction', SkinAchievementAlert)
	hooksecurefunc(_G.StorePurchaseAlertSystem, 'setUpFunction', SkinStorePurchaseAlert)
end

S:AddCallback('AlertSystem')
