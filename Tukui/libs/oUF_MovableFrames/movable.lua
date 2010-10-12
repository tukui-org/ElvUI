if TukuiCF.unitframes.enable ~= true then return end
if not oUF then return end

local _, ns = ...
local oUF = ns.oUF or oUF

assert(oUF, "oUF_MovableFrames was unable to locate oUF install.")

local _DB
local _LOCK

local _BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background";
}

local print = function(...)
	return print('|cff33ff99oUF_MovableFrames:|r', ...)
end
local round = function(n)
	return math.floor(n * 1e5 + .5) / 1e5
end

local backdropPool = {}

local getPoint = function(obj, anchor)
	if(not anchor) then
		local UIx, UIy = UIParent:GetCenter()
		local Ox, Oy = obj:GetCenter()

		-- Frame doesn't really have a positon yet.
		if(not Ox) then return end

		local UIS = UIParent:GetEffectiveScale()
		local OS = obj:GetEffectiveScale()

		local UIWidth, UIHeight = UIParent:GetRight(), UIParent:GetTop()

		local LEFT = UIWidth / 3
		local RIGHT = UIWidth * 2 / 3

		local point, x, y
		if(Ox >= RIGHT) then
			point = 'RIGHT'
			x = obj:GetRight() - UIWidth
		elseif(Ox <= LEFT) then
			point = 'LEFT'
			x = obj:GetLeft()
		else
			x = Ox - UIx
		end

		local BOTTOM = UIHeight / 3
		local TOP = UIHeight * 2 / 3

		if(Oy >= TOP) then
			point = 'TOP' .. (point or '')
			y = obj:GetTop() - UIHeight
		elseif(Oy <= BOTTOM) then
			point = 'BOTTOM' .. (point or '')
			y = obj:GetBottom()
		else
			if(not point) then point = 'CENTER' end
			y = Oy - UIy
		end

		return string.format(
			'%s\031%s\031%d\031%d',
			point, 'UIParent', round(x * UIS / OS),  round(y * UIS / OS)
		)
	else
		local point, parent, _, x, y = anchor:GetPoint()

		return string.format(
			'%s\031%s\031%d\031%d',
			point, 'UIParent', round(x), round(y)
		)
	end
end

local getObjectInformation  = function(obj)
	-- This won't be set if we're dealing with oUF <1.3.22. Due to this we're just
	-- setting it to Unknown. It will only break if the user has multiple layouts
	-- spawning the same unit or change between layouts.
	local style = obj.style or 'Unknown'
	local identifier = obj:GetName() or obj.unit

	-- Are we dealing with header units?
	local isHeader
	local parent = obj:GetParent()

	if(parent and parent.initialConfigFunction and (parent.SetManyAttributes or parent.style)) then
		isHeader = true

		-- These always have a name, so we might as well abuse it.
		identifier = parent:GetName()
	end

	return style, identifier, isHeader
end

local restoreDefaultPosition = function(style, identifier)
	-- We've not saved any default position for this style.
	if(not _DB.__INITIAL or not _DB.__INITIAL[style] or not _DB.__INITIAL[style][identifier]) then return end

	local obj, isHeader
	for _, frame in next, oUF.objects do
		local fStyle, fIdentifier, fIsHeader = getObjectInformation(frame)
		if(fStyle == style and fIdentifier == identifier) then
			obj = frame
			isHeader = fIsHeader

			break
		end
	end

	if(obj) then
		local scale = obj:GetScale()
		local parent = obj:GetParent()
		local SetPoint = getmetatable(parent or obj).__index.SetPoint;

		if(parent == UIParent) then
			parent = nil
		end

		(parent or obj):ClearAllPoints()

		local point, parentName, x, y = string.split('\031', _DB.__INITIAL[style][identifier])
		SetPoint(parent or obj, point, parentName, point, x / scale, y / scale)

		local backdrop = backdropPool[parent or obj]
		if(backdrop) then
			backdrop:ClearAllPoints()
			backdrop:SetAllPoints(parent or obj)
		end

		-- We don't need this anymore
		_DB.__INITIAL[style][identifier] = nil
		if(not next(_DB.__INITIAL[style])) then
			_DB[style] = nil
		end
	end
end

local function restorePosition(obj)
	if(InCombatLockdown()) then return end
	local style, identifier, isHeader = getObjectInformation(obj)
	-- We've not saved any custom position for this style.
	if(not _DB[style] or not _DB[style][identifier]) then return end

	local scale = obj:GetScale()
	local parent = (isHeader and obj:GetParent())
	local SetPoint = getmetatable(parent or obj).__index.SetPoint;

	-- Hah, a spot you have to use semi-colon!
	-- Guess I've never experienced that as these are usually wrapped in do end
	-- statements.
	(parent or obj).SetPoint = restorePosition;
	(parent or obj):ClearAllPoints();

	-- damn it Blizzard, _how_ did you manage to get the input of this function
	-- reversed. Any sane person would implement this as: split(str, dlm, lim);
	local point, parentName, x, y = string.split('\031', _DB[style][identifier])
	SetPoint(parent or obj, point, parentName, point, x / scale, y / scale)
end

local saveDefaultPosition = function(obj)
	local style, identifier, isHeader = getObjectInformation(obj)
	if(not _DB.__INITIAL) then
		_DB.__INITIAL = {}
	end

	if(not _DB.__INITIAL[style]) then
		_DB.__INITIAL[style] = {}
	end

	if(not _DB.__INITIAL[style][identifier]) then
		local point
		if(isHeader) then
			point = getPoint(obj:GetParent())
		else
			point = getPoint(obj)
		end

		_DB.__INITIAL[style][identifier] = point
	end
end

local savePosition = function(obj, anchor)
	local style, identifier, isHeader = getObjectInformation(obj)
	if(not _DB[style]) then _DB[style] = {} end

	if(isHeader) then
		_DB[style][identifier] = getPoint(obj:GetParent(), anchor)
	else
		_DB[style][identifier] = getPoint(obj, anchor)
	end
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
	local frame = CreateFrame"Frame"
	frame:SetScript("OnEvent", function(self, event)
		return self[event](self)
	end)

	function frame:VARIABLES_LOADED()
		-- I honestly don't trust the load order of SVs.
		if TukuiCF["unitframes"].positionbychar == true then
			_DB = TukuiUFpos or {}
			TukuiUFpos = _DB
		else
			if (TukuiData == nil) then TukuiData = {} end
			_DB = TukuiData.ufpos or {}
			TukuiData.ufpos = _DB
		end
		-- Got to catch them all!
		for _, obj in next, oUF.objects do
			restorePosition(obj)
		end

		oUF:RegisterInitCallback(restorePosition)
		self:UnregisterEvent"VARIABLES_LOADED"
		self.VARIABLES_LOADED = nil
	end
	frame:RegisterEvent"VARIABLES_LOADED"

	function frame:PLAYER_REGEN_DISABLED()
		if(_LOCK) then
			print("Anchors hidden due to combat.")
			for k, bdrop in next, backdropPool do
				bdrop:Hide()
			end
			_LOCK = nil
		end
	end
	frame:RegisterEvent"PLAYER_REGEN_DISABLED"
end

local getBackdrop
do
	local OnShow = function(self)
		return self.name:SetText(smartName(self.obj, self.header))
	end

	local OnDragStart = function(self)
		saveDefaultPosition(self.obj)
		self:StartMoving()

		local frame = self.header or self.obj
		frame:ClearAllPoints();
		frame:SetAllPoints(self);
	end

	local OnDragStop = function(self)
		self:StopMovingOrSizing()
		savePosition(self.obj, self)
	end

	getBackdrop = function(obj, isHeader)
		local header = (isHeader and obj:GetParent())
		if(not (header or obj):GetCenter()) then return end
		if(backdropPool[header or obj]) then return backdropPool[header or obj] end

		local backdrop = CreateFrame"Frame"
		backdrop:SetParent(UIParent)
		backdrop:Hide()

		backdrop:SetBackdrop(_BACKDROP)
		backdrop:SetFrameStrata"TOOLTIP"
		backdrop:SetAllPoints(header or obj)

		backdrop:EnableMouse(true)
		backdrop:SetMovable(true)
		backdrop:RegisterForDrag"LeftButton"

		backdrop:SetScript("OnShow", OnShow)

		local name = backdrop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		name:SetPoint"CENTER"
		name:SetJustifyH"CENTER"
		name:SetFont(GameFontNormal:GetFont(), 12)
		name:SetTextColor(1, 1, 1)

		backdrop.name = name
		backdrop.obj = obj
		backdrop.header = header

		backdrop:SetBackdropBorderColor(0, .9, 0)
		backdrop:SetBackdropColor(0, .9, 0)

		-- Work around the fact that headers with no units displayed are 0 in height.
		if(header and math.floor(header:GetHeight()) == 0) then
			local height = header:GetChildren():GetHeight()
			header:SetHeight(height)
		end

		backdrop:SetScript("OnDragStart", OnDragStart)
		backdrop:SetScript("OnDragStop", OnDragStop)

		backdropPool[header or obj] = backdrop

		return backdrop
	end
end

-- reset data
local function RESETUF()
	if TukuiCF["unitframes"].positionbychar == true then
		TukuiUFpos = {}
	else
		TukuiData.ufpos = {}
	end
	ReloadUI()
end
SLASH_RESETUF1 = "/resetuf"
SlashCmdList["RESETUF"] = RESETUF

SLASH_OUF_MOVABLEFRAMES1 = '/uf'
SlashCmdList['OUF_MOVABLEFRAMES'] = function(inp)
	if(InCombatLockdown()) then
		return print"Frames cannot be moved while in combat. Bailing out."
	end

	if(not _LOCK) then
		for k, obj in next, oUF.objects do
			local style, identifier, isHeader = getObjectInformation(obj)
			local backdrop = getBackdrop(obj, isHeader)
			if(backdrop) then backdrop:Show() end
		end

		_LOCK = true
	else
		for k, bdrop in next, backdropPool do
			bdrop:Hide()
		end

		_LOCK = nil
	end
end
-- It's not in your best interest to disconnect me. Someone could get hurt.