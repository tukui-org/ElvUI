--Create a Mover frame

local ElvDB = ElvDB

local myPlayerRealm = GetCVar("realmName")
local myPlayerName  = UnitName("player")

ElvDB.CreatedMovers = {}

local function CreateMover(parent, name, text, overlay, postdrag)
	if not parent then return end --If for some reason the parent isnt loaded yet
	
	if overlay == nil then overlay = true end
	
	if ElvuiData == nil then ElvuiData = {} end
	if ElvuiData.Movers == nil then ElvuiData.Movers = {} end
	if ElvuiData.Movers[myPlayerRealm] == nil then ElvuiData.Movers[myPlayerRealm] = {} end
	if ElvuiData.Movers[myPlayerRealm][myPlayerName] == nil then ElvuiData.Movers[myPlayerRealm][myPlayerName] = {} end
	if ElvuiData.Movers[myPlayerRealm][myPlayerName][name] == nil then ElvuiData.Movers[myPlayerRealm][myPlayerName][name] = {} end
	
	ElvDB.Movers = ElvuiData.Movers[myPlayerRealm][myPlayerName]
	
	local p, p2, p3, p4, p5 = parent:GetPoint()
	
	
	if ElvDB.Movers[name]["moved"] == nil then 
		ElvDB.Movers[name]["moved"] = false 
		
		ElvDB.Movers[name]["p"] = nil
		ElvDB.Movers[name]["p2"] = nil
		ElvDB.Movers[name]["p3"] = nil
		ElvDB.Movers[name]["p4"] = nil
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
	ElvDB.SetTemplate(f2)
	f2:RegisterForDrag("LeftButton", "RightButton")
	f2:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StartMoving() 
	end)
	
	f2:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
		self:StopMovingOrSizing()
	
		ElvDB.Movers[name]["moved"] = true
		local p, _, p2, p3, p4 = self:GetPoint()
		ElvDB.Movers[name]["p"] = p
		ElvDB.Movers[name]["p2"] = p2
		ElvDB.Movers[name]["p3"] = p3
		ElvDB.Movers[name]["p4"] = p4
		
		if postdrag ~= nil and type(postdrag) == 'function' then
			postdrag(self)
		end
	end)	
	
	parent:ClearAllPoints()
	parent:SetAllPoints(f2)	
	parent.ClearAllPoints = ElvDB.dummy
	parent.SetAllPoints = ElvDB.dummy
	parent.SetPoint = ElvDB.dummy
	
	if ElvDB.Movers[name]["moved"] == true then
		f:ClearAllPoints()
		f:SetPoint(ElvDB.Movers[name]["p"], UIParent, ElvDB.Movers[name]["p3"], ElvDB.Movers[name]["p4"], ElvDB.Movers[name]["p5"])
	end
	
	local fs = f2:CreateFontString(nil, "OVERLAY")
	fs:SetFont(ElvCF["media"].font, ElvCF["general"].fontscale, "THINOUTLINE")
	fs:SetShadowOffset(ElvDB.mult*1.2, -ElvDB.mult*1.2)
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	f2:SetFontString(fs)
	f2.text = fs
	
	f2:SetScript("OnEnter", function(self) 
		local color = RAID_CLASS_COLORS[ElvDB.myclass]
		self.text:SetTextColor(color.r, color.g, color.b)
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	end)
	f2:SetScript("OnLeave", function(self)
		self.text:SetTextColor(1, 1, 1)
		self:SetBackdropBorderColor(unpack(ElvCF["media"].bordercolor))
	end)
	
	f2:SetMovable(true)
	f2:Hide()	
	
	if postdrag ~= nil and type(postdrag) == 'function' then
		postdrag(f2)
	end	
end

function ElvDB.CreateMover(parent, name, text, overlay, postdrag)
	local p, p2, p3, p4, p5 = parent:GetPoint()

	if ElvDB.CreatedMovers[name] == nil then 
		ElvDB.CreatedMovers[name] = {}
		ElvDB.CreatedMovers[name]["parent"] = parent
		ElvDB.CreatedMovers[name]["text"] = text
		ElvDB.CreatedMovers[name]["overlay"] = overlay
		ElvDB.CreatedMovers[name]["postdrag"] = postdrag
		ElvDB.CreatedMovers[name]["p"] = p
		ElvDB.CreatedMovers[name]["p2"] = p2 or "UIParent"
		ElvDB.CreatedMovers[name]["p3"] = p3
		ElvDB.CreatedMovers[name]["p4"] = p4
		ElvDB.CreatedMovers[name]["p5"] = p5
	end	
	
	--Post Variables Loaded..
	if ElvuiData ~= nil then
		CreateMover(parent, name, text, overlay, postdrag)
	end
end

function ElvDB.ToggleMovers()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	
	for name, _ in pairs(ElvDB.CreatedMovers) do
		if _G[name]:IsShown() then
			_G[name]:Hide()
		else
			_G[name]:Show()
		end
	end
end

function ElvDB.ResetMovers()
	for name, _ in pairs(ElvDB.CreatedMovers) do
		local n = _G[name]
		_G[name]:ClearAllPoints()
		_G[name]:SetPoint(ElvDB.CreatedMovers[name]["p"], ElvDB.CreatedMovers[name]["p2"], ElvDB.CreatedMovers[name]["p3"], ElvDB.CreatedMovers[name]["p4"], ElvDB.CreatedMovers[name]["p5"])
		
		ElvDB.Movers[name]["moved"] = false 
		
		ElvDB.Movers[name]["p"] = nil
		ElvDB.Movers[name]["p2"] = nil
		ElvDB.Movers[name]["p3"] = nil
		ElvDB.Movers[name]["p4"] = nil	
		
		for key, value in pairs(ElvDB.CreatedMovers[name]) do
			if key == "postdrag" and type(value) == 'function' then
				value(n)
			end
		end
	end	
end

local loadmovers = CreateFrame("Frame")
loadmovers:RegisterEvent("ADDON_LOADED")
loadmovers:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "ElvUI" then return end
	for name, _ in pairs(ElvDB.CreatedMovers) do
		local n = name
		local p, t, o, pd
		for key, value in pairs(ElvDB.CreatedMovers[name]) do
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
end)