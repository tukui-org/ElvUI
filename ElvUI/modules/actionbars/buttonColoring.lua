local E, L, DF = unpack(select(2, ...)); --Engine
local AB = E:GetModule('ActionBars');

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

function AB:CreateTimer()
	local updater = UpdateFrame:CreateAnimationGroup()
	updater:SetLooping('NONE')
	updater:SetScript('OnFinished', function()
		if self:UpdateAllButtons(UPDATE_INTERVAL) then
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

function AB:IsHolyPowerAbility(actionId)
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

function AB:GetColor(index)
	local color = BUTTON_COLOR_INDEX[index]
	return color[1], color[2], color[3]
end

function AB:SetButtonColor(button, colorType)
	if button.colorType ~= colorType then
		local name = button:GetName();
		local icon = _G[name.."Icon"];
		local normalTexture = _G[name.."NormalTexture"];		
		
		if not icon or not normalTexture then return end
		
		local r, g, b = self:GetColor(colorType)
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

function AB:UpdateUsable(button)
    local id = button.action;

	if not id or not button:IsShown() then return; end
	
    local isUsable, notEnoughMana = IsUsableAction(id);
	
    if isUsable then
        if IsActionInRange(id) == 0 then
			self:SetButtonColor(button, 'OOR');
        elseif E.myclass == "PALADIN" and self:IsHolyPowerAbility(id) and not(UnitPower('player', SPELL_POWER_HOLY_POWER) == 3 or UnitBuff('player', HAND_OF_LIGHT)) then
			self:SetButtonColor(button, 'OOH');
		else
			self:SetButtonColor(button, 'NORMAL');
        end
    elseif notEnoughMana then
		self:SetButtonColor(button, 'OOM');
	else
		self:SetButtonColor(button, 'UNUSABLE');
    end
end

function AB:UpdateFlash(button, elapsed)
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

function AB:UpdateButton(button, elapsed)
	self:UpdateUsable(button)
	self:UpdateFlash(button, elapsed)
end

function AB:UpdateAllButtons(elapsed)
	if next(ButtonsToUpdate) then
		for button in pairs(ButtonsToUpdate) do
			self:UpdateButton(button, elapsed)
		end
		return true
	end
	return false
end

function AB:UpdateActive()
	if next(ButtonsToUpdate) then
		if not UpdateFrame:Active() then
			UpdateFrame:Start()
		end
	else
		UpdateFrame:Stop()
	end
end

function AB:UpdateButtonStatus()
	local action = ActionButton_GetPagedID(self)
	if self:IsVisible() and action and HasAction(action) and ActionHasRange(action) then
		ButtonsToUpdate[self] = true
	else
		ButtonsToUpdate[self] = nil
	end
	AB:UpdateActive()
end

function AB:OnUpdateUsable()
	self.colorType = nil; 
	AB:UpdateUsable(self);
end

local function RegisterButton(button, elapsed)
	_G[button:GetName().."HotKey"].SetVertexColor = E.noop
	
	button:SetScript('OnShow', AB.UpdateselfStatus)
	button:SetScript('OnHide', AB.UpdateselfStatus)
	button:SetScript('OnUpdate', nil)	
	
	AB.UpdateButtonStatus(button)
end

function AB:LoadButtonColoring()	
	hooksecurefunc('ActionButton_OnUpdate', RegisterButton)
	hooksecurefunc('ActionButton_UpdateUsable', AB.OnUpdateUsable)
	hooksecurefunc('ActionButton_Update', AB.UpdateButtonStatus)
end
AB:CreateTimer()