--oUF_MoveableFrames by Haste, Rewritten partially for ElvUI

local Sticky = LibStub("LibSimpleSticky-1.0")
local _, ns = ...
local oUF = ns.oUF or oUF or ElvUF

assert(oUF, "oUF_MovableFrames was unable to locate oUF install.")
local _DB
local _LOCK
local snapOffset = -15

local print = function(...)
	return print('|cff33ff99oUF_MovableFrames:|r', ...)
end

local initialPositions = {}
local backdropPool = {}

local function GetObjectPoint(obj, anchor)
	local E = select(1, unpack(ElvUI))
	
	if not anchor then
		local UIx, UIy = UIParent:GetCenter()
		local Ox, Oy = obj:GetCenter()

		if not Ox then return end

		local UIS = UIParent:GetEffectiveScale()
		local OS = obj:GetEffectiveScale()

		local UIWidth, UIHeight = UIParent:GetRight(), UIParent:GetTop()

		local LEFT = UIWidth / 3
		local RIGHT = UIWidth * 2 / 3

		local point, x, y
		if Ox >= RIGHT then
			point = 'RIGHT'
			x = obj:GetRight() - UIWidth
		elseif Ox <= LEFT then
			point = 'LEFT'
			x = obj:GetLeft()
		else
			x = Ox - UIx
		end

		local BOTTOM = UIHeight / 3
		local TOP = UIHeight * 2 / 3

		if Oy >= TOP then
			point = 'TOP' .. (point or '')
			y = obj:GetTop() - UIHeight
		elseif Oy <= BOTTOM then
			point = 'BOTTOM' .. (point or '')
			y = obj:GetBottom()
		else
			if not point then point = 'CENTER' end
			y = Oy - UIy
		end
		return string.format('%s\031%s\031%d\031%d', point, 'UIParent', E:Round(x * UIS / OS),  E:Round(y * UIS / OS))
	else
		local point, parent, point2, x, y = anchor:GetPoint()

		return string.format('%s\031%s\031%d\031%d', point, 'UIParent', E:Round(x), E:Round(y))
	end
end

local function GetObjectInfo(obj)
	local style = obj.style or 'Unknown'
	local identifier = obj:GetName() or obj.unit
	local isHeader
	local parent = obj:GetParent()
	
	if(parent) then
		if(parent:GetAttribute'initialConfigFunction' and parent.style) then
			isHeader = parent
			identifier = parent:GetName()
		elseif(parent:GetAttribute'oUF-onlyProcessChildren') then
			isHeader = parent:GetParent()
			identifier = isHeader:GetName()
		end
	end

	return style, identifier, isHeader
end

local function SaveDefaultPosition(obj)
	local style, identifier, isHeader = GetObjectInfo(obj)
	
	if not initialPositions[identifier] then
		local point
		if(isHeader) then
			point = GetObjectPoint(isHeader)
		else
			point = GetObjectPoint(obj)
		end
		
		initialPositions[identifier] = point
	end
end

local RestoreDefaultPosition = function(style, identifier)
	local obj, isHeader
	for _, frame in next, oUF.objects do
		local fStyle, fIdentifier, fIsHeader = GetObjectInfo(frame)
		if fStyle == style and fIdentifier == identifier then
			obj = frame
			isHeader = fIsHeader

			break
		end
	end	
	
	if not initialPositions[identifier] then SaveDefaultPosition(_G[identifier]) end
	
	if(obj) then
		local scale = obj:GetScale()
		local target = isHeader or obj
		local E = select(1, unpack(ElvUI))
		local UF = E:GetModule('UnitFrames')
		local point, parentName, x, y = string.split('\031', initialPositions[identifier])

		local backdrop = backdropPool[target]
		if backdrop then
			backdrop:ClearAllPoints()
			backdrop:Point(point, _G[parentName], point, x / scale, y / scale)	
		end		
		
		if _DB['units'].positions then
			_DB['units'].positions[identifier] = nil
			if not next(_DB['units'].positions) then
				_DB['units'].positions = nil
			end		
		end
	end	
end

local function LoadObjectPosition(obj)
	if InCombatLockdown() then return end
	local style, identifier, isHeader = GetObjectInfo(obj)
	local E = select(1, unpack(ElvUI))
	local UF = E:GetModule('UnitFrames')
	
	if not identifier then identifier = obj:GetName() end
	if not _DB['units'].positions or not _DB['units'].positions[identifier] then
		local scale = obj:GetScale()
		local target = isHeader or obj
		
		if not initialPositions[identifier] then SaveDefaultPosition(_G[identifier]) end
		if not initialPositions[identifier] then return end
		local point, parentName, x, y = string.split('\031', initialPositions[identifier])
		local backdrop = backdropPool[target]
		if(backdrop) then
			backdrop:ClearAllPoints()
			backdrop:Point(point, _G[parentName], point, x / scale, y / scale)
		end			
	else
		local scale = obj:GetScale()
		local target = isHeader or obj
		

		local point, parentName, x, y = string.split('\031', _DB['units'].positions[identifier])
		local backdrop = backdropPool[target]
		if(backdrop) then
			backdrop:ClearAllPoints()
			backdrop:Point(point, _G[parentName], point, x / scale, y / scale)
			target:ClearAllPoints()
			target:Point(point, backdrop, point)
		else
			backdrop = getBackdrop(obj, isHeader)
			target:ClearAllPoints()
			target:Point(point, backdrop, point)
		end			
	end
end


local function SaveCurrentPosition(obj, anchor)
	local style, identifier, isHeader = GetObjectInfo(obj)
	local E = select(1, unpack(ElvUI))
	local UF = E:GetModule('UnitFrames')
	
	if not _DB['units'].positions then
		_DB['units'].positions = {}
	end
	
	local point
	if(isHeader) then
		point = GetObjectPoint(anchor)
	else
		point = GetObjectPoint(anchor)
	end

	_DB['units'].positions[identifier] = point
end

-- Attempt to figure out a more sane name to dispaly.
local smartName
do
	local nameCache = {}
	local validNames = {
		'player',
		'target',
		'focus',
		'raid',
		'pet',
		'party',
		'maintank',
		'mainassist',
		'arena',
	}

	local validName = function(smartName)
		-- Not really a valid name, but we'll accept it for simplicities sake.
		if(tonumber(smartName)) then
			return smartName
		end

		if(type(smartName) == 'string') then
			if(smartName == 'mt') then
				return 'maintank'
			end

			for _, v in next, validNames do
				if(v == smartName) then
					return smartName
				end
			end

			if(
				smartName:match'^party%d?$' or
				smartName:match'^arena%d?$' or
				smartName:match'^boss%d?$' or
				smartName:match'^partypet%d?$' or
				smartName:match'^raid%d?%d?$' or
				smartName:match'%w+target$' or
				smartName:match'%w+pet$'
				) then
				return smartName
			end
		end
	end

	local function guessName(...)
		local name = validName(select(1, ...))

		local n = select('#', ...)
		if(n > 1) then
			for i=2, n do
				local inp = validName(select(i, ...))
				if(inp) then
					name = (name or '') .. inp
				end
			end
		end

		return name
	end

	local smartString = function(name)
		if(nameCache[name]) then
			return nameCache[name]
		end

		-- Here comes the substitute train!
		local n = name:gsub('(%l)(%u)', '%1_%2'):gsub('([%l%u])(%d)', '%1_%2_'):lower()
		n = guessName(string.split('_', n))
		if(n) then
			nameCache[name] = n
			return n
		end

		return name
	end

	smartName = function(obj, header)
		if(type(obj) == 'string') then
			return smartString(obj)
		elseif(header) then
			return smartString(header:GetName())
		else
			local name = obj:GetName()
			if(name) then
				return smartString(name)
			end

			return obj.unit or '<unknown>'
		end
	end
end

do
	local OnShow = function(self)
		return self.name:SetText(smartName(self.obj, self.header))
	end
	
	local OnHide = function(self)
		if(self.dirtyMinHeight) then
			self:SetAttribute('minHeight', nil)
		end

		if(self.dirtyMinWidth) then
			self:SetAttribute('minWidth', nil)
		end
	end	

	local OnDragStart = function(self)
		local E = select(1, unpack(ElvUI))
		if E.db['general'].stickyFrames then
			local offset = self.obj.snapOffset or snapOffset
			Sticky:StartMoving(self, E['snapBars'], offset, offset, offset, offset)
		else
			self:StartMoving()
		end
	end

	local OnDragStop = function(self)
		local E = select(1, unpack(ElvUI))
		if E.db['general'].stickyFrames then
			Sticky:StopMoving(self)
		else
			self:StopMovingOrSizing()
		end
		
		SaveCurrentPosition(self.obj, self)

		self:SetUserPlaced(false)
	end
	
	local OnSizeChanged = function(self)
		if InCombatLockdown() then return end
		self.mover:SetSize(self:GetSize())
	end

	getBackdrop = function(obj, isHeader)
		local target = isHeader or obj
		if(not target:GetCenter()) then return end
		if(backdropPool[target]) then return backdropPool[target] end
		if target.isChild then return end
		
		local p, p2, p3, p4, p5 = target:GetPoint()
		local E = select(1, unpack(ElvUI))
		local UF = E:GetModule('UnitFrames')
		
		local backdrop = CreateFrame"Button"
		backdropPool[target] = backdrop
		tinsert(E['snapBars'], backdrop)
		
		backdrop:SetParent(E.UIParent)
		backdrop:Hide()
		backdrop:SetFrameStrata"TOOLTIP"
		backdrop:SetSize(target:GetSize())
		backdrop:SetPoint(p, p2, p3, p4, p5)

		SaveDefaultPosition(target)
		LoadObjectPosition(target)
		
		backdrop:EnableMouse(true)
		backdrop:SetMovable(true)
		backdrop:RegisterForDrag"LeftButton"

		backdrop:SetScript("OnShow", OnShow)
		backdrop:SetScript("OnHide", OnHide)
		target:SetScript("OnSizeChanged", OnSizeChanged)
		target.mover = backdrop
		
		local name = backdrop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		name:SetPoint"CENTER"
		name:SetJustifyH"CENTER"
		name:SetFont(GameFontNormal:GetFont(), 12, "OUTLINE")
		name:SetTextColor(unpack(E["media"].rgbvaluecolor))
		
		backdrop.name = name
		backdrop.obj = target
		backdrop.header = isHeader
		target.mover = backdrop
		backdrop:SetTemplate("Default", true)

		if (isHeader and (not isHeader:GetAttribute'minHeight' and math.floor(isHeader:GetHeight()) == 0 or not isHeader:GetAttribute'minWidth' and math.floor(isHeader:GetWidth()) == 0)) then
			isHeader:SetHeight(obj:GetHeight())
			isHeader:SetWidth(obj:GetWidth())
			
			if(not isHeader:GetAttribute'minHeight') then
				isHeader.dirtyMinHeight = true
				isHeader:SetAttribute('minHeight', obj:GetHeight())
			end

			if(not isHeader:GetAttribute'minWidth') then
				isHeader.dirtyMinWidth = true
				isHeader:SetAttribute('minWidth', obj:GetWidth())
			end
		elseif isHeader then
			backdrop.baseWidth, backdrop.baseHeight = isHeader:GetSize()
		end
		
		target:ClearAllPoints()
		target:SetPoint(p, backdrop, p, 0, 0)

		backdrop:SetScript("OnDragStart", OnDragStart)
		backdrop:SetScript("OnDragStop", OnDragStop)
		backdrop:SetScript("OnEnter", function(self)
			self.name:SetTextColor(1, 1, 1)
			self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))		
		end)
		backdrop:SetScript("OnLeave", function(self)
			self.name:SetTextColor(unpack(E["media"].rgbvaluecolor))
			self:SetTemplate("Default", true)
		end)		


		return backdrop
	end
end

do
	local frame = CreateFrame"Frame"
	frame:SetScript("OnEvent", function(self, event)
		return self[event](self)
	end)
	
	function LoadAllMovers()
		for _, obj in next, oUF.objects do
			local style, identifier, isHeader = GetObjectInfo(obj)
			local backdrop = getBackdrop(obj, isHeader)
		end		
	end
	
	function frame:PLAYER_ENTERING_WORLD()
		local E = select(1, unpack(ElvUI))
		_DB = E.db['unitframe']	
		-- reset data
		LoadAllMovers()
		
		oUF:RegisterInitCallback(LoadObjectPosition)
		self:UnregisterEvent"PLAYER_ENTERING_WORLD"
	end
	frame:RegisterEvent"PLAYER_ENTERING_WORLD"
	
	function frame:PLAYER_REGEN_DISABLED()
		if(_LOCK) then
			for k, bdrop in next, backdropPool do
				bdrop:Hide()
			end
			_LOCK = nil
		end
	end
	frame:RegisterEvent"PLAYER_REGEN_DISABLED"
end

function oUF:ResetDB()
	local E = select(1, unpack(ElvUI))
	if E.private["unitframe"].enable ~= true then return; end
	_DB = E.db['unitframe']	
end

function oUF:ResetUF()	
	for object, _ in pairs(initialPositions) do
		RestoreDefaultPosition(_G[object].style, object)	
	end
end

function oUF:PositionUF()
	local E = select(1, unpack(ElvUI))
	if E.private["unitframe"].enable ~= true then return; end
	for object, _ in pairs(initialPositions) do
		LoadObjectPosition(_G[object])
	end
end

function oUF:MoveUF(move)
	if InCombatLockdown() then return end
	
	if move then
		for k, obj in next, oUF.objects do
			local style, identifier, isHeader = GetObjectInfo(obj)
			local backdrop = getBackdrop(obj, isHeader)
			if backdrop then backdrop:Show() end
		end

		_LOCK = true
	else
		for k, bdrop in next, backdropPool do
			bdrop:Hide()
		end

		_LOCK = nil
	end
end