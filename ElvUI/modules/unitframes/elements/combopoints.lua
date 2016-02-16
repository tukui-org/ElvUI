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

	CPoints:SetScript("OnShow", UF.ToggleResourceBar)
	CPoints:SetScript("OnHide", UF.ToggleResourceBar)

	return CPoints
end

function UF:Configure_ComboPoints(frame)
	local CPoints = frame.CPoints
	CPoints:ClearAllPoints()
	local db = frame.db
	if not frame.CLASSBAR_DETACHED then
		CPoints:SetParent(frame)
	else
		CPoints:SetParent(E.UIParent)
	end

	if not frame.USE_CLASSBAR or db.combobar.autoHide then
		CPoints:Hide()
	end
	
	local CLASSBAR_WIDTH = frame.CLASSBAR_WIDTH
	if frame.USE_MINI_CLASSBAR and not frame.CLASSBAR_DETACHED then
		CPoints:Point("CENTER", frame.Health.backdrop, "TOP", -(frame.BORDER*3 + 6), -frame.SPACING)
		CPoints:SetFrameStrata("MEDIUM")
		if CPoints.Holder and CPoints.Holder.mover then
			CPoints.Holder.mover:SetScale(0.000001)
			CPoints.Holder.mover:SetAlpha(0)
		end
	elseif not frame.CLASSBAR_DETACHED then
		CPoints:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, (frame.SPACING*3))
		CPoints:SetFrameStrata("LOW")
		if CPoints.Holder and CPoints.Holder.mover then
			CPoints.Holder.mover:SetScale(0.000001)
			CPoints.Holder.mover:SetAlpha(0)
		end
	else
		CLASSBAR_WIDTH = db.combobar.detachedWidth - (frame.BORDER*2)

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
			CPoints.Holder.mover:SetScale(1)
			CPoints.Holder.mover:SetAlpha(1)
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
			CPoints[i]:SetWidth((CLASSBAR_WIDTH - (frame.MAX_CLASS_BAR*(frame.BORDER-frame.SPACING))+(frame.BORDER-frame.SPACING)) / frame.MAX_CLASS_BAR)
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
end

function UF:UpdateComboDisplay(event, unit)
	if (unit == 'pet') then return end
	local cpoints = self.CPoints
	local cp = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and UnitPower('vehicle', 4) or UnitPower('player', 4)
	--Some bosses require the old API and return 0 constantly with the new API (Malygos is one example)
	local cpOldApi = (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) and GetComboPoints('vehicle', 'target') or GetComboPoints('player', 'target')
	if cpOldApi and cp and (cpOldApi > cp) then cp = cpOldApi end
	
	if cp == 0 and self.db.combobar.autoHide then
		cpoints:Hide()
	else
		cpoints:Show()
		for i=1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:SetAlpha(1)
			else
				cpoints[i]:SetAlpha(.2)
			end
		end
	end
end