local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local HasExtraActionBar = HasExtraActionBar
local hooksecurefunc = hooksecurefunc

local ExtraActionBarHolder, ZoneAbilityHolder

local function stripStyle(btn, tex)
	if tex ~= nil then
		btn:SetTexture()
	end
end

function AB:Extra_SetAlpha()
	if not E.private.actionbar.enable then return; end
	local alpha = E.db.actionbar.extraActionButton.alpha

	for i = 1, _G.ExtraActionBarFrame:GetNumChildren() do
		local button = _G['ExtraActionButton'..i]
		if button then
			button:SetAlpha(alpha)
		end
	end

	local button = _G.ZoneAbilityFrame.SpellButton
	if button then
		button:SetAlpha(alpha)
	end
end

function AB:Extra_SetScale()
	if not E.private.actionbar.enable then return; end
	local scale = E.db.actionbar.extraActionButton.scale

	if _G.ExtraActionBarFrame then
		_G.ExtraActionBarFrame:SetScale(scale)

		local size = _G.ExtraActionBarFrame:GetWidth() * scale
		ExtraActionBarHolder:SetSize(size, size)
	end

	if _G.ZoneAbilityFrame then
		_G.ZoneAbilityFrame:SetScale(scale)

		local size = _G.ZoneAbilityFrame:GetWidth() * scale
		ZoneAbilityHolder:SetSize(size, size)
	end
end

function AB:SetupExtraButton()
	local ExtraActionBarFrame = _G.ExtraActionBarFrame
	local ZoneAbilityFrame = _G.ZoneAbilityFrame

	ExtraActionBarHolder = CreateFrame('Frame', nil, E.UIParent)
	ExtraActionBarHolder:SetPoint('BOTTOM', E.UIParent, 'BOTTOM', -1, 293)
	ExtraActionBarHolder:SetSize(ExtraActionBarFrame:GetSize())

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', ExtraActionBarHolder, 'CENTER')
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil

	ZoneAbilityHolder = CreateFrame('Frame', nil, E.UIParent)
	ZoneAbilityHolder:SetPoint('BOTTOM', E.UIParent, 'BOTTOM', -1, 293)
	ZoneAbilityHolder:SetSize(ExtraActionBarFrame:GetSize())

	ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint('CENTER', ZoneAbilityHolder, 'CENTER')
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ZoneAbilityFrame = nil

	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G['ExtraActionButton'..i]
		if button then
			button.pushed = true
			button.checked = true

			self:StyleButton(button, true) -- registers cooldown too
			button.icon:SetDrawLayer('ARTWORK')
			button:SetTemplate()

			if E.private.skins.cleanBossButton and button.style then -- Hide the Artwork
				button.style:SetTexture()
				hooksecurefunc(button.style, 'SetTexture', stripStyle)
			end

			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)
		end
	end

	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetNormalTexture('')
		button:StyleButton()
		button:SetTemplate()
		button.Icon:SetDrawLayer('ARTWORK')
		button.Icon:SetTexCoord(unpack(E.TexCoords))
		button.Icon:SetInside()

		if E.private.skins.cleanBossButton and button.Style then -- Hide the Artwork
			button.Style:SetTexture()
			hooksecurefunc(button.Style, 'SetTexture', stripStyle)
		end

		if button.Cooldown then
			button.Cooldown.CooldownOverride = 'actionbar'
			E:RegisterCooldown(button.Cooldown)
		end
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show()
	end

	E:CreateMover(ExtraActionBarHolder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraActionButton')
	E:CreateMover(ZoneAbilityHolder, 'ZoneAbility', L["Zone Ability"], nil, nil, nil, 'ALL,ACTIONBARS')

	AB:Extra_SetAlpha()
	AB:Extra_SetScale()
end
