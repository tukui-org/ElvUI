local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
-- GLOBALS: ExtraActionBarFrame, DraenorZoneAbilityFrame

local function FixExtraActionCD(cd)
	local start, duration = GetActionCooldown(cd:GetParent().action)
	E.OnSetCooldown(cd, start, duration, 0, 0)
end

function AB:Extra_SetAlpha()
	local alpha = E.db.actionbar.extraActionButton.alpha
	for i=1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button:SetAlpha(alpha)
		end
	end
end

function AB:Extra_SetScale()
	local scale = E.db.actionbar.extraActionButton.scale
	if ExtraActionBarFrame then
		ExtraActionBarFrame:SetScale(scale)
	end
end

function AB:SetupExtraButton()
	local holder = CreateFrame('Frame', nil, E.UIParent)
	holder:Point('BOTTOM', E.UIParent, 'BOTTOM', 0, 150)
	holder:Size(ExtraActionBarFrame:GetSize())

	ExtraActionBarFrame:SetParent(holder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:Point('CENTER', holder, 'CENTER')
	ExtraActionBarFrame.ignoreFramePositionManager  = true

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
			tex:SetTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)

			if(button.cooldown and E.private.cooldown.enable) then
				E:RegisterCooldown(button.cooldown)
				button.cooldown:HookScript("OnShow", FixExtraActionCD)
			end
		end
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show();
	end

	AB:Extra_SetAlpha()
	AB:Extra_SetScale()

	E:CreateMover(holder, 'BossButton', L["Boss Button"], nil, nil, nil, 'ALL,ACTIONBARS');
end