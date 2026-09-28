local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function DeathRecapScrollUpdateChild(child)
	local spellInfo = child.SpellInfo
	if spellInfo.IsSkinned then return end

	spellInfo:CreateBackdrop()
	spellInfo.backdrop:SetOutside(spellInfo.Icon)
	spellInfo.Icon:SetTexCoords()
	spellInfo.Icon:SetParent(spellInfo.backdrop)
	spellInfo.IconBorder:Kill()

	spellInfo.IsSkinned = true
end

local function DeathRecapScrollUpdate(frame)
	frame:ForEachFrame(DeathRecapScrollUpdateChild)
end

function S:Blizzard_DeathRecap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.deathRecap) then return end

	local DeathRecapFrame = _G.DeathRecapFrame
	DeathRecapFrame:StripTextures()
	DeathRecapFrame:SetTemplate('Transparent')
	DeathRecapFrame.CloseButton:SetFrameLevel(5)

	S:HandleCloseButton(DeathRecapFrame.CloseXButton)
	S:HandleButton(DeathRecapFrame.CloseButton)

	S:HandleTrimScrollBar(DeathRecapFrame.ScrollBar)
	hooksecurefunc(DeathRecapFrame.ScrollBox, 'Update', DeathRecapScrollUpdate)
end

S:AddCallbackForAddon('Blizzard_DeathRecap')
