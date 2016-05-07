local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub("LibSharedMedia-3.0")

local NamePlateDriverMixin = NamePlateDriverMixin

local DefaultCompactUnitFrameOptions = {
	displayNameWhenSelected = false,
	displayNameByPlayerNameRules = true,
}

function NP:IsPlayerEffectivelyTank()
	local assignedRole = UnitGroupRolesAssigned("player");
	if ( assignedRole == "NONE" ) then
		local spec = GetSpecialization();
		return spec and GetSpecializationRole(spec) == "TANK";
	end

	return assignedRole == "TANK";
end


function NP:ApplySettings(plate)
	local statusBarTex = LSM:Fetch("statusbar", self.db.statusbar)
	plate.UnitFrame.healthBar:SetStatusBarTexture(statusBarTex)
	plate.UnitFrame.castBar:SetStatusBarTexture(statusBarTex)
	
	local font, fontSize, fontOutline = LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline
	plate.UnitFrame.name:SetFont(font, fontSize, fontOutline)
	plate.UnitFrame.level:SetFont(font, fontSize, fontOutline)
	
	plate.UnitFrame.name:SetWordWrap(self.db.wrapName)
end

NAMEPLATE_VERTICAL_SCALE = 1.0
NAMEPLATE_HORIZONTAL_SCALE = 1.0
function Test(self)
	DefaultCompactNamePlateEnemyFrameOptions.useClassColors = GetCVarBool("ShowClassColorInNameplate");
	DefaultCompactNamePlateEnemyFrameOptions.playLoseAggroHighlight = GetCVarBool("ShowNamePlateLoseAggroFlash");

	local namePlateVerticalScale = tonumber(NAMEPLATE_VERTICAL_SCALE);
	DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight = 4 * namePlateVerticalScale;

	local zeroBasedScale = namePlateVerticalScale - 1.0;
	local clampedZeroBasedScale = Saturate(zeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.useLargeNameFont = clampedZeroBasedScale > .25;

	DefaultCompactNamePlateFrameSetUpOptions.castBarHeight = math.min(Lerp(12, 16, zeroBasedScale), DefaultCompactNamePlateFrameSetUpOptions.healthBarHeight * 2);
	DefaultCompactNamePlateFrameSetUpOptions.castBarFontHeight = Lerp(8, 12, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.castBarShieldWidth = Lerp(10, 15, clampedZeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.castBarShieldHeight = Lerp(12, 18, clampedZeroBasedScale);

	DefaultCompactNamePlateFrameSetUpOptions.castIconWidth = Lerp(10, 15, clampedZeroBasedScale);
	DefaultCompactNamePlateFrameSetUpOptions.castIconHeight = Lerp(10, 15, clampedZeroBasedScale);

	local horizontalScale = tonumber(NAMEPLATE_HORIZONTAL_SCALE);
	C_NamePlate.SetNamePlateOtherSize(self.baseNamePlateWidth, self.baseNamePlateHeight);

	C_NamePlate.SetNamePlateSelfSize(self.baseNamePlateWidth, self.baseNamePlateHeight);

	for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
		self:ApplyFrameOptions(frame, frame.namePlateUnitToken);
		CompactUnitFrame_UpdateAll(frame.UnitFrame);
	end
end


function NP:NAME_PLATE_CREATED(event, plate)
	local healthBar = plate.UnitFrame.healthBar
	local castBar = plate.UnitFrame.castBar
	local border = plate.UnitFrame.healthBar.border
	border:StripTextures(true)
	self.mult = E.mult * UIParent:GetScale()
	
	plate.UnitFrame.name:ClearAllPoints()
	plate.UnitFrame.name:SetPoint("BOTTOMLEFT", healthBar, "TOPLEFT", 0, 2)
	plate.UnitFrame.name:SetJustifyH("LEFT")
	
	plate.UnitFrame.level = plate.UnitFrame:CreateFontString(nil, 'OVERLAY')
	plate.UnitFrame.level:SetPoint("BOTTOMRIGHT", healthBar, "TOPRIGHT", 0, 2)
	
	plate.UnitFrame.name:SetPoint("BOTTOMRIGHT", plate.UnitFrame.level, "BOTTOMLEFT")

	border.bordertop = border:CreateTexture(nil, "BORDER")
	border.bordertop:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -self.mult, self.mult)
	border.bordertop:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", self.mult, self.mult)
	border.bordertop:SetHeight(self.mult)
	border.bordertop:SetColorTexture(unpack(E["media"].bordercolor))
	border.bordertop:SetDrawLayer("BORDER", 1)

	border.borderbottom = border:CreateTexture(nil, "BORDER")
	border.borderbottom:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", -self.mult, -self.mult)
	border.borderbottom:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", self.mult, -self.mult)
	border.borderbottom:SetHeight(self.mult)
	border.borderbottom:SetColorTexture(unpack(E["media"].bordercolor))
	border.borderbottom:SetDrawLayer("BORDER", 1)

	border.borderleft = border:CreateTexture(nil, "BORDER")
	border.borderleft:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -self.mult, self.mult)
	border.borderleft:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", self.mult, -self.mult)
	border.borderleft:SetWidth(self.mult)
	border.borderleft:SetColorTexture(unpack(E["media"].bordercolor))
	border.borderleft:SetDrawLayer("BORDER", 1)

	border.borderright = border:CreateTexture(nil, "BORDER")
	border.borderright:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", self.mult, self.mult)
	border.borderright:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", -self.mult, -self.mult)
	border.borderright:SetWidth(self.mult)
	border.borderright:SetColorTexture(unpack(E["media"].bordercolor))
	border.borderright:SetDrawLayer("BORDER", 1)

	self:ApplySettings(plate)
end

function NP:NAME_PLATE_REMOVED(even, plate)

end

function NP:NAME_PLATE_UNIT_ADDED(event, unit)
	--Name
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	--plate:SetTemplate()
	if(plate.UnitFrame.optionTable.displayNameWhenSelected) then
		plate.UnitFrame.optionTable.displayNameWhenSelected = false
		plate.UnitFrame.optionTable.displayName = true
		plate.UnitFrame.optionTable.displayNameByPlayerNameRules = false
		CompactUnitFrame_UpdateName(plate.UnitFrame)
	end

	--Level
	local level = UnitLevel(unit)
	if level == UnitLevel("player") then
		plate.UnitFrame.level:SetText("")
	elseif level == -1 then
		plate.UnitFrame.level:SetText('??')
		plate.UnitFrame.level:SetTextColor(0.9, 0, 0)	
	else
		local color = GetQuestDifficultyColor(level)
		plate.UnitFrame.level:SetText(level)
		plate.UnitFrame.level:SetTextColor(color.r, color.g, color.b)
	end

end

function NP:NAME_PLATE_UNIT_REMOVED(event, unit)

end

function NP:UpdateNameColor()
	local r, g, b;
	if ( not UnitIsConnected(self.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		if ( self.optionTable.healthBarColorOverride ) then
			local healthBarColorOverride = self.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
		else
			--Try to color it by class.
			local localizedClass, englishClass = UnitClass(self.unit);
			local classColor = RAID_CLASS_COLORS[englishClass];
			if ( UnitIsPlayer(self.unit) and classColor and self.optionTable.useClassColors ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( CompactUnitFrame_IsTapDenied(self) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = 0.1, 0.1, 0.1;
			elseif ( self.optionTable.colorHealthBySelection ) then
				-- Use color based on the type of unit (neutral, etc.)
				if ( self.optionTable.considerSelectionInCombatAsHostile and UnitAffectingCombat(self.unit)) then
					if(CompactUnitFrame_IsOnThreatListWithPlayer(self.displayedUnit)) then
						if(NP:IsPlayerEffectivelyTank()) then
							r, g, b = 0.0, 1.0, 0.0;
						else
							r, g, b = 1.0, 0.0, 0.0;
						end
					else
						if(NP:IsPlayerEffectivelyTank()) then
							r, g, b = 1.0, 0.0, 0.0;
						else
							r, g, b = 0.0, 1.0, 0.0;
						end					
					end
				else
					r, g, b = UnitSelectionColor(self.unit, self.optionTable.colorHealthWithExtendedColors);
				end
			elseif ( UnitIsFriend("player", self.unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	end
	if ( r ~= self.healthBar.r or g ~= self.healthBar.g or b ~= self.healthBar.b ) then
		self.healthBar:SetStatusBarColor(r, g, b);

		if (self.optionTable.colorHealthWithExtendedColors) then
			self.selectionHighlight:SetVertexColor(r, g, b);
		else
			self.selectionHighlight:SetVertexColor(1, 1, 1);
		end
		
		self.healthBar.r, self.healthBar.g, self.healthBar.b = r, g, b;
	end
end

function NP:EventHook(event)
	if event == "UNIT_THREAT_SITUATION_UPDATE" then
		if ( self.optionTable.considerSelectionInCombatAsHostile ) then
			NP:UpdateNameColor(self)
		end	
	end
end

function NP:Initialize()
	self.db = E.db["nameplate"]
	if E.private["nameplate"].enable ~= true then return end
	E.NamePlates = NP
	
	self:RegisterEvent("NAME_PLATE_CREATED")
	self:RegisterEvent("NAME_PLATE_REMOVED")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	
	--hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", Test)
	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", NP.UpdateNameColor)
	hooksecurefunc("CompactUnitFrame_OnEvent", NP.EventHook)
end


E:RegisterModule(NP:GetName())