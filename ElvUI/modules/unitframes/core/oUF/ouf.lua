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
		if(self.unit and (self.unit == value or self.realUnit == value)) then
			return
		else
			if(self.hasChildren) then
				iterateChildren(self:GetChildren())
			end

			if(not self:GetAttribute'oUF-onlyProcessChildren') then
				local unit = SecureButton_GetModifiedUnit(self)
				unit = conv[unit] or unit
				units[unit] = self
				self.unit = unit
				self.id = unit:match"^.-(%d+)"
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
		if(not element or self:IsElementEnabled(name)) then return end

		if(element.enable(self, unit or self.unit)) then
			table.insert(self.__elements, element.update)
		end
	end,

	DisableElement = function(self, name)
		argcheck(name, 2, 'string')

		local enabled, k = self:IsElementEnabled(name)
		if(not enabled) then return end

		table.remove(self.__elements, k)

		-- We need to run a new update cycle incase we knocked ourself out of sync.
		-- The main reason we do this is to make sure the full update is completed
		-- if an element for some reason removes itself _during_ the update
		-- progress.
		self:UpdateAllElements('DisableElement', name)

		return elements[name].disable(self)
	end,

	IsElementEnabled = function(self, name)
		argcheck(name, 2, 'string')

		local element = elements[name]
		if(not element) then return end

		for k, update in next, self.__elements do
			if(update == element.update) then
				return true, k
			end
		end
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

local updateActiveUnit = function(self, event, unit)
	-- Calculate units to work with
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

	-- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
	if(realUnit == 'playerpet') then
		realUnit = 'pet'
	end

	if(modUnit == "pet" and realUnit ~= "pet") then
		modUnit = "vehicle"
	end

	-- Drop out if the event unit doesn't match any of the frame units.
	if(not UnitExists(modUnit) or unit and unit ~= realUnit and unit ~= modUnit) then return end

	if(modUnit ~= realUnit) then
		self.realUnit = realUnit
	else
		self.realUnit = nil
	end

	-- Change the active unit and run a full update.
	if(self.unit ~= modUnit) then
		self.unit = modUnit
		self:UpdateAllElements('RefreshUnit')

		return true
	end
end

local OnShow = function(self)
	if(not updateActiveUnit(self, 'OnShow')) then
		return self:UpdateAllElements'OnShow'
	end
end

local initObject = function(unit, style, styleFunc, header, ...)
	local num = select('#', ...)
	for i=1, num do
		local object = select(i, ...)
		local objectUnit = object:GetAttribute'oUF-guessUnit' or unit
		local suffix = object:GetAttribute'unitsuffix'

		object.__elements = {}
		object.style = style
		object = setmetatable(object, frame_metatable)

		-- Expose the frame through oUF.objects.
		table.insert(objects, object)

		-- We have to force update the frames when PEW fires.
		object:RegisterEvent("PLAYER_ENTERING_WORLD", object.UpdateAllElements)

		-- Handle the case where someone has modified the unitsuffix attribute in
		-- oUF-initialConfigFunction.
		if(suffix and not objectUnit:match(suffix)) then
			objectUnit = objectUnit .. suffix
		end

		if(not (suffix == 'target' or objectUnit and objectUnit:match'target')) then
			object:RegisterEvent('UNIT_ENTERED_VEHICLE', updateActiveUnit)
			object:RegisterEvent('UNIT_EXITED_VEHICLE', updateActiveUnit)

			-- We don't need to register UNIT_PET for the player unit. We rigester it
			-- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE doesn't always
			-- have pet information when they fire for party and raid units.
			if(objectUnit ~= 'player') then
				object:RegisterEvent('UNIT_PET', updateActiveUnit)
			end
		end

		if(not header) then
			-- No header means it's a frame created through :Spawn().
			object:SetAttribute("*type1", "target")
			object:SetAttribute('*type2', 'menu')

			-- No need to enable this for *target frames.
			if(not (unit:match'target' or suffix == 'target')) then
				object:SetAttribute('toggleForVehicle', true)
			end

			-- Other boss and target units are handled by :HandleUnit().
			if(suffix == 'target') then
				enableTargetUpdate(object)
			elseif(not (unit:match'%w+target' or unit:match'(boss)%d?$' == 'boss')) then
				object:SetScript('OnEvent', Private.OnEvent)
			end
		else
			-- Used to update frames when they change position in a group.
			object:RegisterEvent('PARTY_MEMBERS_CHANGED', object.UpdateAllElements)

			if(num > 1) then
				if(object:GetParent() == header) then
					object.hasChildren = true
				else
					object.isChild = true
				end
			end

			if(suffix == 'target') then
				enableTargetUpdate(object)
			else
				object:SetScript('OnEvent', Private.OnEvent)
			end
		end

		styleFunc(object, objectUnit, not header)

		object:SetScript("OnAttributeChanged", OnAttributeChanged)
		object:SetScript("OnShow", OnShow)

		for element in next, elements do
			object:EnableElement(element, objectUnit)
		end

		for _, func in next, callback do
			func(object)
		end

		-- Make Clique happy
		_G.ClickCastFrames = ClickCastFrames or {}
		ClickCastFrames[object] = true
	end
end

local walkObject = function(object, unit)
	local parent = object:GetParent()
	local style = parent.style or style
	local styleFunc = styles[style]

	local header = parent:GetAttribute'oUF-headerType' and parent

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
				local groupFilter = header:GetAttribute'groupFilter'

				if(type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]')) then
					local role = groupFilter:match('MAIN([AT])')
					if(role == 'T') then
						unit = 'maintank'
					else
						unit = 'mainassist'
					end
				elseif(header:GetAttribute'showRaid') then
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

		header:SetAttribute("template", "oUF_ClickCastUnitTemplate")
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

	self:DisableBlizzard(unit)
	self:HandleUnit(object)

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
	if(parent ~= 'oUF' and global == 'oUF') then
		error("%s is doing it wrong and setting its global to oUF.", parent)
	else
		_G[global] = oUF
	end
end
