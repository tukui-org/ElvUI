local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local select, unpack = select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local FAILED = FAILED
local INTERRUPTED = INTERRUPTED

function mod:UpdateElement_CastBarOnUpdate(elapsed)
	if ( self.casting ) then
		self.value = self.value + elapsed;
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			self:Hide()
			return;
		end
		self:SetValue(self.value);
		self.Time:SetFormattedText("%.1f ", self.value)
		if ( self.Spark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);
		end
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			self:Hide()
			return;
		end
		self:SetValue(self.value);
		self.Time:SetFormattedText("%.1f ", self.value)
	end
end

function mod:UpdateElement_Cast(frame, event, ...)
	if(self.db.units[frame.UnitType].castbar.enable ~= true) then return end

	local arg1 = ...;
	local unit = frame.displayedUnit
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel = UnitChannelInfo(unit);
		local nameSpell = UnitCastingInfo(unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = unit;
		else
		    frame.CastBar:Hide()
		end
	end

	if ( arg1 ~= unit ) then
		return;
	end

	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
		if ( not name) then
			frame.CastBar:Hide();
			return;
		end

		frame.CastBar.canInterrupt = not notInterruptible

		if ( frame.CastBar.Spark ) then
			frame.CastBar.Spark:Show();
		end
		frame.CastBar.Name:SetText(name)
		frame.CastBar.value = (GetTime() - (startTime / 1000));
		frame.CastBar.maxValue = (endTime - startTime) / 1000;
		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
		frame.CastBar:SetValue(frame.CastBar.value);
		if ( frame.CastBar.Text ) then
			frame.CastBar.Text:SetText(text);
		end
		if ( frame.CastBar.Icon ) then
			frame.CastBar.Icon.texture:SetTexture(texture);
		end

		frame.CastBar.casting = true;
		frame.CastBar.castID = castID;
		frame.CastBar.channeling = nil;

		frame.CastBar:Show()
	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
		if ( not frame.CastBar:IsVisible() ) then
			frame.CastBar:Hide();
		end
		if ( (frame.CastBar.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == frame.CastBar.castID) or
		     (frame.CastBar.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
			if ( frame.CastBar.Spark ) then
				frame.CastBar.Spark:Hide();
			end

			frame.CastBar:SetValue(frame.CastBar.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
				frame.CastBar.casting = nil;
			else
				frame.CastBar.channeling = nil;
			end
			frame.CastBar.canInterrupt = nil
			frame.CastBar:Hide()
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( frame.CastBar:IsShown() and (frame.CastBar.casting and select(4, ...) == frame.CastBar.castID) ) then
			frame.CastBar:SetValue(frame.CastBar.maxValue);
			if ( frame.CastBar.Spark ) then
				frame.CastBar.Spark:Hide();
			end
			if ( frame.CastBar.Text ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					frame.CastBar.Text:SetText(FAILED);
				else
					frame.CastBar.Text:SetText(INTERRUPTED);
				end
			end
			frame.CastBar.casting = nil;
			frame.CastBar.channeling = nil;
			frame.CastBar.canInterrupt = nil
			frame.CastBar:Hide()
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( frame:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
			if ( not name ) then
				-- if there is no name, there is no bar
				frame.CastBar:Hide();
				return;
			end
			frame.canInterrupt = not notInterruptible
			frame.CastBar.Name:SetText(name)
			frame.CastBar.value = (GetTime() - (startTime / 1000));
			frame.CastBar.maxValue = (endTime - startTime) / 1000;
			frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
			frame.CastBar.canInterrupt = not notInterruptible
			if ( not frame.CastBar.casting ) then
				if ( frame.CastBar.Spark ) then
					frame.CastBar.Spark:Show();
				end

				frame.CastBar.casting = true;
				frame.CastBar.channeling = nil;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit);
		if ( not name) then
			frame.CastBar:Hide();
			return;
		end

		frame.CastBar.Name:SetText(name)
		frame.CastBar.value = (endTime / 1000) - GetTime();
		frame.CastBar.maxValue = (endTime - startTime) / 1000;
		frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
		frame.CastBar:SetValue(frame.CastBar.value);

		if ( frame.CastBar.Text ) then
			frame.CastBar.Text:SetText(text);
		end
		if ( frame.CastBar.Icon ) then
			frame.CastBar.Icon.texture:SetTexture(texture);
		end
		if ( frame.CastBar.Spark ) then
			frame.CastBar.Spark:Hide();
		end
		frame.CastBar.canInterrupt = not notInterruptible
		frame.CastBar.casting = nil;
		frame.CastBar.channeling = true;

		frame.CastBar:Show();
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		if ( frame.CastBar:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
			if ( not name ) then
				frame.CastBar:Hide();
				return;
			end
			frame.CastBar.Name:SetText(name)
			frame.CastBar.value = ((endTime / 1000) - GetTime());
			frame.CastBar.maxValue = (endTime - startTime) / 1000;
			frame.CastBar:SetMinMaxValues(0, frame.CastBar.maxValue);
			frame.CastBar:SetValue(frame.CastBar.value);
		end
	elseif ( event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then
		frame.CastBar.canInterrupt = true
	elseif ( event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
		frame.CastBar.canInterrupt = nil
	end

	if(frame.CastBar.canInterrupt) then
		frame.CastBar:SetStatusBarColor(self.db.castColor.r, self.db.castColor.g, self.db.castColor.b)
	else
		frame.CastBar:SetStatusBarColor(self.db.castNoInterruptColor.r, self.db.castNoInterruptColor.g, self.db.castNoInterruptColor.b)
	end
	frame.CastBar.canInterrupt = nil

	if(self.db.classbar.enable and self.db.classbar.position == "BELOW") then
		self:ClassBar_Update(frame)
	end
end

function mod:ConfigureElement_CastBar(frame)
	local castBar = frame.CastBar

	--Position
	castBar:ClearAllPoints()
	if(self.db.units[frame.UnitType].powerbar.enable) then
		castBar:SetPoint("TOPLEFT", frame.PowerBar, "BOTTOMLEFT", 0, -E.Border - E.Spacing*3)
		castBar:SetPoint("TOPRIGHT", frame.PowerBar, "BOTTOMRIGHT", 0, -E.Border - E.Spacing*3)
	else
		castBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -E.Border - E.Spacing*3)
		castBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -E.Border - E.Spacing*3)
	end
	castBar:SetHeight(self.db.units[frame.UnitType].castbar.height)

	castBar.Icon:SetPoint("TOPLEFT", frame.HealthBar, "TOPRIGHT", E.Border + E.Spacing*3, 0)
	castBar.Icon:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", E.Border + E.Spacing*3, 0)
	if(self.db.units[frame.UnitType].powerbar.enable) then
		castBar.Icon:SetWidth(self.db.units[frame.UnitType].castbar.height + self.db.units[frame.UnitType].healthbar.height + self.db.units[frame.UnitType].powerbar.height + mod.mult + E.Border + E.Spacing*3)
	else
		castBar.Icon:SetWidth(self.db.units[frame.UnitType].castbar.height + self.db.units[frame.UnitType].healthbar.height + E.Border + E.Spacing*3)
	end
	castBar.Icon.texture:SetTexCoord(unpack(E.TexCoords))

	castBar.Time:SetPoint("TOPRIGHT", castBar, "BOTTOMRIGHT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, -E.Border*3)
	castBar.Name:SetPoint("TOPRIGHT", castBar.Time, "TOPLEFT")

	castBar.Name:SetJustifyH("LEFT")
	castBar.Name:SetJustifyV("TOP")
	castBar.Name:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
	castBar.Time:SetJustifyH("RIGHT")
	castBar.Time:SetJustifyV("TOP")
	castBar.Time:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)

	if (self.db.units[frame.UnitType].castbar.hideSpellName) then
		castBar.Name:Hide()
	else
		castBar.Name:Show()
	end
	if (self.db.units[frame.UnitType].castbar.hideTime) then
		castBar.Time:Hide()
	else
		castBar.Time:Show()
	end

	--Texture
	castBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function mod:ConstructElement_CastBar(parent)
	local frame = CreateFrame("StatusBar", "$parentCastBar", parent)
	self:StyleFrame(frame)
	frame:SetScript("OnUpdate", mod.UpdateElement_CastBarOnUpdate)

	frame.Icon = CreateFrame("Frame", nil, frame)
	frame.Icon.texture = frame.Icon:CreateTexture(nil, "BORDER")
	frame.Icon.texture:SetAllPoints()
	self:StyleFrame(frame.Icon)

	frame.Name = frame:CreateFontString(nil, "OVERLAY")
	frame.Name:SetWordWrap(false)
	frame.Time = frame:CreateFontString(nil, "OVERLAY")
	frame.Time:SetWordWrap(false)
	frame.Spark = frame:CreateTexture(nil, "OVERLAY")
	frame.Spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	frame.Spark:SetBlendMode("ADD")
	frame.Spark:SetSize(15, 15)
	frame:Hide()
	return frame
end