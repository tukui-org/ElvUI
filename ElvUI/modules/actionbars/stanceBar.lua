local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

--Cache global variables
--Lua functions
local _G = _G
local type = type
local ceil = math.ceil;
local format, lower = format, string.lower
--WoW API / Variables
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetShapeshiftForm = GetShapeshiftForm
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local GetBindingKey = GetBindingKey
local C_PetBattlesIsInBattle = C_PetBattles.IsInBattle
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: StanceBarFrame

local Masque = LibStub("Masque", true)
local MasqueGroup = Masque and Masque:Group("ElvUI", "Stance Bar")

local bar = CreateFrame('Frame', 'ElvUI_StanceBar', E.UIParent, 'SecureHandlerStateTemplate');

function AB:UPDATE_SHAPESHIFT_COOLDOWN()
	local numForms = GetNumShapeshiftForms();
	local start, duration, enable, cooldown
	for i = 1, NUM_STANCE_SLOTS do
		if i <= numForms then
			cooldown = _G["ElvUI_StanceBarButton"..i.."Cooldown"];
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
			cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0.5) --Cooldown Bling Fix
		end
	end

	self:StyleShapeShift("UPDATE_SHAPESHIFT_COOLDOWN")
end

function AB:StyleShapeShift(event)
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable, _;
	local buttonName, button, icon, cooldown;
	local stance = GetShapeshiftForm();

	for i = 1, NUM_STANCE_SLOTS do
		buttonName = "ElvUI_StanceBarButton"..i;
		button = _G[buttonName];
		icon = _G[buttonName.."Icon"];
		cooldown = _G[buttonName.."Cooldown"];

		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);

			if not texture then
				texture = "Interface\\Icons\\Spell_Nature_WispSplode"
			end

			if not button.useMasque then
				if (type(texture) == "string" and (lower(texture) == "interface\\icons\\spell_nature_wispsplode" or lower(texture) == "interface\\icons\\ability_rogue_envelopingshadows")) and self.db.stanceBar.style == 'darkenInactive' then
					_, _, texture = GetSpellInfo(name)
				end

				if texture then
					cooldown:SetAlpha(1);
				else
					cooldown:SetAlpha(0);
				end

				if isActive then
					StanceBarFrame.lastSelected = button:GetID();
					if numForms == 1 then
						button.checked:SetTexture(1, 1, 1, 0.5)
						button:SetChecked(true);
					else
						button.checked:SetTexture(1, 1, 1, 0.5)
						button:SetChecked(self.db.stanceBar.style ~= 'darkenInactive');
					end
				else
					if numForms == 1 or stance == 0 then
						button:SetChecked(false);
					else
						button:SetChecked(self.db.stanceBar.style == 'darkenInactive');
						button.checked:SetAlpha(1)
						if self.db.stanceBar.style == 'darkenInactive' then
							button.checked:SetTexture(0, 0, 0, 0.5)
						else
							button.checked:SetTexture(1, 1, 1, 0.5)
						end
					end
				end
			else
				if isActive then
					button:SetChecked(true)
				else
					button:SetChecked(false)
				end
			end

			icon:SetTexture(texture);

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local spacing = E:Scale(self.db['stanceBar'].buttonspacing);
	local buttonsPerRow = self.db['stanceBar'].buttonsPerRow;
	local numButtons = self.db['stanceBar'].buttons;
	local size = E:Scale(self.db['stanceBar'].buttonsize);
	local point = self.db['stanceBar'].point;
	local widthMult = self.db['stanceBar'].widthMult;
	local heightMult = self.db['stanceBar'].heightMult;
	if bar.mover then
		bar.mover.positionOverride = point;
		E:UpdatePositionOverride(bar.mover:GetName())
	end
	bar.db = self.db['stanceBar']
	bar.db.position = nil; --Depreciated
	if bar.LastButton and numButtons > bar.LastButton then
		numButtons = bar.LastButton;
	end

	if bar.LastButton and buttonsPerRow > bar.LastButton then
		buttonsPerRow = bar.LastButton;
	end

	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	local numColumns = ceil(numButtons / buttonsPerRow);
	if numColumns < 1 then
		numColumns = 1;
	end

	bar:Width(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:Height(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mouseover = self.db['stanceBar'].mouseover
	if self.db['stanceBar'].enabled then
		bar:SetScale(1);
		bar:SetAlpha(bar.db.alpha);
		E:EnableMover(bar.mover:GetName())
	else
		bar:SetScale(0.000001);
		bar:SetAlpha(0);
		E:DisableMover(bar.mover:GetName())
	end

	if self.db['stanceBar'].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end

	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end
	
	if(self.db['stanceBar'].inheritGlobalFade) then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end	

	local button, lastButton, lastColumnButton;
	for i=1, NUM_STANCE_SLOTS do
		button = _G["ElvUI_StanceBarButton"..i];
		lastButton = _G["ElvUI_StanceBarButton"..i-1];
		lastColumnButton = _G["ElvUI_StanceBarButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);

		if self.db['stanceBar'].mouseover == true then
			bar:SetAlpha(0);
		else
			bar:SetAlpha(bar.db.alpha);
		end

		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing;
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing;
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing;
			else
				x, y = -spacing, spacing;
			end

			button:Point(point, bar, point, x, y);
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0;
			local y = -spacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = spacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = spacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -spacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end

		if i > numButtons then
			button:SetScale(0.000001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(bar.db.alpha);
		end

		if(not button.FlyoutUpdateFunc) then
			self:StyleButton(button, nil, MasqueGroup and E.private.actionbar.masque.stanceBar and true or nil);
		end
	end

	if MasqueGroup and E.private.actionbar.masque.stanceBar then MasqueGroup:ReSkin() end
end

function AB:AdjustMaxStanceButtons(event)
	if InCombatLockdown() then return; end

	for i=1, #bar.buttons do
		bar.buttons[i]:Hide()
	end
	local initialCreate = false;
	local numButtons = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame("CheckButton", format(bar:GetName().."Button%d", i), bar, "StanceButtonTemplate")
			bar.buttons[i]:SetID(i)
			if MasqueGroup and E.private.actionbar.masque.stanceBar then
				MasqueGroup:AddButton(bar.buttons[i])
			end
			self:HookScript(bar.buttons[i], 'OnEnter', 'Button_OnEnter');
			self:HookScript(bar.buttons[i], 'OnLeave', 'Button_OnLeave');			
			initialCreate = true;
		end

		if ( i <= numButtons ) then
			bar.buttons[i]:Show();
			bar.LastButton = i;
		else
			bar.buttons[i]:Hide();
		end
	end

	self:PositionAndSizeBarShapeShift();

	if event == 'UPDATE_SHAPESHIFT_FORMS' then
		self:StyleShapeShift()
	end

	if not C_PetBattlesIsInBattle() or initialCreate then
		if numButtons == 0 then
			UnregisterStateDriver(bar, "show");
			bar:Hide()
		else
			bar:Show()
			RegisterStateDriver(bar, "show", '[petbattle] hide;show');
		end
	end
end

function AB:UpdateStanceBindings()
	for i = 1, NUM_STANCE_SLOTS do
		if self.db.hotkeytext then
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:Show()
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:SetText(GetBindingKey("CLICK ElvUI_StanceBarButton"..i..":LeftButton"))
			self:FixKeybindText(_G["ElvUI_StanceBarButton"..i])
		else
			_G["ElvUI_StanceBarButton"..i.."HotKey"]:Hide()
		end
	end
end


function AB:CreateBarShapeShift()
	bar:CreateBackdrop('Default');
	bar.backdrop:SetAllPoints();
	bar:Point('TOPLEFT', E.UIParent, 'TOPLEFT', 4, -4);
	bar.buttons = {};
	bar:SetAttribute("_onstate-show", [[
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end
	]]);

	self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
	self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');


	self:RegisterEvent('UPDATE_SHAPESHIFT_FORMS', 'AdjustMaxStanceButtons');
	self:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN');
	self:RegisterEvent('UPDATE_SHAPESHIFT_USABLE', 'StyleShapeShift');
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', 'StyleShapeShift');
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED', 'StyleShapeShift');

	E:CreateMover(bar, 'ShiftAB', L["Stance Bar"], nil, -3, nil, 'ALL,ACTIONBARS');
	self:AdjustMaxStanceButtons();
	self:PositionAndSizeBarShapeShift();
	self:StyleShapeShift();
	self:UpdateStanceBindings()
end