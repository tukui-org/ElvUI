local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars');

--Cache global variables
--Lua functions
local _G = _G
local ceil = math.ceil;
local format, find = format, string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetShapeshiftForm = GetShapeshiftForm
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local CooldownFrame_Set = CooldownFrame_Set
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local GetBindingKey = GetBindingKey
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
			CooldownFrame_Set(cooldown, start, duration, enable);
			cooldown:SetDrawBling(cooldown:GetEffectiveAlpha() > 0.5) --Cooldown Bling Fix
		end
	end

	self:StyleShapeShift("UPDATE_SHAPESHIFT_COOLDOWN")
end

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms();
	local texture, spellID, isActive, isCastable, _;
	local buttonName, button, icon, cooldown;
	local stance = GetShapeshiftForm();

	for i = 1, NUM_STANCE_SLOTS do
		buttonName = "ElvUI_StanceBarButton"..i;
		button = _G[buttonName];
		icon = _G[buttonName.."Icon"];
		cooldown = _G[buttonName.."Cooldown"];

		if i <= numForms then
			texture, isActive, isCastable, spellID = GetShapeshiftFormInfo(i);

			if self.db.stanceBar.style == 'darkenInactive' then
				_,_, texture = GetSpellInfo(spellID)
			end

			if not texture then
				texture = "Interface\\Icons\\Spell_Nature_WispSplode"
			end

			if not button.useMasque then
				if texture then
					cooldown:SetAlpha(1);
				else
					cooldown:SetAlpha(0);
				end

				if isActive then
					StanceBarFrame.lastSelected = button:GetID();
					if numForms == 1 then
						button.checked:SetColorTexture(1, 1, 1, 0.5)
						button:SetChecked(true);
					else
						button.checked:SetColorTexture(1, 1, 1, 0.5)
						button:SetChecked(self.db.stanceBar.style ~= 'darkenInactive');
					end
				else
					if numForms == 1 or stance == 0 then
						button:SetChecked(false);
					else
						button:SetChecked(self.db.stanceBar.style == 'darkenInactive');
						button.checked:SetAlpha(1)
						if self.db.stanceBar.style == 'darkenInactive' then
							button.checked:SetColorTexture(0, 0, 0, 0.5)
						else
							button.checked:SetColorTexture(1, 1, 1, 0.5)
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
	local buttonSpacing = E:Scale(self.db.stanceBar.buttonspacing);
	local backdropSpacing = E:Scale((self.db.stanceBar.backdropSpacing or self.db.stanceBar.buttonspacing))
	local buttonsPerRow = self.db.stanceBar.buttonsPerRow;
	local numButtons = self.db.stanceBar.buttons;
	local size = E:Scale(self.db.stanceBar.buttonsize);
	local point = self.db.stanceBar.point;
	local widthMult = self.db.stanceBar.widthMult;
	local heightMult = self.db.stanceBar.heightMult;
	if bar.mover then
		if self.db.stanceBar.usePositionOverride then
			bar.mover.positionOverride = point;
		else
			bar.mover.positionOverride = nil
		end
		E:UpdatePositionOverride(bar.mover:GetName())
	end

	--Now that we have set positionOverride for mover, convert "TOP" or "BOTTOM" to anchor points we can use
	local position = E:GetScreenQuadrant(bar)
	if find(position, "LEFT") or position == "TOP" or position == "BOTTOM" then
		if point == "TOP" then
			point = "TOPLEFT"
		elseif point == "BOTTOM" then
			point = "BOTTOMLEFT"
		end
	else
		if point == "TOP" then
			point = "TOPRIGHT"
		elseif point == "BOTTOM" then
			point = "BOTTOMRIGHT"
		end
	end

	bar.db = self.db.stanceBar
	bar.db.position = nil; --Depreciated
	bar.mouseover = self.db.stanceBar.mouseover

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

	if self.db.stanceBar.backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
		--Set size multipliers to 1 when backdrop is disabled
		widthMult = 1
		heightMult = 1
	end

	local barWidth = (size * (buttonsPerRow * widthMult)) + ((buttonSpacing * (buttonsPerRow - 1)) * widthMult) + (buttonSpacing * (widthMult-1)) + ((self.db.stanceBar.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2)
	local barHeight = (size * (numColumns * heightMult)) + ((buttonSpacing * (numColumns - 1)) * heightMult) + (buttonSpacing * (heightMult-1)) + ((self.db.stanceBar.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2)
	bar:Width(barWidth);
	bar:Height(barHeight);

	if self.db.stanceBar.enabled then
		bar:SetScale(1);
		bar:SetAlpha(bar.db.alpha);
		E:EnableMover(bar.mover:GetName())
	else
		bar:SetScale(0.0001);
		bar:SetAlpha(0);
		E:DisableMover(bar.mover:GetName())
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

	if(self.db.stanceBar.inheritGlobalFade) then
		bar:SetParent(self.fadeParent)
	else
		bar:SetParent(E.UIParent)
	end

	local button, lastButton, lastColumnButton;
	local firstButtonSpacing = (self.db.stanceBar.backdrop == true and (E.Border + backdropSpacing) or E.Spacing)
	for i=1, NUM_STANCE_SLOTS do
		button = _G["ElvUI_StanceBarButton"..i];
		lastButton = _G["ElvUI_StanceBarButton"..i-1];
		lastColumnButton = _G["ElvUI_StanceBarButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);

		if self.db.stanceBar.mouseover == true then
			bar:SetAlpha(0);
		else
			bar:SetAlpha(bar.db.alpha);
		end

		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = firstButtonSpacing, firstButtonSpacing;
			elseif point == "TOPRIGHT" then
				x, y = -firstButtonSpacing, -firstButtonSpacing;
			elseif point == "TOPLEFT" then
				x, y = firstButtonSpacing, -firstButtonSpacing;
			else
				x, y = -firstButtonSpacing, firstButtonSpacing;
			end

			button:Point(point, bar, point, x, y);
		elseif (i - 1) % buttonsPerRow == 0 then
			local x = 0;
			local y = -buttonSpacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = buttonSpacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = buttonSpacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -buttonSpacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end

		if i > numButtons then
			button:SetScale(0.0001);
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
	if InCombatLockdown() then
		AB.NeedsAdjustMaxStanceButtons = event or true
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local visibility = self.db.stanceBar.visibility;
	if visibility and visibility:match('[\n\r]') then
		visibility = visibility:gsub('[\n\r]','')
	end

	for i=1, #bar.buttons do
		bar.buttons[i]:Hide()
	end

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
		end

		if ( i <= numButtons ) then
			bar.buttons[i]:Show();
			bar.LastButton = i;
		else
			bar.buttons[i]:Hide();
		end
	end

	self:PositionAndSizeBarShapeShift();

	-- sometimes after combat lock down `event` may be true because of passing it back with `AB.NeedsAdjustMaxStanceButtons`
	if event == 'UPDATE_SHAPESHIFT_FORMS' then
		self:StyleShapeShift()
	end

	RegisterStateDriver(bar, "visibility", (numButtons == 0 and "hide") or visibility);
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

	self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
	self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');

	self:RegisterEvent('UPDATE_SHAPESHIFT_FORMS', 'AdjustMaxStanceButtons');
	self:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN');
	self:RegisterEvent('UPDATE_SHAPESHIFT_USABLE', 'StyleShapeShift');
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', 'StyleShapeShift');
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED', 'StyleShapeShift');

	E:CreateMover(bar, 'ShiftAB', L["Stance Bar"], nil, -3, nil, 'ALL,ACTIONBARS', nil, 'actionbar,stanceBar');
	self:AdjustMaxStanceButtons();
	self:PositionAndSizeBarShapeShift();
	self:StyleShapeShift();
	self:UpdateStanceBindings()
end
