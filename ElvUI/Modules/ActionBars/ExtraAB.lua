local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')
local S = E:GetModule('Skins')

local _G = _G
local tinsert = tinsert
local unpack, pairs = unpack, pairs
local GetBindingKey = GetBindingKey
local CreateFrame = CreateFrame
local HasExtraActionBar = HasExtraActionBar
local hooksecurefunc = hooksecurefunc

local ExtraActionBarHolder, ZoneAbilityHolder
local ExtraButtons = {}

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

local function ZoneContainerScale(scale)
	if not scale then scale = E.db.actionbar.extraActionButton.scale end

	local zoneContainer = _G.ZoneAbilityFrame and _G.ZoneAbilityFrame.SpellButtonContainer
	if zoneContainer then
		zoneContainer:SetScale(scale)

		local width, height = zoneContainer:GetSize()
		ZoneAbilityHolder:SetSize(width * scale, height * scale)
	end
end

function AB:Extra_SetScale()
	if not E.private.actionbar.enable then return end
	local scale = E.db.actionbar.extraActionButton.scale

	ZoneContainerScale(scale)

	if _G.ExtraActionBarFrame then
		_G.ExtraActionBarFrame:SetScale(scale)

		local width, height = _G.ExtraActionBarFrame.button:GetSize()
		ExtraActionBarHolder:SetSize(width * scale, height * scale)
	end
end

function AB:SetupExtraButton()
	local ExtraActionBarFrame = _G.ExtraActionBarFrame
	local ZoneAbilityFrame = _G.ZoneAbilityFrame

	ExtraActionBarHolder = CreateFrame('Frame', nil, E.UIParent)
	ExtraActionBarHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', -200, 300)

	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint('TOPLEFT', ExtraActionBarHolder, 'TOPLEFT', E.Spacing, -E.Spacing)
	ExtraActionBarFrame:SetPoint('BOTTOMRIGHT', ExtraActionBarHolder, 'BOTTOMRIGHT', -E.Spacing, E.Spacing)
	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil

	ZoneAbilityHolder = CreateFrame('Frame', nil, E.UIParent)
	ZoneAbilityHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 200, 300)

	-- Please check this 9.0 Shadowlands
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint('TOPLEFT', ZoneAbilityHolder, 'TOPLEFT', E.Border, -E.Border)
	ZoneAbilityFrame:SetPoint('BOTTOMRIGHT', ZoneAbilityHolder, 'BOTTOMRIGHT', -E.Border, E.Border)
	ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.ZoneAbilityFrame = nil

	hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(button)
		ZoneContainerScale()

		if E.private.skins.cleanZoneButton then
			ZoneAbilityFrame.Style:SetAlpha(0)
		else
			ZoneAbilityFrame.Style:SetAlpha(1)
		end

		for spellButton in button.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.IsSkinned then
				spellButton.NormalTexture:SetAlpha(0)
				spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				spellButton:StyleButton(nil, true)
				spellButton:CreateBackdrop()
				spellButton.backdrop:SetAllPoints()
				spellButton.Icon:SetDrawLayer('ARTWORK')
				spellButton.Icon:SetTexCoord(unpack(E.TexCoords))
				spellButton.Icon:SetInside()

				--check these
				--spellButton.HotKey:SetText(GetBindingKey(spellButton:GetName()))
				--tinsert(ExtraButtons, spellButton)

				if spellButton.Cooldown then
					spellButton.Cooldown.CooldownOverride = 'actionbar'
					E:RegisterCooldown(spellButton.Cooldown)
				end

				spellButton.IsSkinned = true
			end
		end
	end)

	-- Sometimes the ZoneButtons anchor it to the ExtraAbilityContainer, we dont want this.
	hooksecurefunc(ZoneAbilityFrame, 'SetParent', function(frame, parent)
		if parent ~= ZoneAbilityHolder then
			frame:SetParent(ZoneAbilityHolder)
		end
	end)

	-- Also track the parent for the Boss Button
	hooksecurefunc(ExtraActionBarFrame, 'SetParent', function(frame, parent)
		if parent ~= ExtraActionBarHolder then
			frame:SetParent(ExtraActionBarHolder)
		end
	end)

	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G['ExtraActionButton'..i]
		if button then
			button.pushed = true
			button.checked = true

			self:StyleButton(button, true) -- registers cooldown too
			button.icon:SetDrawLayer('ARTWORK')
			button:CreateBackdrop()
			button.backdrop:SetAllPoints()

			if E.private.skins.cleanBossButton and button.style then -- Hide the Artwork
				button.style:SetTexture()
				hooksecurefunc(button.style, 'SetTexture', stripStyle)
			end

			local tex = button:CreateTexture(nil, 'OVERLAY')
			tex:SetColorTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)

			button.HotKey:SetText(GetBindingKey('ExtraActionButton'..i))
			tinsert(ExtraButtons, button)
		end
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show()
	end

	AB:Extra_SetAlpha()
	AB:Extra_SetScale()

	E:CreateMover(ExtraActionBarHolder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraActionButton')
	E:CreateMover(ZoneAbilityHolder, 'ZoneAbility', L["Zone Ability"], nil, nil, nil, 'ALL,ACTIONBARS')
end

function AB:UpdateExtraBindings()
	for _, button in pairs(ExtraButtons) do
		button.HotKey:SetText(_G.GetBindingKey(button:GetName()))
		AB:FixKeybindText(button)
	end
end
