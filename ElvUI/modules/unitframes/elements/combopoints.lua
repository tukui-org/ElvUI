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
	CPoints:CreateBackdrop('Default', nil, nil, UF.thinBorders)
	CPoints.Override = UF.UpdateComboDisplay
	CPoints.origParent = frame

	for i = 1, MAX_COMBO_POINTS do
		CPoints[i] = CreateFrame("StatusBar", frame:GetName().."ComboBarButton"..i, CPoints)
		UF['statusbars'][CPoints[i]] = true
		CPoints[i]:SetStatusBarTexture(E['media'].blankTex)
		CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
		CPoints[i]:SetAlpha(0.15)
		CPoints[i]:CreateBackdrop('Default', nil, nil, UF.thinBorders)
		CPoints[i].backdrop:SetParent(CPoints)
	end

	CPoints:SetScript("OnShow", UF.ToggleResourceBar)
	CPoints:SetScript("OnHide", UF.ToggleResourceBar)

	return CPoints
end

function UF:Configure_ComboPoints(frame)
	local CPoints = frame.CPoints
	CPoints:ClearAllPoints()
	local db = frame.db
	if not frame.CLASSBAR_DETACHED then
		E.FrameLocks[CPoints] = nil
		CPoints:SetParent(frame)
	else
		E.FrameLocks[CPoints] = true
		CPoints:SetParent(E.UIParent)
	end

	--Fix height in case it is lower than the theme allows
	if (not self.thinBorders and not E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 7 then --A height of 7 means 6px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 7
		if db.combobar then db.combobar.height = 7 end
		UF.ToggleResourceBar(CPoints)  --Trigger update to health if needed
	elseif (self.thinBorders or E.PixelMode) and frame.CLASSBAR_HEIGHT > 0 and frame.CLASSBAR_HEIGHT < 3 then --A height of 3 means 2px for borders and just 1px for the actual power statusbar
		frame.CLASSBAR_HEIGHT = 3
		if db.combobar then db.combobar.height = 3 end
		UF.ToggleResourceBar(CPoints)  --Trigger update to health if needed
	end

	if not frame.USE_CLASSBAR then
		CPoints:Hide()
	end

	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH
	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		CPoints:Point("CENTER", frame.Health.backdrop, "TOP", 0, 0)
		CLASSBAR_WIDTH = CLASSBAR_WIDTH * (frame.MAX_CLASS_BAR - 1) / frame.MAX_CLASS_BAR
		CPoints:SetFrameStrata("MEDIUM")
		if CPoints.Holder and CPoints.Holder.mover then
			E:DisableMover(CPoints.Holder.mover:GetName())
		end
	elseif not frame.CLASSBAR_DETACHED then
		CPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, (frame.SPACING*3))
		CPoints:SetFrameStrata("LOW")
		if CPoints.Holder and CPoints.Holder.mover then
			E:DisableMover(CPoints.Holder.mover:GetName())
		end
	else
		CLASSBAR_WIDTH = db.combobar.detachedWidth - ((frame.BORDER+frame.SPACING)*2)

		if not CPoints.Holder or (CPoints.Holder and not CPoints.Holder.mover) then
			CPoints.Holder = CreateFrame("Frame", nil, CPoints)
			CPoints.Holder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
			CPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height)
			CPoints:Width(CLASSBAR_WIDTH)
			CPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))
			CPoints:ClearAllPoints()
			CPoints:Point("BOTTOMLEFT", CPoints.Holder, "BOTTOMLEFT", frame.BORDER + frame.SPACING, frame.BORDER + frame.SPACING)
			E:CreateMover(CPoints.Holder, 'ComboBarMover', L["Combobar"], nil, nil, nil, 'ALL,SOLO')
		else
			CPoints.Holder:Size(db.combobar.detachedWidth, db.combobar.height)
			CPoints:ClearAllPoints()
			CPoints:Point("BOTTOMLEFT", CPoints.Holder.mover, "BOTTOMLEFT", frame.BORDER+frame.SPACING, frame.BORDER+frame.SPACING)
			E:EnableMover(CPoints.Holder.mover:GetName())
		end

		CPoints:SetFrameStrata("LOW")
	end

	CPoints:Width(CLASSBAR_WIDTH)
	CPoints:Height(frame.CLASSBAR_HEIGHT - ((frame.BORDER + frame.SPACING)*2))

	for i = 1, frame.MAX_CLASS_BAR do
		CPoints[i]:SetStatusBarColor(unpack(ElvUF.colors.ComboPoints[i]))
		CPoints[i]:Height(CPoints:GetHeight())
		if frame.USE_MINI_CLASSBAR then
			CPoints[i]:SetWidth((CLASSBAR_WIDTH - ((5 + (frame.BORDER*2 + frame.SPACING*2))*(frame.MAX_CLASS_BAR - 1)))/frame.MAX_CLASS_BAR) --Width accounts for 5px spacing between each button, excluding borders
		elseif i ~= MAX_COMBO_POINTS then
			CPoints[i]:Width((CLASSBAR_WIDTH - ((frame.MAX_CLASS_BAR-1)*(frame.BORDER-frame.SPACING))) / frame.MAX_CLASS_BAR) --classbar width minus total width of dividers between each button, divided by number of buttons
		end

		CPoints[i]:ClearAllPoints()
		if i == 1 then
			CPoints[i]:Point("LEFT", CPoints)
		else
			if frame.USE_MINI_CLASSBAR then
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", (5 + frame.BORDER*2 + frame.SPACING*2), 0)
			elseif i == frame.MAX_CLASS_BAR then
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
				CPoints[i]:Point("RIGHT", CPoints)
			else
				CPoints[i]:Point("LEFT", CPoints[i-1], "RIGHT", frame.BORDER-frame.SPACING, 0)
			end
		end

		if not frame.USE_MINI_CLASSBAR then
			CPoints[i].backdrop:Hide()
		else
			CPoints[i].backdrop:Show()
		end
	end

	if not frame.USE_MINI_CLASSBAR then
		CPoints.backdrop:Show()
	else
		CPoints.backdrop:Hide()
	end

	if frame.USE_CLASSBAR and not frame:IsElementEnabled('CPoints') then
		frame:EnableElement('CPoints')
	elseif not frame.USE_CLASSBAR and frame:IsElementEnabled('CPoints') then
		frame:DisableElement('CPoints')
		CPoints:Hide()
	end

	--OnHide will not execute if Target Frame is not shown (logging in / reloading), so force an update
	if not frame:IsShown() then
		CPoints:ForceUpdate()
	end
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == 'pet') then return end
	local db = self.db
	if not db then return; end

	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and UnitPower('vehicle', 4) or UnitPower('player', 4)
	--Some bosses require the old API and return 0 constantly with the new API (Malygos is one example)
	local cpOldApi = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints('vehicle', 'target') or GetComboPoints('player', 'target')
	if cpOldApi and cp and (cpOldApi > cp) then cp = cpOldApi end

	if cp == 0 and db.combobar.autoHide then
		cpoints:Hide()
		UF.ToggleResourceBar(cpoints) --Call update manually too, as the OnShow/OnHide will not execute if there is currently no target
	else
		cpoints:Show()
		for i=1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:SetAlpha(1)
			else
				cpoints[i]:SetAlpha(.2)
			end
		end
		UF.ToggleResourceBar(cpoints)
	end
end