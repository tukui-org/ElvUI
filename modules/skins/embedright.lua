local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

local AddonPoints = {
	['Recount'] = {},
	['Omen'] = {},
	['Skada'] = {},
}

function S:SaveEmbeddedAddonPoints(addon)
	if not IsAddOnLoaded(addon) then return; end
	
	if addon == 'Recount' then
		local point, _, anchor, x, y = Recount_MainWindow:GetPoint()
		AddonPoints[addon] = {point, UIParent, anchor, x, y}
	elseif addon == 'Omen' then
		local point, _, anchor, x, y = OmenAnchor:GetPoint()
		AddonPoints[addon] = {point, UIParent, anchor, x, y}
	elseif addon == 'Skada' then

	end	
end

--Reset points of previous addon
function S:RemovePrevious(current)
	local lastAddon = self.lastAddon

	if lastAddon == 'Recount' then
		Recount_MainWindow:ClearAllPoints()
		local point, attachTo, anchor, x, y = unpack(AddonPoints[lastAddon])
		Recount_MainWindow:SetPoint(point, attachTo, anchor, x, y)
		Recount:LockWindows(false)
		Recount_MainWindow:SetParent(UIParent)
	elseif lastAddon == 'Omen' then
		OmenAnchor:ClearAllPoints()
		local point, attachTo, anchor, x, y = unpack(AddonPoints[lastAddon])
		OmenAnchor:SetPoint(point, attachTo, anchor, x, y)
		OmenAnchor:SetParent(UIParent)	
		OmenAnchor.SetFrameStrata = OmenAnchor.SetFrameStrataOld
		
		if Omen.db.profile.Locked ~= true then
			Omen.Grip:Show()
			Omen.VGrip1:Show()
			if Omen.db.profile.Bar.ShowTPS then
				Omen.VGrip2:Show()
			else
				Omen.VGrip2:Hide()
			end			
		end
	elseif lastAddon == 'Skada' then
	
	end
end

function S:SetEmbedRight(addon)
	self:RemovePrevious(addon)
	if not IsAddOnLoaded(addon) then return; end
	if self.lastAddon == nil then self.lastAddon = addon; end

	if addon == 'Recount' then
		Recount:LockWindows(true)
		
		Recount_MainWindow:ClearAllPoints()
		Recount_MainWindow:SetPoint("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 0, 4)
		Recount_MainWindow:SetWidth(E.db.core.panelWidth - 10)
		Recount_MainWindow:SetHeight(E.db.core.panelHeight - 26)
		Recount_MainWindow:SetParent(RightChatPanel)	
		self.lastAddon = addon
	elseif addon == 'Omen' then
		Omen.db.profile.Locked = true
		Omen:UpdateGrips()
		if not Omen.oldUpdateGrips then
			Omen.oldUpdateGrips = Omen.UpdateGrips
		end
		Omen.UpdateGrips = function(...)
			local db = Omen.db.profile
			if S.db.embedRight == 'Omen' then
				Omen.VGrip1:ClearAllPoints()
				Omen.VGrip1:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip1, 0)
				Omen.VGrip1:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip1, 0)
				Omen.VGrip2:ClearAllPoints()
				Omen.VGrip2:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip2, 0)
				Omen.VGrip2:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip2, 0)
				Omen.Grip:Hide()
				if db.Locked then
					Omen.VGrip1:Hide()
					Omen.VGrip2:Hide()
				else
					Omen.VGrip1:Show()
					if db.Bar.ShowTPS then
						Omen.VGrip2:Show()
					else
						Omen.VGrip2:Hide()
					end
				end			
			else
				Omen.oldUpdateGrips(...)
			end
		end
		
		if not Omen.oldSetAnchors then
			Omen.oldSetAnchors = Omen.SetAnchors
		end
		Omen.SetAnchors = function(...)
			if S.db.embedRight == 'Omen' then return; end
			Omen.oldSetAnchors(...)
		end
		
		OmenAnchor:ClearAllPoints()
		OmenAnchor:SetPoint("BOTTOMLEFT", RightChatDataPanel, "TOPLEFT", 0, 4)
		
		if E.db.core.panelBackdrop == 'SHOWBOTH' or E.db.core.panelBackdrop == 'SHOWRIGHT' then
			OmenAnchor:SetWidth(E.db.core.panelWidth - 10)
			OmenAnchor:SetHeight(E.db.core.panelHeight - 35)
		else
			OmenAnchor:SetWidth(E.db.core.panelWidth)
			OmenAnchor:SetHeight(E.db.core.panelHeight - 29)		
		end
		
		OmenAnchor:SetParent(RightChatPanel)
		OmenAnchor:SetFrameStrata('LOW')
		if not OmenAnchor.SetFrameStrataOld then
			OmenAnchor.SetFrameStrataOld = OmenAnchor.SetFrameStrata
		end
		OmenAnchor.SetFrameStrata = E.noop
		
		local StartMoving = Omen.Title:GetScript('OnMouseDown')
		local StopMoving = Omen.Title:GetScript('OnMouseUp')
		Omen.Title:SetScript("OnMouseDown", function()
			if S.db.embedRight == 'Omen' then return end
			StartMoving()
		end)
		
		Omen.Title:SetScript("OnMouseUp", function()
			if S.db.embedRight == 'Omen' then return end
			StopMoving()
		end)	

		Omen.BarList:SetScript("OnMouseDown", function()
			if S.db.embedRight == 'Omen' then return end
			StartMoving()
		end)
		
		Omen.BarList:SetScript("OnMouseUp", function()
			if S.db.embedRight == 'Omen' then return end
			StopMoving()
		end)				
		
		self.lastAddon = addon
	elseif addon == 'Skada' then
		self:RemovePrevious(addon)
		
		self.lastAddon = addon
	end
end