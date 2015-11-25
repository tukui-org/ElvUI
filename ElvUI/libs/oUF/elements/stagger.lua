local parent, ns = ...
local oUF = ns.oUF

oUF.colors.Stagger = {.52, 1, .52, 1, .98, .22, 1, .42, .42}

local staggerSpells = {
	[GetSpellInfo(124275)] = true,
	[GetSpellInfo(124274)] = true,
	[GetSpellInfo(124273)] = true,
}

local function UpdateMaxValues(self)
	local stagger = self.Stagger
	if(stagger) then
		local maxhealth = UnitHealthMax("player");
		stagger:SetMinMaxValues(0, maxhealth);
	end
end

local function OnEnter(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetUnitAura("player", self.spellName, self.rank, "HARMFUL")
	self.isMoused = true
end

local function OnLeave(self)
	GameTooltip:Hide()
	self.isMoused = nil
end

local Update = function(self, elapsed)
	local stagger = self.Stagger or self

	if(stagger) then
		--if(stagger.elapsed and stagger.elapsed > 0.2) then
			local curStagger = UnitStagger("player") or 0;
			local _, maxStagger = stagger:GetMinMaxValues();
			
			stagger:SetValue(curStagger);

			local r, g, b = oUF.ColorGradient(curStagger, maxStagger, unpack(oUF.colors.Stagger))
			stagger:SetStatusBarColor(r, g, b);

			if stagger.isMoused then
				OnEnter(stagger)
			end
		--[[	stagger.elapsed = 0
		elseif elapsed then
			stagger.elapsed = (stagger.elapsed or 0) + elapsed
		end]]
	end
end

local function CheckAuras(self)
	local staggerExists = false
	
	local index = 1
	local spellName, rank = UnitDebuff("player", index)
	while spellName do
		if staggerSpells[spellName] then
			staggerExists = true
			self.rank = rank
			self.spellName = spellName
		end
		index = index + 1
		spellName, rank = UnitDebuff("player", index)
	end
	
	return staggerExists
end

local function UpdatePowerType(self)
	local stagger = self.Stagger
	if(stagger) then
		if ( stagger.class == "MONK" and stagger.specRestriction == GetSpecialization() and not UnitHasVehiclePlayerFrameUI("player") and CheckAuras(stagger) ) then
			stagger:Show();
		else
			stagger:Hide();
		end

		if(stagger.PostUpdate) then
			stagger:PostUpdate()
		end		
	end
end

local function OnEvent(self, event, arg1)
	local stagger = self.Stagger
	if ( event == "UNIT_DISPLAYPOWER" or event == "UPDATE_VEHICLE_ACTIONBAR" ) then
		UpdatePowerType(self);
	elseif ( (event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UNIT_AURA") and arg1 == self.unit ) then
		UpdatePowerType(self);
	elseif ( event == "UNIT_MAXHEALTH" and arg1 == self.unit ) then
		UpdateMaxValues(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		stagger.specRestriction = SPEC_MONK_BREWMASTER;
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", OnEvent);
		UpdateMaxValues(self);
		UpdatePowerType(self);
	end
end

--Bugfix: http://git.tukui.org/Elv/elvui/issues/526
local enteredWorld = false
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	enteredWorld = true
end)

local Enable = function(self, unit)
	local stagger = self.Stagger
	if(stagger) then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent);
		self:RegisterEvent("UNIT_DISPLAYPOWER", OnEvent);
		self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", OnEvent);
		self:RegisterEvent("UNIT_MAXHEALTH", OnEvent)
		self:RegisterEvent("UNIT_AURA", OnEvent)
		
		if not stagger:GetScript("OnUpdate") then
			stagger:SetScript("OnUpdate", Update)
			stagger:SetScript("OnEnter", OnEnter)
			stagger:SetScript("OnLeave", OnLeave)
		end
		
		if not stagger.class then
			stagger.class = select(2, UnitClass("player"))
		end
		
		--Bugfix: http://git.tukui.org/Elv/elvui/issues/526
		if enteredWorld and not self:IsEventRegistered("PLAYER_SPECIALIZATION_CHANGED") then
			stagger.specRestriction = SPEC_MONK_BREWMASTER;
			self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", OnEvent);
			UpdateMaxValues(self);
			UpdatePowerType(self);
		end
		UpdatePowerType(self)
		return true
	end
end

local Disable = function(self)
	local stagger = self.Stagger
	if(stagger) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", OnEvent);
		self:UnregisterEvent("UNIT_DISPLAYPOWER", OnEvent);
		self:UnregisterEvent("UPDATE_VEHICLE_ACTIONBAR", OnEvent);
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", OnEvent);
		self:UnregisterEvent("UNIT_AURA", OnEvent)
		self:UnregisterEvent("UNIT_MAXHEALTH", OnEvent)
		stagger:Hide()
	end
end

oUF:AddElement('Stagger', Update, Enable, Disable)