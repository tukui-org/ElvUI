local E, L, V, P, G = unpack(select(2, ...));
local CT = E:NewModule('ClassTimers')

E.ClassTimers = CT

local auraTypes = { "HELPFUL", "HARMFUL" };
local BAR_HEIGHT, BAR_SPACING = 22, 1;

local function CreateColor(red, green, blue, alpha)
	return { red / 255, green / 255, blue / 255, alpha };
end

local function CheckFilter(self, id, caster, filter)
	if (filter == nil) then return false; end
		
	local byPlayer = caster == "player" or caster == "pet" or caster == "vehicle";
		
	for _, v in ipairs(filter) do
		if (v.id == id and (v.castByAnyone or byPlayer) and v.enabled == true) then return v; end
	end
	
	return false;
end

local function CheckUnit(self, unit, filter, result)
	if (not UnitExists(unit)) then return 0; end

	local unitIsFriend = UnitIsFriend("player", unit);

	for _, auraType in ipairs(auraTypes) do
		local isDebuff = auraType == "HARMFUL";
	
		for index = 1, 40 do
			local name, _, texture, stacks, _, duration, expirationTime, caster, _, _, spellId = UnitAura(unit, index, auraType);		
			if (name == nil) then
				break;
			end							
			
			local filterInfo = CheckFilter(self, spellId, caster, filter);
			if (filterInfo and (filterInfo.unitType ~= 1 or unitIsFriend) and (filterInfo.unitType ~= 2 or not unitIsFriend)) then 					
				filterInfo.name = name;
				filterInfo.texture = texture;
				filterInfo.duration = duration;
				filterInfo.expirationTime = expirationTime;
				filterInfo.stacks = stacks;
				filterInfo.unit = unit;
				filterInfo.isDebuff = isDebuff;
				table.insert(result, filterInfo);
			end
		end
	end
end

local function Update(self)
	local result = self.table;

	for index = 1, #result do
		table.remove(result);
	end				

	CheckUnit(self, self.unit, self.filter, result);
	if (self.includePlayer) then
		CheckUnit(self, "player", self.playerFilter, result);
	end
	
	self.table = result;
end

local function SetSortDirection(self, descending)
	self.sortDirection = descending;
end

local function GetSortDirection(self)
	return self.sortDirection;
end

local function Sort(self)
	local direction = self.sortDirection;
	local time = GetTime();

	local sorted;
	repeat
		sorted = true;
		for key, value in pairs(self.table) do
			local nextKey = key + 1;
			local nextValue = self.table[ nextKey ];
			if (nextValue == nil) then break; end
			
			local currentRemaining = value.expirationTime == 0 and 4294967295 or math.max(value.expirationTime - time, 0);
			local nextRemaining = nextValue.expirationTime == 0 and 4294967295 or math.max(nextValue.expirationTime - time, 0);
			
			if ((direction and currentRemaining < nextRemaining) or (not direction and currentRemaining > nextRemaining)) then
				self.table[ key ] = nextValue;
				self.table[ nextKey ] = value;
				sorted = false;
			end				
		end			
	until (sorted == true)
end

local function Get(self)
	return self.table;
end

local function Count(self)
	return #self.table;
end

local function AddFilter(self, filter, defaultColor, debuffColor)
	if (filter == nil) then return; end
	
	for _, v in pairs(filter) do
		local clone = { };
		
		if v.color then
			clone.color = {v.color.r, v.color.g, v.color.b}
		end

		clone.enabled = v.enabled;
		clone.id = v.id;
		clone.castByAnyone = v.castByAnyone;
		clone.unitType = v.unitType;
		clone.castSpellId = v.castSpellId;
		
		if defaultColor then
			clone.defaultColor = {defaultColor.r, defaultColor.g, defaultColor.b};
		end
		
		if debuffColor then
			clone.debuffColor = {debuffColor.r, debuffColor.g, debuffColor.b};
		end
		
		table.insert(self.filter, clone);
	end
end

local function RemoveAllFilters(self)
	wipe(self.filter)
end

local function AddPlayerFilter(self, filter, defaultColor, debuffColor)
	if (filter == nil) then return; end

	for _, v in pairs(filter) do
		local clone = { };
		
		clone.enabled = v.enabled;
		clone.id = v.id;
		clone.castByAnyone = v.castByAnyone;
		clone.color = v.color;
		clone.unitType = v.unitType;
		clone.castSpellId = v.castSpellId;
		
		clone.defaultColor = defaultColor;
		clone.debuffColor = debuffColor;
		
		table.insert(self.playerFilter, clone);
	end
end

local function GetUnit(self)
	return self.unit;
end

local function GetIncludePlayer(self)
	return self.includePlayer;
end

local function SetIncludePlayer(self, value)
	self.includePlayer = value;
end

local function SetTexture(self, ...)
	return self.texture:SetTexture(...);
end

local function GetTexture(self)
	return self.texture:GetTexture();
end

local function GetTexCoord(self)
	return self.texture:GetTexCoord();
end

local function SetTexCoord(self, ...)
	return self.texture:SetTexCoord(...);
end

local function SetBorderColor(self, ...)
	return self.border:SetVertexColor(...);
end

function CT:CreateFramedTexture(parent)
	local result = CreateFrame('Frame', nil, parent)
	local texture = result:CreateTexture(nil, "ARTWORK");		
	result:SetTemplate('Default')
	
	texture:SetPoint("TOPLEFT", result, "TOPLEFT", 2, -2);
	texture:SetPoint("BOTTOMRIGHT", result, "BOTTOMRIGHT", -2, 2);
		
	result.texture = texture;
		
	result.SetBorderColor = SetBorderColor;
	
	result.SetTexture = SetTexture;
	result.GetTexture = GetTexture;
	result.SetTexCoord = SetTexCoord;
	result.GetTexCoord = GetTexCoord;
	
	return result;
end

local function OnUpdate(self, elapsed)	
	local time = GetTime();

	if (time > self.expirationTime) then
		self.bar:SetScript("OnUpdate", nil);
		self.bar:SetValue(0);
		self.time:SetText("");
		self.spark:Hide()
	else
		local remaining = self.expirationTime - time;
		self.bar:SetValue(remaining);
		
		local timeText = "";
		if (remaining >= 3600) then
			timeText = tostring(math.floor(remaining / 3600)) .. "h";
		elseif (remaining >= 60) then
			timeText = tostring(math.floor(remaining / 60)) .. "m";
		elseif (remaining > 1) then
			timeText = tostring(math.floor(remaining));
		elseif (remaining > 0) then
			timeText = tostring(math.floor(remaining * 10) / 10);
		end
		self.time:SetText(timeText);
		
		local barWidth = self.bar:GetWidth();
		
		self.spark:SetPoint("CENTER", self.bar, "LEFT", barWidth * remaining / self.duration, 0);
	end
end

local function SetIcon(self, icon)
	if (not self.icon) then return; end
	
	self.icon:SetTexture(icon);
end

local function SetTime(self, expirationTime, duration)
	self.expirationTime = expirationTime;
	self.duration = duration;
	
	if (expirationTime > 0 and duration > 0) then		
		self.bar:SetMinMaxValues(0, duration);
		OnUpdate(self, 0);

		local spark = self.spark;
		if (spark) then 
			spark:Show();
		end

		self:SetScript("OnUpdate", OnUpdate);
	else
		self.bar:SetMinMaxValues(0, 1);
		self.bar:SetValue(1);
		self.time:SetText("");
		
		local spark = self.spark;
		if (spark) then 
			spark:Hide();
		end
		
		self:SetScript("OnUpdate", nil);
	end
end

local function SetName(self, name)
	self.name:SetText(name);
end

local function SetStacks(self, stacks)
	if (not self.stacks) then
		if (stacks ~= nil and stacks > 1) then
			local name = self.name;
			
			name:SetText(tostring(stacks) .. "  " .. name:GetText());
		end
	else			
		if (stacks ~= nil and stacks > 1) then
			self.stacks:SetText(stacks);
		else
			self.stacks:SetText("");
		end
	end
end

local function SetColor(self, color)
	self.bar:SetStatusBarColor(unpack(color));
end

local function SetCastSpellId(self, id)
	self.castSpellId = id;
end

local function SetAuraInfo(self, auraInfo)
	self:SetName(auraInfo.name);
	self:SetIcon(auraInfo.texture);	
	self:SetTime(auraInfo.expirationTime, auraInfo.duration);
	self:SetStacks(auraInfo.stacks);
	self:SetCastSpellId(auraInfo.castSpellId);
end

function CT:CreateAuraBar(parent)
	local result = CreateFrame("Frame", nil, parent, nil);
	
	local icon = self:CreateFramedTexture(result, "OVERLAY");
	icon:SetTexCoord(unpack(E.TexCoords));	
	icon:SetPoint("TOPLEFT", result, 'TOPLEFT');		
	icon:Size(BAR_HEIGHT)

	result.icon = icon;
			
	local stacks = icon:CreateFontString(nil, "OVERLAY", nil);
	stacks:FontTemplate(nil, 10, 'OUTLINE')
	stacks:SetPoint("BOTTOMRIGHT", icon.texture, "BOTTOMRIGHT", 1, 1);
	stacks:SetJustifyH('RIGHT')
	result.stacks = stacks;
		
	local bar = CreateFrame("StatusBar", nil, result, nil);
	bar:SetStatusBarTexture(E["media"].normTex);
	bar:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 3, -2)
	bar:SetPoint('BOTTOMRIGHT', -2, 2)
	bar:CreateBackdrop('Transparent')
	result.bar = bar;
	
	local spark = bar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	spark:SetWidth(12);
	spark:SetBlendMode("ADD");
	spark:Show();
	result.spark = spark;
				
	local name = bar:CreateFontString(nil, "OVERLAY", nil);
	name:FontTemplate(nil, 12, 'OUTLINE')
	name:SetJustifyH("LEFT");
	name:SetPoint("TOPLEFT", bar, "TOPLEFT", 5, 0);
	name:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -45, 0);
	result.name = name;
	
	local time = bar:CreateFontString(nil, "OVERLAY", nil);
	time:FontTemplate(nil, 12, 'OUTLINE')
	time:SetJustifyH("RIGHT");
	time:SetPoint("TOPLEFT", name, "TOPRIGHT", 0, 0);
	time:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -5, 0);
	result.time = time;
	
	result.SetIcon = SetIcon;
	result.SetTime = SetTime;
	result.SetName = SetName;
	result.SetStacks = SetStacks;
	result.SetAuraInfo = SetAuraInfo;
	result.SetColor = SetColor;
	result.SetCastSpellId = SetCastSpellId;
	
	return result;
end

local function SetAuraBar(self, index, auraInfo)
	local line = self.lines[ index ]
	if (line == nil) then
		line = CT:CreateAuraBar(self);
		if (index == 1) then
			line:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, BAR_HEIGHT);
			line:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
		else
			local anchor = self.lines[ index - 1 ];
			line:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, BAR_HEIGHT + BAR_SPACING);
			line:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, BAR_SPACING);
		end
		tinsert(self.lines, index, line);
	end	
	
	line:SetAuraInfo(auraInfo);
	if (auraInfo.color) then
		line:SetColor(auraInfo.color);
	elseif (auraInfo.debuffColor and auraInfo.isDebuff) then
		line:SetColor(auraInfo.debuffColor);
	elseif (auraInfo.defaultColor) then
		line:SetColor(auraInfo.defaultColor);
	end
	
	line:Show();
end

local function OnEvent(self, event, unit)
	if (event == "UNIT_AURA") then
		if (unit ~= self.unit and (self.dataSource:GetIncludePlayer() == false or unit ~= "player")) then
			return;
		end
		self:Render();
	elseif (event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD") then
		self:Render();
	else
		error("Unhandled event " .. event);
	end
end

local function Render(self)
	local dataSource = self.dataSource;	

	dataSource:Update();
	dataSource:Sort();
	
	local count = dataSource:Count();

	for index, auraInfo in ipairs(dataSource:Get()) do
		SetAuraBar(self, index, auraInfo);
	end
	
	for index = count + 1, 80 do
		local line = self.lines[ index ];
		if (line == nil or not line:IsShown()) then
			break;
		end
		line:Hide();
	end
	
	if (count > 0) then
		self:SetHeight((BAR_HEIGHT + BAR_SPACING) * count - BAR_SPACING);
		self:Show();
	else
		self:Hide();
		self:SetHeight(self.hiddenHeight or 1);
	end
end

local function SetHiddenHeight(self, height)
	self.hiddenHeight = height;
end

function CT:CreateUnitAuraDataSource(unit)
	local result = {};

	result.Sort = Sort;
	result.Update = Update;
	result.Get = Get;
	result.Count = Count;
	result.SetSortDirection = SetSortDirection;
	result.GetSortDirection = GetSortDirection;
	result.AddFilter = AddFilter;
	result.RemoveAllFilters = RemoveAllFilters
	result.AddPlayerFilter = AddPlayerFilter;
	result.GetUnit = GetUnit; 
	result.SetIncludePlayer = SetIncludePlayer; 
	result.GetIncludePlayer = GetIncludePlayer; 
	result.SetHiddenHeight = SetHiddenHeight
	
	result.unit = unit;
	result.includePlayer = false;
	result.filter = {};
	result.playerFilter = {};
	result.table = {};
	
	result:SetSortDirection(true)
	result:SetHiddenHeight(-6)
	
	return result;
end

function CT:EnableAuraBarFrame(bar)
	bar:RegisterEvent("PLAYER_ENTERING_WORLD");
	bar:RegisterEvent("UNIT_AURA");
	if (bar.unit == "target") then
		bar:RegisterEvent("PLAYER_TARGET_CHANGED");
	end
	
	bar:SetScript("OnEvent", OnEvent);
	bar:Show()
end

function CT:DisableAuraBarFrame(bar)
	bar:UnregisterEvent("PLAYER_ENTERING_WORLD");
	bar:UnregisterEvent("UNIT_AURA");
	if (bar.unit == "target") then
		bar:UnregisterEvent("PLAYER_TARGET_CHANGED");
	end
	
	bar:SetScript("OnEvent", nil);
	bar:Hide()
end

function CT:CreateAuraBarFrame(dataSource, parent, objectType)
	local result = CreateFrame("Frame", nil, parent, nil);
	local unit = dataSource:GetUnit();
	
	result.objectType = objectType
	result.unit = unit;
	
	result.lines = {};		
	result.dataSource = dataSource;
				
	result.Render = Render;
	result.SetHiddenHeight = SetHiddenHeight;
		
	return result;
end

local frameAnchors = {}
function CT:FrameCheck(targetFrame, currentFrame)
	for frame, anchor in pairs(frameAnchors) do
		if frame == currentFrame and anchor == targetFrame then
			E:Print(L['You have attempted to anchor a classtimer frame to a frame that is dependant on this classtimer frame, try changing your anchors again.'])
			return false
		end
	end

	return true
end

function CT:GetAnchor(option, frame)
	local anchor, yOffset
	if option == 'PLAYERANCHOR' then
		anchor, yOffset = self.playerFrame, 4
	elseif option == 'PLAYERFRAME' then
		anchor, yOffset = ElvUF_Player, 1
	elseif option == 'PLAYERBUFFS' then
		anchor, yOffset = ElvUF_Player.Buffs, 1
	elseif option == 'PLAYERDEBUFFS' then
		anchor, yOffset = ElvUF_Player.Debuffs, 1
	elseif option == 'TARGETANCHOR' then
		anchor, yOffset = self.targetFrame, 4
	elseif option == 'TARGETFRAME' then
		anchor, yOffset = ElvUF_Target, 1
	elseif option == 'TARGETBUFFS' then
		anchor, yOffset = ElvUF_Target.Buffs, 1
	elseif option == 'TARGETDEBUFFS' then
		anchor, yOffset = ElvUF_Target.Debuffs, 1
	elseif option == 'TRINKETANCHOR' then
		anchor, yOffset = self.trinketFrame, 4
	end
	
	if option == 'PLAYERFRAME' or option == 'TARGETFRAME' then
		frame:SetParent(anchor)
	else
		frame:SetParent(anchor:GetParent())
	end
	
	if anchor:GetParent() then
		frame.unit = anchor.unit or anchor:GetParent().unit or anchor:GetParent():GetParent().unit
	end
	
	frameAnchors[anchor] = frame
	return anchor, yOffset
end

function CT:PositionTimers()
	if not E.private.classtimer.enable or not ElvUF_Player or not ElvUF_Target then return end
	local playerAnchor, playerY = self:GetAnchor(self.db.player.anchor, self.playerFrame)
	local targetAnchor, targetY = self:GetAnchor(self.db.target.anchor, self.targetFrame)
	local trinketAnchor, trinketY = self:GetAnchor(self.db.trinket.anchor, self.trinketFrame)

	if self:FrameCheck(playerAnchor, self.playerFrame) and self.db.player.enable then
		self.playerFrame:ClearAllPoints()
		self.playerFrame:Point("BOTTOMLEFT", playerAnchor, "TOPLEFT", 0, playerY);
		self.playerFrame:Point("BOTTOMRIGHT", playerAnchor, "TOPRIGHT", 0, playerY);	
	end
	
	if self:FrameCheck(trinketFrame, self.trinketFrame) and self.db.trinket.enable then
		self.trinketFrame:ClearAllPoints()
		self.trinketFrame:Point("BOTTOMLEFT", trinketAnchor, "TOPLEFT", 0, trinketY);
		self.trinketFrame:Point("BOTTOMRIGHT", trinketAnchor, "TOPRIGHT", 0, trinketY);
	end
	
	if self:FrameCheck(targetFrame, self.targetFrame) and self.db.target.enable then
		self.targetFrame:ClearAllPoints()		
		self.targetFrame:Point("BOTTOMLEFT", targetAnchor, "TOPLEFT", 0, targetY);
		self.targetFrame:Point("BOTTOMRIGHT", targetAnchor, "TOPRIGHT", 0, targetY);	
	end
end

function CT:ToggleTimers()
	if not E.private.classtimer.enable or not ElvUF_Player or not ElvUF_Target then return end
	if self.db.player.enable then
		self:EnableAuraBarFrame(self.playerFrame)
	else
		self:DisableAuraBarFrame(self.playerFrame)
	end
	
	if self.db.target.enable then
		self:EnableAuraBarFrame(self.targetFrame)
	else
		self:DisableAuraBarFrame(self.targetFrame)
	end	
	
	if self.db.trinket.enable then
		self:EnableAuraBarFrame(self.trinketFrame)
	else
		self:DisableAuraBarFrame(self.trinketFrame)
	end		
end

function CT:UpdateFiltersAndColors()
	self.player:RemoveAllFilters()
	self.target:RemoveAllFilters()
	self.trinket:RemoveAllFilters()
	
	self.target:AddFilter(E.global.classtimer.spells_filter[E.myclass].target, self.db.target.buffcolor, self.db.target.debuffcolor);		
	self.player:AddFilter(E.global.classtimer.spells_filter[E.myclass].player, self.db.player.buffcolor, self.db.player.debuffcolor);
	self.trinket:AddFilter(E.global.classtimer.spells_filter[E.myclass].procs, self.db.trinket.color);
	self.trinket:AddFilter(E.global.classtimer.trinkets_filter, self.db.trinket.color);	
	
	if self.playerFrame then
		OnEvent(self.playerFrame, 'UNIT_AURA', 'player')
		OnEvent(self.targetFrame, 'UNIT_AURA', 'player')
		OnEvent(self.trinketFrame, 'UNIT_AURA', 'player')
	end
end

function CT:Initialize()
	self.db = E.db.classtimer
	if not E.private.classtimer.enable or not ElvUF_Player or not ElvUF_Target then return end

	self.target = self:CreateUnitAuraDataSource("target");
	self.player = self:CreateUnitAuraDataSource("player");
	self.trinket = self:CreateUnitAuraDataSource("player");
	
	self:UpdateFiltersAndColors()
	
	self.playerFrame = self:CreateAuraBarFrame(self.player, ElvUF_Player, 'player');
	self.targetFrame = self:CreateAuraBarFrame(self.target, ElvUF_Target, 'target');		
	self.trinketFrame = self:CreateAuraBarFrame(self.trinket, ElvUF_Player, 'trinket');

	self:PositionTimers()
	self:ToggleTimers()
end

E:RegisterModule(CT:GetName())