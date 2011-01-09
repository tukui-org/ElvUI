local parent, ns = ...
local global = GetAddOnMetadata(parent, 'X-oUF')
local _VERSION = GetAddOnMetadata(parent, 'version')

local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck

local print = Private.print
local error = Private.error
local OnEvent = Private.OnEvent

local styles, style = {}
local callback, units, objects = {}, {}, {}

local select = select
local UnitExists = UnitExists

local conv = {
	['playerpet'] = 'pet',
	['playertarget'] = 'target',
}
local elements = {}

-- updating of "invalid" units.
local enableTargetUpdate = function(object)
	local total = 0
	object.onUpdateFrequency = object.onUpdateFrequency or .5

	object:SetScript('OnUpdate', function(self, elapsed)
		if(not self.unit) then
			return
		elseif(total > self.onUpdateFrequency) then
			self:UpdateAllElements'OnUpdate'
			total = 0
		end

		total = total + elapsed
	end)
end
Private.enableTargetUpdate = enableTargetUpdate

local iterateChildren = function(...)
	for l = 1, select("#", ...) do
		local obj = select(l, ...)

		if(type(obj) == 'table' and obj.isChild) then
			local unit = SecureButton_GetModifiedUnit(obj)
			local subUnit = conv[unit] or unit
			units[subUnit] = obj
			obj.unit = subUnit
			obj.id = subUnit:match'^.-(%d+)'
			obj:UpdateAllElements"PLAYER_ENTERING_WORLD"
		end
	end
end

local OnAttributeChanged = function(self, name, value)
	if(name == "unit" and value) then
		units[value] = self

		if(self.unit and self.unit == value) then
			return
		else
			if(self.hasChildren) then
				iterateChildren(self:GetChildren())
			end

			if(not self:GetAttribute'oUF-onlyProcessChildren') then
				self.unit = SecureButton_GetModifiedUnit(self)
				self.id = value:match"^.-(%d+)"
				self:UpdateAllElements"PLAYER_ENTERING_WORLD"
			end
		end
	end
end

local frame_metatable = {
	__index = CreateFrame"Button"
}
Private.frame_metatable = frame_metatable

for k, v in pairs{
	EnableElement = function(self, name, unit)
		argcheck(name, 2, 'string')
		argcheck(unit, 3, 'string', 'nil')

		local element = elements[name]
		if(not element) then return end

		if(element.enable(self, unit or self.unit)) then
			table.insert(self.__elements, element.update)
		end
	end,

	DisableElement = function(self, name)
		argcheck(name, 2, 'string')
		local element = elements[name]
		if(not element) then return end

		for k, update in next, self.__elements do
			if(update == element.update) then
				table.remove(self.__elements, k)

				-- We need to run a new update cycle incase we knocked ourself out of sync.
				-- The main reason we do this is to make sure the full update is completed
				-- if an element for some reason removes itself _during_ the update
				-- progress.
				self:UpdateAllElements('DisableElement', name)
				break
			end
		end

		return element.disable(self)
	end,

	Enable = RegisterUnitWatch,
	Disable = function(self)
		UnregisterUnitWatch(self)
		self:Hide()
	end,

	UpdateAllElements = function(self, event)
		local unit = self.unit
		if(not UnitExists(unit)) then return end

		if(self.PreUpdate) then
			self:PreUpdate(event)
		end

		for _, func in next, self.__elements do
			func(self, event, unit)
		end

		if(self.PostUpdate) then
			self:PostUpdate(event)
		end
	end,
} do
	frame_metatable.__index[k] = v
end

local initObject = function(unit, style, styleFunc, header, ...)
	local num = select('#', ...)
	for i=1, num do
		local object = select(i, ...)

		object.__elements = {}
		object = setmetatable(object, frame_metatable)

		-- Run it before the style function so they can override it.
		if(not header) then
			object:SetAttribute("*type1", "target")
			object:SetAttribute('*type2', 'menu')

			object:SetAttribute('toggleForVehicle', true)
		else
			object:RegisterEvent('PARTY_MEMBERS_CHANGED', object.UpdateAllElements)
		end
		object.style = style

		local parent = object:GetParent()
		if(num > 1) then
			if(i == 1 and not parent:GetAttribute'oUF-onlyProcessChildren') then
				object.hasChildren = true
			else
				object.isChild = true
			end
		end

		-- Register it early so it won't be executed after the layouts PEW, if they
		-- have one.
		object:RegisterEvent("PLAYER_ENTERING_WORLD", object.UpdateAllElements)

		styleFunc(object, object:GetAttribute'oUF-guessUnit' or unit, not header)

		local showPlayer
		if(header and i == 1) then
			showPlayer = header:GetAttribute'showPlayer' or header:GetAttribute'showSolo'
		end

		local suffix = object:GetAttribute'unitsuffix'
		if(suffix and suffix:match'target' and (i ~= 1 and not showPlayer)) then
			enableTargetUpdate(object)
		else
			object:SetScript("OnEvent", Private.OnEvent)
		end

		object:SetScript("OnAttributeChanged", OnAttributeChanged)
		object:SetScript("OnShow", object.UpdateAllElements)

		for element in next, elements do
			object:EnableElement(element, object:GetAttribute'oUF-guessUnit' or unit)
		end

		for _, func in next, callback do
			func(object)
		end

		-- We could use ClickCastFrames only, but it will probably contain frames that
		-- we don't care about.
		table.insert(objects, object)
		_G.ClickCastFrames = ClickCastFrames or {}
		ClickCastFrames[object] = true
	end
end

local walkObject = function(object, unit)
	local parent = object:GetParent()
	local style = parent.style or style
	local header = parent.style and parent
	local styleFunc = styles[style]

	-- Check if we should leave the main frame blank.
	if(object:GetAttribute'oUF-onlyProcessChildren') then
		object.hasChildren = true
		object:SetScript('OnAttributeChanged', OnAttributeChanged)
		return initObject(unit, style, styleFunc, header, object:GetChildren())
	end

	return initObject(unit, style, styleFunc, header, object, object:GetChildren())
end

function oUF:RegisterInitCallback(func)
	table.insert(callback, func)
end

function oUF:RegisterMetaFunction(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(frame_metatable.__index[name]) then
		return
	end

	frame_metatable.__index[name] = func
end

function oUF:RegisterStyle(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(styles[name]) then return error("Style [%s] already registered.", name) end
	if(not style) then style = name end

	styles[name] = func
end

function oUF:SetActiveStyle(name)
	argcheck(name, 2, 'string')
	if(not styles[name]) then return error("Style [%s] does not exist.", name) end

	style = name
end

do
	local function iter(_, n)
		-- don't expose the style functions.
		return (next(styles, n))
	end

	function oUF.IterateStyles()
		return iter, nil, nil
	end
end

local getCondition
do
	local conditions = {
		raid40 = '[@raid26,exists] show;',
		raid25 = '[@raid11,exists] show;',
		raid10 = '[@raid6,exists] show;',
		raid = '[group:raid] show;',
		party = '[group:party,nogroup:raid] show;',
		solo = '[@player,exists,nogroup:party] show;',
	}

	function getCondition(...)
		local cond = ''

		for i=1, select('#', ...) do
			local short = select(i, ...)

			local condition = conditions[short]
			if(condition) then
				cond = cond .. condition
			end
		end

		return cond .. 'hide'
	end
end

local generateName = function(unit, ...)
	local name = 'oUF_' .. style:gsub('[^%a%d_]+', '')

	local raid, party, groupFilter
	for i=1, select('#', ...), 2 do
		local att, val = select(i, ...)
		if(att == 'showRaid') then
			raid = true
		elseif(att == 'showParty') then
			party = true
		elseif(att == 'groupFilter') then
			groupFilter = val
		end
	end

	local append
	if(raid) then
		if(groupFilter) then
			if(type(groupFilter) == 'number' and groupFilter > 0) then
				append = groupFilter
			elseif(groupFilter:match'TANK') then
				append = 'MainTank'
			elseif(groupFilter:match'ASSIST') then
				append = 'MainAssist'
			else
				local _, count = groupFilter:gsub(',', '')
				if(count == 0) then
					append = groupFilter
				else
					append = 'Raid'
				end
			end
		else
			append = 'Raid'
		end
	elseif(party) then
		append = 'Party'
	elseif(unit) then
		append = unit:gsub("^%l", string.upper)
	end

	if(append) then
		name = name .. append
	end

	-- Change oUF_LilyRaidRaid into oUF_LilyRaid
	name = name:gsub('(%u%l+)([%u%l]*)%1', '%1')

	local base = name
	local i = 2
	while(_G[name]) do
		name = base .. i
		i = i + 1
	end

	return name
end

do
	local styleProxy = function(self, frame, ...)
		return walkObject(_G[frame])
	end

	-- There has to be an easier way to do this.
	local initialConfigFunction = [[
		local header = self:GetParent()
		local frames = table.new()
		table.insert(frames, self)
		self:GetChildList(frames)
		for i=1, #frames do
			local frame = frames[i]
			local unit
			-- There's no need to do anything on frames with onlyProcessChildren
			if(not frame:GetAttribute'oUF-onlyProcessChildren') then
				RegisterUnitWatch(frame)

				-- Attempt to guess what the header is set to spawn.
				if(header:GetAttribute'showRaid') then
					unit = 'raid'
				elseif(header:GetAttribute'showParty') then
					unit = 'party'
				end

				local headerType = header:GetAttribute'oUF-headerType'
				local suffix = frame:GetAttribute'unitsuffix'
				if(unit and suffix) then
					if(headerType == 'pet' and suffix == 'target') then
						unit = unit .. headerType .. suffix
					else
						unit = unit .. suffix
					end
				elseif(unit and headerType == 'pet') then
					unit = unit .. headerType
				end

				frame:SetAttribute('*type1', 'target')
				frame:SetAttribute('*type2', 'menu')
				frame:SetAttribute('toggleForVehicle', true)
				frame:SetAttribute('oUF-guessUnit', unit)
			end

			local body = header:GetAttribute'oUF-initialConfigFunction'
			if(body) then
				frame:Run(body, unit)
			end
		end

		header:CallMethod('styleFunction', self:GetName())

		local clique = header:GetFrameRef("clickcast_header")
		if(clique) then
			clique:SetAttribute("clickcast_button", self)
			clique:RunAttribute("clickcast_register")
		end
	]]

	function oUF:SpawnHeader(overrideName, template, visibility, ...)
		if(not style) then return error("Unable to create frame. No styles have been registered.") end

		template = (template or 'SecureGroupHeaderTemplate')

		local isPetHeader = template:match'PetHeader'
		local name = overrideName or generateName(nil, ...)
		local header = CreateFrame('Frame', name, UIParent, template)

		header:SetAttribute("template", "SecureUnitButtonTemplate,oUF_ClickCastUnitTemplate")
		for i=1, select("#", ...), 2 do
			local att, val = select(i, ...)
			if(not att) then break end
			header:SetAttribute(att, val)
		end

		header.style = style
		header.styleFunction = styleProxy

		-- We set it here so layouts can't directly override it.
		header:SetAttribute('initialConfigFunction', initialConfigFunction)
		header:SetAttribute('oUF-headerType', isPetHeader and 'pet' or 'group')

		if(Clique) then
			SecureHandlerSetFrameRef(header, 'clickcast_header', Clique.header)
		end

		if(header:GetAttribute'showParty') then
			self:DisableBlizzard'party'
		end

		if(visibility) then
			local type, list = string.split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterAttributeDriver(header, 'state-visibility', list)
			else
				local condition = getCondition(string.split(',', visibility))
				RegisterAttributeDriver(header, 'state-visibility', condition)
			end
		end

		return header
	end
end

function oUF:Spawn(unit, overrideName)
	argcheck(unit, 2, 'string')
	if(not style) then return error("Unable to create frame. No styles have been registered.") end

	unit = unit:lower()

	local name = overrideName or generateName(unit)
	local object = CreateFrame("Button", name, UIParent, "SecureUnitButtonTemplate")
	object.unit = unit
	object.id = unit:match"^.-(%d+)"

	units[unit] = object
	walkObject(object, unit)

	object:SetAttribute("unit", unit)
	RegisterUnitWatch(object)

	self:DisableBlizzard(unit, object)

	return object
end

function oUF:AddElement(name, update, enable, disable)
	argcheck(name, 2, 'string')
	argcheck(update, 3, 'function', 'nil')
	argcheck(enable, 4, 'function', 'nil')
	argcheck(disable, 5, 'function', 'nil')

	if(elements[name]) then return error('Element [%s] is already registered.', name) end
	elements[name] = {
		update = update;
		enable = enable;
		disable = disable;
	}
end

oUF.version = _VERSION
oUF.units = units
oUF.objects = objects

if(global) then
	_G[global] = oUF
end
