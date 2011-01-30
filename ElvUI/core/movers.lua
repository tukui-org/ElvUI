--Create a Mover frame

local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local myPlayerRealm = GetCVar("realmName")
local myPlayerName  = UnitName("player")

DB.CreatedMovers = {}

local print = function(...)
	return print('|cffFF6347ElvUI:|r', ...)
end

local function CreateMover(parent, name, text, overlay, postdrag)
	if not parent then return end --If for some reason the parent isnt loaded yet
	
	if overlay == nil then overlay = true end
	
	if ElvuiData == nil then ElvuiData = {} end
	if ElvuiData.Movers == nil then ElvuiData.Movers = {} end
	if ElvuiData.Movers[myPlayerRealm] == nil then ElvuiData.Movers[myPlayerRealm] = {} end
	if ElvuiData.Movers[myPlayerRealm][myPlayerName] == nil then ElvuiData.Movers[myPlayerRealm][myPlayerName] = {} end
	if ElvuiData.Movers[myPlayerRealm][myPlayerName][name] == nil then ElvuiData.Movers[myPlayerRealm][myPlayerName][name] = {} end
	
	DB.Movers = ElvuiData.Movers[myPlayerRealm][myPlayerName]
	
	local p, p2, p3, p4, p5 = parent:GetPoint()
	
	
	if DB.Movers[name]["moved"] == nil then 
		DB.Movers[name]["moved"] = false 
		
		DB.Movers[name]["p"] = nil
		DB.Movers[name]["p2"] = nil
		DB.Movers[name]["p3"] = nil
		DB.Movers[name]["p4"] = nil
	end
	
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint(p, p2, p3, p4, p5)
	f:SetWidth(parent:GetWidth())
	f:SetHeight(parent:GetHeight())

	local f2 = CreateFrame("Button", name, UIParent)
	f2:SetFrameLevel(parent:GetFrameLevel() + 1)
	f2:SetWidth(parent:GetWidth())
	f2:SetHeight(parent:GetHeight())
	if overlay == true then
		f2:SetFrameStrata("DIALOG")
	else
		f2:SetFrameStrata("BACKGROUND")
	end
	f2:SetPoint("CENTER", f, "CENTER")
	DB.SetTemplate(f2)
	f2:RegisterForDrag("LeftButton", "RightButton")
	f2:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving() 
	end)
	
	f2:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StopMovingOrSizing()
	
		DB.Movers[name]["moved"] = true
		local p, _, p2, p3, p4 = self:GetPoint()
		DB.Movers[name]["p"] = p
		DB.Movers[name]["p2"] = p2
		DB.Movers[name]["p3"] = p3
		DB.Movers[name]["p4"] = p4
		
		if postdrag ~= nil and type(postdrag) == 'function' then
			postdrag(self)
		end
	end)	
	
	parent:ClearAllPoints()
	parent:SetPoint(p3, f2, p3, 0, 0)
	parent.ClearAllPoints = DB.dummy
	parent.SetAllPoints = DB.dummy
	parent.SetPoint = DB.dummy
	
	if DB.Movers[name]["moved"] == true then
		f:ClearAllPoints()
		f:SetPoint(DB.Movers[name]["p"], UIParent, DB.Movers[name]["p3"], DB.Movers[name]["p4"], DB.Movers[name]["p5"])
	end
	
	local fs = f2:CreateFontString(nil, "OVERLAY")
	fs:SetFont(C["media"].font, C["general"].fontscale, "THINOUTLINE")
	fs:SetShadowOffset(DB.mult*1.2, -DB.mult*1.2)
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	f2:SetFontString(fs)
	f2.text = fs
	
	f2:SetScript("OnEnter", function(self) 
		local color = RAID_CLASS_COLORS[DB.myclass]
		self.text:SetTextColor(color.r, color.g, color.b)
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	end)
	f2:SetScript("OnLeave", function(self)
		self.text:SetTextColor(1, 1, 1)
		self:SetBackdropBorderColor(unpack(C["media"].bordercolor))
	end)
	
	f2:SetMovable(true)
	f2:Hide()	
	
	if postdrag ~= nil and type(postdrag) == 'function' then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			postdrag(f2)
			self:UnregisterAllEvents()
		end)
	end	
end

function DB.CreateMover(parent, name, text, overlay, postdrag)
	local p, p2, p3, p4, p5 = parent:GetPoint()

	if DB.CreatedMovers[name] == nil then 
		DB.CreatedMovers[name] = {}
		DB.CreatedMovers[name]["parent"] = parent
		DB.CreatedMovers[name]["text"] = text
		DB.CreatedMovers[name]["overlay"] = overlay
		DB.CreatedMovers[name]["postdrag"] = postdrag
		DB.CreatedMovers[name]["p"] = p
		DB.CreatedMovers[name]["p2"] = p2 or "UIParent"
		DB.CreatedMovers[name]["p3"] = p3
		DB.CreatedMovers[name]["p4"] = p4
		DB.CreatedMovers[name]["p5"] = p5
	end	
	
	--Post Variables Loaded..
	if ElvuiData ~= nil then
		CreateMover(parent, name, text, overlay, postdrag)
	end
end

function DB.ToggleMovers()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	
	for name, _ in pairs(DB.CreatedMovers) do
		if _G[name]:IsShown() then
			_G[name]:Hide()
		else
			_G[name]:Show()
		end
	end
end

function DB.ResetMovers(arg)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if arg == "" then
		for name, _ in pairs(DB.CreatedMovers) do
			local n = _G[name]
			_G[name]:ClearAllPoints()
			_G[name]:SetPoint(DB.CreatedMovers[name]["p"], DB.CreatedMovers[name]["p2"], DB.CreatedMovers[name]["p3"], DB.CreatedMovers[name]["p4"], DB.CreatedMovers[name]["p5"])
			
			DB.Movers[name]["moved"] = false 
			
			DB.Movers[name]["p"] = nil
			DB.Movers[name]["p2"] = nil
			DB.Movers[name]["p3"] = nil
			DB.Movers[name]["p4"] = nil	
			
			for key, value in pairs(DB.CreatedMovers[name]) do
				if key == "postdrag" and type(value) == 'function' then
					value(n)
				end
			end
		end	
	else
		for name, _ in pairs(DB.CreatedMovers) do
			for key, value in pairs(DB.CreatedMovers[name]) do
				local mover
				if key == "text" then
					if arg == value then 
						_G[name]:ClearAllPoints()
						_G[name]:SetPoint(DB.CreatedMovers[name]["p"], DB.CreatedMovers[name]["p2"], DB.CreatedMovers[name]["p3"], DB.CreatedMovers[name]["p4"], DB.CreatedMovers[name]["p5"])						
						
						DB.Movers[name]["moved"] = false 
						
						DB.Movers[name]["p"] = nil
						DB.Movers[name]["p2"] = nil
						DB.Movers[name]["p3"] = nil
						DB.Movers[name]["p4"] = nil	

						if DB.CreatedMovers[name]["postdrag"] ~= nil and type(DB.CreatedMovers[name]["postdrag"]) == 'function' then
							DB.CreatedMovers[name]["postdrag"](_G[name])
						end
					end
				end
			end	
		end
	end
end

local loadmovers = CreateFrame("Frame")
loadmovers:RegisterEvent("ADDON_LOADED")
loadmovers:RegisterEvent("PLAYER_REGEN_DISABLED")
loadmovers:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon ~= "ElvUI" then return end
		for name, _ in pairs(DB.CreatedMovers) do
			local n = name
			local p, t, o, pd
			for key, value in pairs(DB.CreatedMovers[name]) do
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
		
		self:UnregisterEvent("ADDON_LOADED")
	else
		local err = false
		for name, _ in pairs(DB.CreatedMovers) do
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