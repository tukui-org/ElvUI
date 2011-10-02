local E, C, L, DF = unpack(select(2, ...));
if C["actionbar"].enable ~= true then return; end

local UpdateAllButtons; --UpValue
local ButtonsToUpdate = {};
local UPDATE_INTERVAL = 0.15;
local UpdateFrame = CreateFrame('Frame');
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER;
local HAND_OF_LIGHT = GetSpellInfo(90174);

local HOLY_POWER_SPELLS = {
	[85256] = GetSpellInfo(85256), --Templar's Verdict
	[53600] = GetSpellInfo(53600), --Shield of the Righteous
};

local BUTTON_COLOR_INDEX = {
	['OOR'] = {0.8, 0.1, 0.1},
	['OOH'] = {0.45, 0.45, 1},
	['OOM'] = {0.1, 0.3, 1.0},
	['NORMAL'] = {1.0, 1.0, 1.0},
	['UNUSABLE'] = {0.2, 0.2, 0.2},
};

local function CreateTimer()
	local updater = UpdateFrame:CreateAnimationGroup()
	updater:SetLooping('NONE')
	updater:SetScript('OnFinished', function(self)
		if UpdateAllButtons(UPDATE_INTERVAL) then
			UpdateFrame:Start(UPDATE_INTERVAL)
		end
	end)

	local a = updater:CreateAnimation('Animation'); 
	a:SetOrder(1);

	UpdateFrame.Start = function(self)
		self:Stop()
		a:SetDuration(UPDATE_INTERVAL)
		updater:Play()
		return self
	end

	UpdateFrame.Stop = function(self)
		if updater:IsPlaying() then
			updater:Stop()
		end
		return self
	end

	UpdateFrame.Active = function(self)
		return updater:IsPlaying()
	end
end

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

local function GetColor(index)
	local color = BUTTON_COLOR_INDEX[index]
	return color[1], color[2], color[3]
end

local function SetButtonColor(button, colorType)
	if button.colorType ~= colorType then
		local name = button:GetName();
		local icon = _G[name.."Icon"];
		local normalTexture = _G[name.."NormalTexture"];		
	
		local r, g, b = GetColor(colorType)
		if colorType ~= 'UNUSABLE' then
			icon:SetVertexColor(r, g, b)
			normalTexture:SetVertexColor(r, g, b)
		else
			icon:SetVertexColor(r, g, b)
			normalTexture:SetVertexColor(1.0, 1.0, 1.0)		
		end
		button.colorType = colorType;
	end
end

local function UpdateUsable(button)
    local id = button.action;

	if not id or not button:IsShown() then return; end
	
    local isUsable, notEnoughMana = IsUsableAction(id);
	
    if isUsable then
        if IsActionInRange(id) == 0 then
			SetButtonColor(button, 'OOR');
        elseif E.myclass == "PALADIN" and IsHolyPowerAbility(id) and not(UnitPower('player', SPELL_POWER_HOLY_POWER) == 3 or UnitBuff('player', HAND_OF_LIGHT)) then
			SetButtonColor(button, 'OOH');
		else
			SetButtonColor(button, 'NORMAL');
        end
    elseif notEnoughMana then
		SetButtonColor(button, 'OOM');
	else
		SetButtonColor(button, 'UNUSABLE');
    end
end

local function UpdateFlash(button, elapsed)
	if ActionButton_IsFlashing(button) then
		local flashtime = button.flashtime - elapsed

		if flashtime <= 0 then
			local overtime = -flashtime
			if overtime >= ATTACK_BUTTON_FLASH_TIME then
				overtime = 0
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime

			local flashTexture = _G[button:GetName() .. 'Flash']
			if flashTexture:IsShown() then
				flashTexture:Hide()
			else
				flashTexture:Show()
			end
		end

		button.flashtime = flashtime
	end
end

local function UpdateButton(button, elapsed)
	UpdateUsable(button)
	UpdateFlash(button, elapsed)
end

function UpdateAllButtons(elapsed)
	if next(ButtonsToUpdate) then
		for button in pairs(ButtonsToUpdate) do
			UpdateButton(button, elapsed)
		end
		return true
	end
	return false
end

local function UpdateActive()
	if next(ButtonsToUpdate) then
		if not UpdateFrame:Active() then
			UpdateFrame:Start()
		end
	else
		UpdateFrame:Stop()
	end
end

local function UpdateButtonStatus(button)
	local action = ActionButton_GetPagedID(button)
	if button:IsVisible() and action and HasAction(action) and ActionHasRange(action) then
		ButtonsToUpdate[button] = true
	else
		ButtonsToUpdate[button] = nil
	end
	UpdateActive()
end

local function RegisterButton(button, elapsed)
	_G[button:GetName().."HotKey"].SetVertexColor = E.dummy
	button:SetScript('OnShow', UpdateButtonStatus)
	button:SetScript('OnHide', UpdateButtonStatus)
	button:SetScript('OnUpdate', nil)	
	
	UpdateButtonStatus(button)
end

hooksecurefunc('ActionButton_OnUpdate', RegisterButton)
hooksecurefunc('ActionButton_UpdateUsable', function(button) button.colorType = nil; UpdateUsable(button); end)
hooksecurefunc('ActionButton_Update', UpdateButtonStatus)
CreateTimer()