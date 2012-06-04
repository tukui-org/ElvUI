local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Sticky = LibStub("LibSimpleSticky-1.0")

E.CreatedMovers = {}

local function SizeChanged(frame)
	frame.mover:Size(frame:GetSize())
end

local function GetPoint(obj)
	local point, anchor, secondaryPoint, x, y = obj:GetPoint()
	if not anchor then anchor = UIParent end
	
	return string.format('%s\031%s\031%s\031%d\031%d', point, anchor:GetName(), secondaryPoint, x, y)
end

local function CreateMover(parent, name, text, overlay, snapOffset, postdrag)
	if not parent then return end --If for some reason the parent isnt loaded yet
	if E.CreatedMovers[name].Created then return end
	
	if overlay == nil then overlay = true end
	local point, anchor, secondaryPoint, x, y = string.split('\031', GetPoint(parent))
	local f = CreateFrame("Button", name, E.UIParent)
	f:SetFrameLevel(parent:GetFrameLevel() + 1)
	f:SetClampedToScreen(true)
	f:SetWidth(parent:GetWidth())
	f:SetHeight(parent:GetHeight())
	f.parent = parent
	f.name = name
	f.textSting = text
	f.postdrag = postdrag
	f.overlay = overlay
	f.snapOffset = snapOffset or -2
	E.CreatedMovers[name].mover = f
	
	tinsert(E['snapBars'], f)
	
	if overlay == true then
		f:SetFrameStrata("DIALOG")
	else
		f:SetFrameStrata("BACKGROUND")
	end
	
	if E.db['movers'] and E.db['movers'][name] then
		if type(E.db['movers'][name]) == 'table' then
			f:SetPoint(E.db["movers"][name]["p"], UIParent, E.db["movers"][name]["p2"], E.db["movers"][name]["p3"], E.db["movers"][name]["p4"])
			E.db['movers'][name] = GetPoint(f)
			f:ClearAllPoints()
		end
		
		local point, anchor, secondaryPoint, x, y = string.split('\031', E.db['movers'][name])
		f:SetPoint(point, anchor, secondaryPoint, x, y)
	else

		f:SetPoint(point, anchor, secondaryPoint, x, y)
	end
	f:SetTemplate("Default", true)
	f:RegisterForDrag("LeftButton", "RightButton")
	f:SetScript("OnDragStart", function(self) 
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end	

		if E.db['general'].stickyFrames then
			Sticky:StartMoving(self, E['snapBars'], f.snapOffset, f.snapOffset, f.snapOffset, f.snapOffset)
		else
			self:StartMoving() 
		end
	end)
	
	f:SetScript("OnDragStop", function(self) 
		if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
		if E.db['general'].stickyFrames then
			Sticky:StopMoving(self)
		else
			self:StopMovingOrSizing()
		end
		
		E:SaveMoverPosition(name)
		
		if postdrag ~= nil and type(postdrag) == 'function' then
			postdrag(self, E:GetScreenQuadrant(self))
		end

		self:SetUserPlaced(false)
	end)	
	
	parent:SetScript('OnSizeChanged', SizeChanged)
	parent.mover = f
	parent:ClearAllPoints()

	parent:SetPoint(point, f, 0, 0)
	
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate()
	fs:SetJustifyH("CENTER")
	fs:SetPoint("CENTER")
	fs:SetText(text or name)
	fs:SetTextColor(unpack(E["media"].rgbvaluecolor))
	f:SetFontString(fs)
	f.text = fs
	
	f:SetScript("OnEnter", function(self) 
		self.text:SetTextColor(1, 1, 1)
		self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
	end)
	f:SetScript("OnLeave", function(self)
		self.text:SetTextColor(unpack(E["media"].rgbvaluecolor))
		self:SetTemplate("Default", true)
	end)
	
	f:SetMovable(true)
	f:Hide()	
	
	if postdrag ~= nil and type(postdrag) == 'function' then
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(self, event)
			postdrag(f, E:GetScreenQuadrant(f))
			self:UnregisterAllEvents()
		end)
	end	
	
	E.CreatedMovers[name].Created = true;
end

function E:HasMoverBeenMoved(name)
	if E.db["movers"] and E.db["movers"][name] then
		return true
	else
		return false
	end
end

function E:SaveMoverPosition(name)
	if not _G[name] then return end
	if not E.db.movers then E.db.movers = {} end

	E.db.movers[name] = GetPoint(_G[name])
end

function E:SetMoverSnapOffset(name, offset)
	if not _G[name] or not E.CreatedMovers[name] then return end
	E.CreatedMovers[name].mover.snapOffset = offset or -2
	E.CreatedMovers[name]["snapoffset"] = offset or -2
end

function E:SaveMoverDefaultPosition(name)
	if not _G[name] then return end

	E.CreatedMovers[name]["point"] = GetPoint(_G[name])
	E.CreatedMovers[name]["postdrag"](_G[name], E:GetScreenQuadrant(_G[name]))
end

function E:CreateMover(parent, name, text, overlay, snapoffset, postdrag)
	local p, p2, p3, p4, p5 = parent:GetPoint()

	if E.CreatedMovers[name] == nil then 
		E.CreatedMovers[name] = {}
		E.CreatedMovers[name]["parent"] = parent
		E.CreatedMovers[name]["text"] = text
		E.CreatedMovers[name]["overlay"] = overlay
		E.CreatedMovers[name]["postdrag"] = postdrag
		E.CreatedMovers[name]["snapoffset"] = snapOffset
		E.CreatedMovers[name]["point"] = GetPoint(parent)
	end	
	
	CreateMover(parent, name, text, overlay, snapoffset, postdrag)
end

function E:ToggleMovers(show)
	for name, _ in pairs(E.CreatedMovers) do
		if not show then
			_G[name]:Hide()
		else
			_G[name]:Show()
		end
	end
end

function E:ResetMovers(arg)
	if arg == "" or arg == nil then
		for name, _ in pairs(E.CreatedMovers) do
			local f = _G[name]
			local point, anchor, secondaryPoint, x, y = string.split('\031', E.CreatedMovers[name]['point'])
			f:ClearAllPoints()
			f:SetPoint(point, anchor, secondaryPoint, x, y)
			
			for key, value in pairs(E.CreatedMovers[name]) do
				if key == "postdrag" and type(value) == 'function' then
					value(f, E:GetScreenQuadrant(f))
				end
			end
		end	
		self.db.movers = nil
	else
		for name, _ in pairs(E.CreatedMovers) do
			for key, value in pairs(E.CreatedMovers[name]) do
				local mover
				if key == "text" then
					if arg == value then 
						local f = _G[name]
						local point, anchor, secondaryPoint, x, y = string.split('\031', E.CreatedMovers[name]['point'])
						f:ClearAllPoints()
						f:SetPoint(point, anchor, secondaryPoint, x, y)				
						
						if self.db.movers then
							self.db.movers[name] = nil
						end
						
						if E.CreatedMovers[name]["postdrag"] ~= nil and type(E.CreatedMovers[name]["postdrag"]) == 'function' then
							E.CreatedMovers[name]["postdrag"](f, E:GetScreenQuadrant(f))
						end
					end
				end
			end	
		end
	end
end

--Profile Change
function E:SetMoversPositions()
	for name, _ in pairs(E.CreatedMovers) do
		local f = _G[name]
		local point, anchor, secondaryPoint, x, y
		if E.db["movers"] and E.db["movers"][name] and type(E.db["movers"][name]) == 'string' then
			point, anchor, secondaryPoint, x, y = string.split('\031', E.db["movers"][name])
			f:ClearAllPoints()
			f:SetPoint(point, anchor, secondaryPoint, x, y)
		elseif f then
			point, anchor, secondaryPoint, x, y = string.split('\031', E.CreatedMovers[name]['point'])
			f:ClearAllPoints()
			f:SetPoint(point, anchor, secondaryPoint, x, y)
		end		
	end
end

--Called from core.lua
function E:LoadMovers()
	for n, _ in pairs(E.CreatedMovers) do
		local p, t, o, so, pd
		for key, value in pairs(E.CreatedMovers[n]) do
			if key == "parent" then
				p = value
			elseif key == "text" then
				t = value
			elseif key == "overlay" then
				o = value
			elseif key == "snapoffset" then
				so = value
			elseif key == "postdrag" then
				pd = value
			end
		end
		CreateMover(p, n, t, o, so, pd)
	end
end

function E:PLAYER_REGEN_DISABLED()
	local err = false
	for name, _ in pairs(E.CreatedMovers) do
		if _G[name] and _G[name]:IsShown() then
			err = true
			_G[name]:Hide()
		end
	end
	if err == true then
		E:Print(ERR_NOT_IN_COMBAT)			
	end	
end
E:RegisterEvent('PLAYER_REGEN_DISABLED')