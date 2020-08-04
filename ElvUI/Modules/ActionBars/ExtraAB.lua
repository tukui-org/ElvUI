local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local GetActionCooldown = GetActionCooldown
local HasExtraActionBar = HasExtraActionBar
local hooksecurefunc = hooksecurefunc

local ExtraActionBarHolder, ZoneAbilityHolder

local function FixExtraActionCD(cd)
	local start, duration = GetActionCooldown(cd:GetParent().action)
	E.OnSetCooldown(cd, start, duration)
end

function AB:Extra_SetAlpha()
	if not E.private.actionbar.enable then return; end
	local alpha = E.db.actionbar.extraActionButton.alpha

	for i = 1, _G.ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
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
		ExtraActionBarHolder:Size(_G.ExtraActionBarFrame:GetWidth() * scale)
	end

	if _G.ZoneAbilityFrame then
		_G.ZoneAbilityFrame:SetScale(scale)
		ZoneAbilityHolder:Size(_G.ZoneAbilityFrame:GetWidth() * scale)
	end
end

function AB:SetupExtraButton()
	local ExtraActionBarFrame = _G.ExtraActionBarFrame
	local ExtraAbilityContainer = _G.ExtraAbilityContainer -- 9.0 Shadowlands?
	local ZoneAbilityFrame = _G.ZoneAbilityFrame

	ExtraActionBarHolder = CreateFrame('Frame', nil, E.UIParent)
	ExtraActionBarHolder:SetPoint('BOTTOM', E.UIParent, 'BOTTOM', -1, 293)
	ExtraActionBarHolder:Size(ExtraActionBarFrame:GetSize())

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('CENTER', ExtraActionBarHolder, 'CENTER')
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil

	-- Please check this 9.0 Shadowlands
	ExtraAbilityContainer:SetParent(ExtraActionBarHolder)
	ExtraAbilityContainer:ClearAllPoints()
	ExtraAbilityContainer:SetPoint('CENTER', ExtraActionBarHolder, 'CENTER')
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraAbilityContainer = nil

	ZoneAbilityHolder = CreateFrame('Frame', nil, E.UIParent)
	ZoneAbilityHolder:SetPoint('BOTTOM', E.UIParent, 'BOTTOM', -1, 293)
	ZoneAbilityHolder:Size(ExtraActionBarFrame:GetSize())

	-- Please check this 9.0 Shadowlands
	ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint('CENTER', ZoneAbilityHolder, 'CENTER')
	ZoneAbilityFrame.Style:SetAlpha(0)
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ZoneAbilityFrame = nil

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(button)
		for spellButton in button.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.IsSkinned then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				spellButton:StyleButton(nil, nil, nil, true)
				spellButton:CreateBackdrop()
				spellButton.Icon:SetDrawLayer('ARTWORK')
				spellButton.Icon:SetTexCoord(unpack(E.TexCoords))
				spellButton.Icon:SetInside()

				if spellButton.Cooldown then
					spellButton.Cooldown.CooldownOverride = 'actionbar'
					E:RegisterCooldown(spellButton.Cooldown)
				end

				spellButton.IsSkinned = true
			end
		end
	end)

	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button.noResize = true
			button.pushed = true
			button.checked = true

			self:StyleButton(button, true)
			button:CreateBackdrop()
			button.icon:SetDrawLayer('ARTWORK')

			if E.private.skins.cleanBossButton and button.style then -- Hide the Artwork
				button.style:SetTexture()
				hooksecurefunc(button.style, 'SetTexture', function(btn, tex)
					if tex ~= nil then btn:SetTexture() end
				end)
			end

			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)

			if button.cooldown then
				button.cooldown.CooldownOverride = 'actionbar'
				E:RegisterCooldown(button.cooldown)
				button.cooldown:HookScript("OnShow", FixExtraActionCD)
			end
		end
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show()
		ExtraAbilityContainer:Show()
	end

	E:CreateMover(ExtraActionBarHolder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraActionButton')
	E:CreateMover(ZoneAbilityHolder, 'ZoneAbility', L["Zone Ability"], nil, nil, nil, 'ALL,ACTIONBARS')

	AB:Extra_SetAlpha()
	AB:Extra_SetScale()
end
