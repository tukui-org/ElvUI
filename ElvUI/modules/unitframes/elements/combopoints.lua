local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitPower = UnitPower
local GetComboPoints = GetComboPoints
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function UF:Construct_Combobar(frame)
	local CPoints = CreateFrame("Frame", nil, frame)
	CPoints:CreateBackdrop('Default')
	CPoints.Override = UF.UpdateComboDisplay

	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", frame:GetName().."ComboBarButton"..i, CPoints)
		UF['statusbars'][CPoints[i]] = true
		CPoints[i]:SetStatusBarTexture(E['media'].blankTex)
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		CPoints[i]:SetAlpha(0.15)
		CPoints[i]:CreateBackdrop('Default')
		CPoints[i].backdrop:SetParent(CPoints)
	end

	return CPoints
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == 'pet') then return end
	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and UnitPower('vehicle', 4) or UnitPower('player', 4)
	--Some bosses require the old API and return 0 constantly with the new API (Malygos is one example)
	local cpOldApi = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints('vehicle', 'target') or GetComboPoints('player', 'target')
	if cpOldApi and cp and (cpOldApi > cp) then cp = cpOldApi end

	for i=1, MAX_COMBO_POINTS do
		if(i <= cp) then
			cpoints[i]:SetAlpha(1)
		else
			cpoints[i]:SetAlpha(.15)
		end
	end

	local BORDER = E.Border;
	local SPACING = E.Spacing;
	local db = E.db['unitframe']['units'].target
	local USE_COMBOBAR = db.combobar.enable
	local USE_MINI_COMBOBAR = db.combobar.fill == "spaced" and USE_COMBOBAR and not db.combobar.detachFromFrame
	local COMBOBAR_HEIGHT = db.combobar.height
	local USE_PORTRAIT = db.portrait.enable
	local USE_PORTRAIT_OVERLAY = db.portrait.overlay and USE_PORTRAIT
	local PORTRAIT_WIDTH = db.portrait.width
	local PORTRAIT_OFFSET_Y = ((COMBOBAR_HEIGHT/2) + SPACING - BORDER)
	local HEALTH_OFFSET_Y
	local DETACHED = db.combobar.detachFromFrame

	if not self.Portrait then
		self.Portrait = db.portrait.style == '2D' and self.Portrait2D or self.Portrait3D
	end

	if USE_PORTRAIT_OVERLAY or not USE_PORTRAIT then
		PORTRAIT_WIDTH = 0
	end

	if DETACHED then
		PORTRAIT_OFFSET_Y = 0
	end

	if cpoints[1]:GetAlpha() == 1 or not db.combobar.autoHide then
		cpoints:Show()
		if USE_MINI_COMBOBAR then
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + (COMBOBAR_HEIGHT/2))
			self.Portrait.backdrop:Point("TOPRIGHT", self, "TOPRIGHT", 0, -PORTRAIT_OFFSET_Y)
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -HEALTH_OFFSET_Y)
		else
			HEALTH_OFFSET_Y = DETACHED and 0 or (SPACING + COMBOBAR_HEIGHT)
			self.Portrait.backdrop:Point("TOPRIGHT", self, "TOPRIGHT")
			self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -(BORDER + HEALTH_OFFSET_Y))
		end
	else
		cpoints:Hide()
		self.Portrait.backdrop:Point("TOPRIGHT", self, "TOPRIGHT")
		self.Health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+PORTRAIT_WIDTH), -BORDER)
	end
end