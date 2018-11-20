local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local GetActionCooldown = GetActionCooldown
local HasExtraActionBar = HasExtraActionBar

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ExtraActionBarFrame, ZoneAbilityFrame

local ExtraActionBarHolder, ZoneAbilityHolder

local function FixExtraActionCD(cd)
	local start, duration = GetActionCooldown(cd:GetParent().action)
	E.OnSetCooldown(cd, start, duration, 0, 0)
end

function AB:Extra_SetAlpha()
	if not E.private.actionbar.enable then return; end
	local alpha = E.db.actionbar.extraActionButton.alpha

	for i=1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button:SetAlpha(alpha)
		end
	end

	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetAlpha(alpha)
	end
end

function AB:Extra_SetScale()
	if not E.private.actionbar.enable then return; end
	local scale = E.db.actionbar.extraActionButton.scale

	if ExtraActionBarFrame then
		ExtraActionBarFrame:SetScale(scale)
		ExtraActionBarHolder:Size(ExtraActionBarFrame:GetWidth() * scale)
	end

	if ZoneAbilityFrame then
		ZoneAbilityFrame:SetScale(scale)
		ZoneAbilityHolder:Size(ZoneAbilityFrame:GetWidth() * scale)
	end
end

function AB:SetupExtraButton()
	ExtraActionBarHolder = CreateFrame('Frame', nil, E.UIParent)
	ExtraActionBarHolder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 150)
	ExtraActionBarHolder:Size(ExtraActionBarFrame:GetSize())

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:Point('CENTER', ExtraActionBarHolder, 'CENTER')
	ExtraActionBarFrame.ignoreFramePositionManager  = true

	ZoneAbilityHolder = CreateFrame('Frame', nil, E.UIParent)
	ZoneAbilityHolder:Point('BOTTOM', ExtraActionBarFrame, 'TOP', 0, 2)
	ZoneAbilityHolder:Size(ExtraActionBarFrame:GetSize())

	ZoneAbilityFrame:SetParent(ZoneAbilityHolder)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:Point('CENTER', ZoneAbilityHolder, 'CENTER')
	ZoneAbilityFrame.ignoreFramePositionManager = true

	for i=1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button.noResize = true;
			button.pushed = true
			button.checked = true

			self:StyleButton(button, true)
			button:SetTemplate()
			_G["ExtraActionButton"..i..'Icon']:SetDrawLayer('ARTWORK')
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

	local button = ZoneAbilityFrame.SpellButton
	if button then
		button:SetNormalTexture('')
		button:StyleButton(nil, nil, nil, true)
		button:SetTemplate()
		button.Icon:SetDrawLayer('ARTWORK')
		button.Icon:SetTexCoord(unpack(E.TexCoords))
		button.Icon:SetInside()

		if button.Cooldown then
			button.Cooldown.CooldownOverride = 'actionbar'
			E:RegisterCooldown(button.Cooldown)
		end
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show();
	end

	E:CreateMover(ExtraActionBarHolder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS', nil, 'actionbar,extraActionButton');
	E:CreateMover(ZoneAbilityHolder, 'ZoneAbility', L["Zone Ability"], nil, nil, nil, 'ALL,ACTIONBARS');

	AB:Extra_SetAlpha()
	AB:Extra_SetScale()
end
