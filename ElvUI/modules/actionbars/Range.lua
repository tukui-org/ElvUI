local E, C, L, DF = unpack(select(2, ...));
if C["actionbar"].enable ~= true then return; end

local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER;
local HAND_OF_LIGHT = GetSpellInfo(90174);
local HOLY_POWER_SPELLS = {
	[85256] = GetSpellInfo(85256), --Templar's Verdict
	[53600] = GetSpellInfo(53600), --Shield of the Righteous
};

local function IsHolyPowerAbility(actionId)
	local actionType, id = GetActionInfo(actionId);
	if actionType == 'macro' then
		local macroSpell = GetMacroSpell(id);
		if macroSpell then
			for spellId, spellName in pairs(HOLY_POWER_SPELLS) do
				if macroSpell == spellName then
					return true;
				end
			end
		end
	else
		return HOLY_POWER_SPELLS[id];
	end
	return false;
end

local id, isUsable, noEnoughMana, name, icon, normalTexture, hotkey;
local function UpdateUsable(button)
    id = button.action;

	if not id or not button:IsShown() then return; end
	
    isUsable, notEnoughMana = IsUsableAction(id);
	name = button:GetName();
	icon = _G[name.."Icon"];
	normalTexture = _G[name.."NormalTexture"];
	hotkey = _G[name.."HotKey"];	
	
    if isUsable then
        if IsActionInRange(id) == 0 then
            icon:SetVertexColor(0.8, 0.1, 0.1);
            normalTexture:SetVertexColor(0.8, 0.1, 0.1);
        elseif E.myclass == "PALADIN" and IsHolyPowerAbility(id) and not(UnitPower('player', SPELL_POWER_HOLY_POWER) == 3 or UnitBuff('player', HAND_OF_LIGHT)) then
			icon:SetVertexColor(0.45, 0.45, 1);
			normalTexture:SetVertexColor(0.45, 0.45, 1);
		else
            icon:SetVertexColor(1.0, 1.0, 1.0);
            normalTexture:SetVertexColor(1.0, 1.0, 1.0);
        end
    elseif notEnoughMana then
        icon:SetVertexColor(0.1, 0.3, 1.0);
        normalTexture:SetVertexColor(0.1, 0.3, 1.0);
	else
		icon:SetVertexColor(0.2, 0.2, 0.2);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);	
    end
	hotkey:SetTextColor(0.6, 0.6, 0.6);
end

hooksecurefunc('ActionButton_OnUpdate', UpdateUsable)