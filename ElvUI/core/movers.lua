--Create a Mover frame

local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

E.CreatedMovers = {}

local print = function(...)
	return print('|cff1784d1ElvUI:|r', ...)
end

local function CreateMover(parent, name, text, overlay, postdrag)
	if not parent then return end --If for some reason the parent isnt loaded yet
	
	if overlay == nil then overlay = true end
	
	local p, p2, p3, p4, p5 = parent:GetPoint()
	
	E.Movers = E.SavePath["movers"]
	
	if E.Movers == {} then E.Movers = nil end
	if E.Movers and E.Movers[name] == {} or (E.Movers and E.Movers[name] and E.Movers[name]["moved"] == false) then 
		E.Movers[name] = nil
	end
	
	local f = CreateFrame("Button", name, E.UIParent)
	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	f:SetWidth(parent:GetWidth())
	f:SetHeight(parent:GetHeight())
	
	if overlay == true then
		f:SetFrameStrata("DIALOG")
	else
		f:SetFrameStrata("BACKGROUND")
	end
	if E["Movers"] and E["Movers"][name] then
		f:SetPoint(E["Movers"][name]["p"], E.UIParent, E["Movers"][name]["p2"], E["Movers"][name]["p3"], E["Movers"][name]["p4"])
	else
		f:SetPoint(p, p2, p3, p4, p5)
	end
	f:SetTemplate("Default", true)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving() 
	end)
	
	f:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StopMovingOrSizing()
		
		if not E.SavePath["movers"] then E.SavePath["movers"] = {} end
		
		E.Movers = E.SavePath["movers"]
		
		E.Movers[name] = {}
		local p, _, p2, p3, p4 = self:GetPoint()
		E.Movers[name]["p"] = p
		E.Movers[name]["p2"] = p2
		E.Movers[name]["p3"] = p3
		E.Movers[name]["p4"] = p4
		
		if postdrag ~= nil and type(postdrag) == 'function' then
			postdrag(self)
		end
		
		self:SetUserPlaced(false)
	end)	
	
	parent:ClearAllPoints()
	parent:SetPoint(p3, f, p3, 0, 0)

	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(C["media"].font, C["general"].fontscale, "THINOUTLINE")
	fs:SetShadowOffset(E.mult*1.2, -E.mult*1.2)
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	fs:SetTextColor(unpack(C["media"].valuecolor))
	f:SetFontString(fs)
	f.text = fs
	
	f:SetScript("OnEnter", function(self) 
		self.text:SetTextColor(1, 1, 1)
		self:SetBackdropBorderColor(unpack(C["media"].valuecolor))
	end)
	f:SetScript("OnLeave", function(self)
		self.text:SetTextColor(unpack(C["media"].valuecolor))
		self:SetTemplate("Default", true)
	end)
	
	f:SetMovable(true)
	f:Hide()	
	
	if postdrag ~= nil and type(postdrag) == 'function' then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			postdrag(f)
			self:UnregisterAllEvents()
		end)
	end	
end

function E.CreateMover(parent, name, text, overlay, postdrag)
	local p, p2, p3, p4, p5 = parent:GetPoint()

	if E.CreatedMovers[name] == nil then 
		E.CreatedMovers[name] = {}
		E.CreatedMovers[name]["parent"] = parent
		E.CreatedMovers[name]["text"] = text
		E.CreatedMovers[name]["overlay"] = overlay
		E.CreatedMovers[name]["postdrag"] = postdrag
		E.CreatedMovers[name]["p"] = p
		E.CreatedMovers[name]["p2"] = p2 or "E.UIParent"
		E.CreatedMovers[name]["p3"] = p3
		E.CreatedMovers[name]["p4"] = p4
		E.CreatedMovers[name]["p5"] = p5
	end	
	
	--Post Variables Loaded..
	if ElvuiData ~= nil then
		CreateMover(parent, name, text, overlay, postdrag)
	end
end

function E.ToggleMovers()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	
	for name, _ in pairs(E.CreatedMovers) do
		if _G[name]:IsShown() then
			_G[name]:Hide()
		else
			_G[name]:Show()
		end
	end
end

function E.ResetMovers(arg)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if arg == "" then
		for name, _ in pairs(E.CreatedMovers) do
			local n = _G[name]
			_G[name]:ClearAllPoints()
			_G[name]:SetPoint(E.CreatedMovers[name]["p"], E.CreatedMovers[name]["p2"], E.CreatedMovers[name]["p3"], E.CreatedMovers[name]["p4"], E.CreatedMovers[name]["p5"])
			
			
			E.Movers = nil
			E.SavePath["movers"] = E.Movers
			
			for key, value in pairs(E.CreatedMovers[name]) do
				if key == "postdrag" and type(value) == 'function' then
					value(n)
				end
			end
		end	
	else
		for name, _ in pairs(E.CreatedMovers) do
			for key, value in pairs(E.CreatedMovers[name]) do
				local mover
				if key == "text" then
					if arg == value then 
						_G[name]:ClearAllPoints()
						_G[name]:SetPoint(E.CreatedMovers[name]["p"], E.CreatedMovers[name]["p2"], E.CreatedMovers[name]["p3"], E.CreatedMovers[name]["p4"], E.CreatedMovers[name]["p5"])						
						
						if E.Movers then
							E.Movers[name] = nil
						end
						E.SavePath["movers"] = E.Movers
						
						if E.CreatedMovers[name]["postdrag"] ~= nil and type(E.CreatedMovers[name]["postdrag"]) == 'function' then
							E.CreatedMovers[name]["postdrag"](_G[name])
						end
					end
				end
			end	
		end
	end
end

local function SetMoverButtonScript()
	--Toggle UI lock button
	ElvuiInfoLeftRButton:SetScript("OnMouseDown", function(self)
		if InCombatLockdown() then return end
			
		E.ToggleMovers()
		
		if C["actionbar"].enable == true then
			E.ToggleABLock()
		end

		if ElvUF or oUF then
			E.MoveUF()
		end	
		
		if ElvuiInfoLeftRButton.hovered == true then
			local locked = false
			GameTooltip:ClearLines()
			for name, _ in pairs(E.CreatedMovers) do
				if _G[name]:IsShown() then
					locked = true
				else
					locked = false
				end
			end	
			
			if locked ~= true then
				GameTooltip:AddLine(UNLOCK.." "..BUG_CATEGORY5,1,1,1)
			else
				GameTooltip:AddLine(LOCK.." "..BUG_CATEGORY5,unpack(C["media"].valuecolor))
			end
		end
		GameTooltip:Show()
	end)
	
	ElvuiInfoLeftRButton:SetScript("OnEnter", function(self)
		ElvuiInfoLeftRButton.hovered = true
		if InCombatLockdown() then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, E.Scale(6));
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, E.mult)
		GameTooltip:ClearLines()
		
		local locked = false
		for name, _ in pairs(E.CreatedMovers) do
			if _G[name]:IsShown() then
				locked = true
				break
			else
				locked = false
			end
		end	
		
		if locked ~= true then
			GameTooltip:AddLine(UNLOCK.." "..BUG_CATEGORY5,1,1,1)
		else
			GameTooltip:AddLine(LOCK.." "..BUG_CATEGORY5,unpack(C["media"].valuecolor))
		end
		GameTooltip:Show()
	end)

	ElvuiInfoLeftRButton:SetScript("OnLeave", function(self)
		ElvuiInfoLeftRButton.hovered = false
		GameTooltip:Hide()
	end)	
end

local loadmovers = CreateFrame("Frame")
loadmovers:RegisterEvent("ADDON_LOADED")
loadmovers:RegisterEvent("PLAYER_REGEN_DISABLED")
loadmovers:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon ~= "ElvUI" then return end
		for name, _ in pairs(E.CreatedMovers) do
			local n = name
			local p, t, o, pd
			for key, value in pairs(E.CreatedMovers[name]) do
				if key == "parent" then
					p = value
				elseif key == "text" then
					t = value
				elseif key == "overlay" then
					o = value
				elseif key == "postdrag" then
					pd = value
				end
			end
			CreateMover(p, n, t, o, pd)
		end
		
		SetMoverButtonScript()
		self:UnregisterEvent("ADDON_LOADED")
	else
		local err = false
		for name, _ in pairs(E.CreatedMovers) do
			if _G[name]:IsShown() then
				err = true
				_G[name]:Hide()
			end
		end
			if err == true then
				print(ERR_NOT_IN_COMBAT)			
			end		
	end
end)