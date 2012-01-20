local E, L, DF = unpack(select(2, ...)); --Engine
local AB = E:GetModule('ActionBars');

local ceil = math.ceil;
local condition = "";
local bar = CreateFrame('Frame', 'ElvUI_Bar3', E.UIParent, 'SecureHandlerStateTemplate');
local LAB = LibStub("LibActionButton-1.0")

local barName = 'bar3'
AB["handledBars"][bar] = barName;
function AB:PositionAndSizeBar3()
	local spacing = E:Scale(self.db.buttonspacing);
	local buttonsPerRow = self.db[barName].buttonsPerRow;
	local numButtons = self.db[barName].buttons;
	local size = E:Scale(self.db.buttonsize);
	local point = self.db[barName].point;
	local numColumns = ceil(numButtons / buttonsPerRow);
	local widthMult = self.db[barName].widthMult;
	local heightMult = self.db[barName].heightMult;
	
	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end

	if numColumns < 1 then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mover:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar.mover:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mouseover = self.db[barName].mouseover
	
	if self.db[barName].backdrop == true then
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
	
	local button, lastButton, lastColumnButton ;
	local possibleButtons = {};
	for i=1, NUM_ACTIONBAR_BUTTONS do
		button = bar.buttons[i];
		lastButton = bar.buttons[i-1];
		lastColumnButton = bar.buttons[i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		
		button:SetAttribute("showgrid", 1);
		ActionButton_ShowGrid(button);
			
		possibleButtons[((i * buttonsPerRow) + 1)] = true;

		if self.db[barName].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');	
			end
			
			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');					
			end
		else
			bar:SetAlpha(1);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end
			
			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');	
				self:Unhook(button, 'OnLeave');	
			end
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
		elseif possibleButtons[i] then
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
			button:SetAlpha(1);
		end
		
		self:StyleButton(button);
	end
	possibleButtons = nil;

	if self.db[barName].enabled then
		bar:SetScale(1);
		
		if not self.db[barName].mouseover then
			bar:SetAlpha(1);
		end
	else
		bar:SetScale(0.000001);
		bar:SetAlpha(0);
	end
	
	RegisterStateDriver(bar, "page", self:GetPage(barName, 6, condition));
	RegisterStateDriver(bar, "show", self.db[barName].visibility);
end

function AB:CreateBar3()
	bar:CreateBackdrop('Default');
	bar.backdrop:SetAllPoints();
	bar:Point('LEFT', ElvUI_Bar1, 'RIGHT', 3, 0);
	bar.buttons = {}
	bar.bindButtons = 'MULTIACTIONBAR1BUTTON'
	
	for i=1, NUM_ACTIONBAR_BUTTONS do
		bar.buttons[i] = LAB:CreateButton(i, format(bar:GetName().."Button%d", i), bar, nil)
		bar.buttons[i]:SetState(0, "action", i)
		for k = 1, 11 do
			bar.buttons[i]:SetState(k, "action", (k - 1) * 12 + i)
		end
	end
	self:UpdateButtonConfig(bar, bar.bindButtons)
	bar:SetAttribute("_onstate-page", [[ 
		self:SetAttribute("state", newstate)
		control:ChildUpdate("state", newstate)
	]]);
	
	bar:SetAttribute("_onstate-show", [[		
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end	
	]])	
	
	self:CreateMover(bar, 'AB3', barName);
	self:PositionAndSizeBar3();
end