local parent, ns = ...
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local global = GetAddOnMetadata(parent, 'X-oUF')
local _VERSION = 'devel'

local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local print = Private.print -- luacheck: no unused
local unitExists = Private.unitExists
local nierror = Private.nierror

local _G = _G
local strsplit = strsplit
local assert, setmetatable = assert, setmetatable
local next, type, select = next, type, select
local strupper, format = strupper, format
local tinsert, tremove = tinsert, tremove

local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local RegisterAttributeDriver = RegisterAttributeDriver
local UnregisterUnitWatch = UnregisterUnitWatch
local RegisterUnitWatch = RegisterUnitWatch
local CreateFrame = CreateFrame
local IsLoggedIn = IsLoggedIn
local UnitGUID = UnitGUID
local Mixin = Mixin

local SecureButton_GetUnit = SecureButton_GetUnit
local SecureButton_GetModifiedUnit = SecureButton_GetModifiedUnit

local SetNamePlateHitTestInsets = C_NamePlateManager and C_NamePlateManager.SetNamePlateHitTestInsets
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local SetNamePlateSize = C_NamePlate.SetNamePlateSize
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local SetCVar = C_CVar.SetCVar

local NAMEPLATE_TYPE = Enum.NamePlateType

local styles, style = {}
local callback, objects, headers = {}, {}, {}

local elements = {}
local activeElements = {}

local UFParentHider = CreateFrame('Frame', (global or parent) .. '_UFParentFrameHider', UIParent, 'SecureHandlerStateTemplate')
UFParentHider:SetFrameStrata('LOW')
RegisterStateDriver(UFParentHider, 'visibility', '[petbattle] hide; show')

local function updateActiveUnit(self, event)
	-- Calculate units to work with
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

	-- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
	if(realUnit == 'playerpet') then
		realUnit = 'pet'
	elseif(realUnit == 'playertarget') then
		realUnit = 'target'
	end

	if(modUnit == 'pet' and realUnit ~= 'pet') then
		modUnit = 'vehicle'
	end

	if(not unitExists(modUnit)) then return end

	-- Change the active unit and run a full update.
	if(Private.UpdateUnits(self, modUnit, realUnit)) then
		self:UpdateAllElements(event or 'RefreshUnit')

		return true
	end
end

local function evalUnitAndUpdate(self, event)
	if(not updateActiveUnit(self, event)) then
		return self:UpdateAllElements(event)
	end
end

local function iterateChildren(...)
	for i = 1, select('#', ...) do
		local obj = select(i, ...)

		if(type(obj) == 'table' and obj.isChild) then
			updateActiveUnit(obj, 'iterateChildren')
		end
	end
end

local function onAttributeChanged(self, name, value)
	if(name == 'unit' and value) then
		if(self.hasChildren) then
			iterateChildren(self:GetChildren())
		end

		if(not self:GetAttribute('oUF-onlyProcessChildren')) then
			updateActiveUnit(self, 'OnAttributeChanged')
		end
	end
end

local frame_metatable = {
	__index = CreateFrame('Button')
}
Private.frame_metatable = frame_metatable

for k, v in next, {
	--[[ frame:EnableElement(name, unit)
	Used to activate an element for the given unit frame.

	* self - unit frame for which the element should be enabled
	* name - name of the element to be enabled (string)
	* unit - unit to be passed to the element's Enable function. Defaults to the frame's unit (string?)
	--]]
	EnableElement = function(self, name, unit)
		argcheck(name, 2, 'string')
		argcheck(unit, 3, 'string', 'nil')

		local element = elements[name]
		if(not element or self:IsElementEnabled(name)) then return end

		if(element.enable(self, unit or self.unit)) then
			activeElements[self][name] = true

			if(element.update) then
				tinsert(self.__elements, element.update)
			end
		end
	end,

	--[[ frame:DisableElement(name)
	Used to deactivate an element for the given unit frame.

	* self - unit frame for which the element should be disabled
	* name - name of the element to be disabled (string)
	--]]
	DisableElement = function(self, name)
		argcheck(name, 2, 'string')

		local enabled = self:IsElementEnabled(name)
		if(not enabled) then return end

		local update = elements[name].update
		if(update) then
			for k, func in next, self.__elements do
				if(func == update) then
					tremove(self.__elements, k)
					break
				end
			end
		end

		activeElements[self][name] = nil

		return elements[name].disable(self)
	end,

	--[[ frame:IsElementEnabled(name)
	Used to check if an element is enabled on the given frame.

	* self - unit frame
	* name - name of the element (string)
	--]]
	IsElementEnabled = function(self, name)
		argcheck(name, 2, 'string')

		local element = elements[name]
		if(not element) then return end

		local active = activeElements[self]
		return active and active[name]
	end,

	--[[ frame:SetEnabled(enabled, asState)
	* self    - unit frame
	* enabled - on or off
	* asState - if true, the frame's "state-unitexists" attribute will be set to a boolean value denoting whether the
	            unit exists; if false, the frame will be shown if its unit exists, and hidden if it does not (boolean)
	--]]
	SetEnabled = function(self, enabled, asState)
		if enabled then
			RegisterUnitWatch(self, asState)
		else
			UnregisterUnitWatch(self)
			self:Hide()
		end
	end,

	--[[ frame:Enable(asState)
	Used to toggle the visibility of a unit frame based on the existence of its unit. This is a reference to
	`RegisterUnitWatch`.

	* self    - unit frame
	* asState - if true, the frame's "state-unitexists" attribute will be set to a boolean value denoting whether the
	            unit exists; if false, the frame will be shown if its unit exists, and hidden if it does not (boolean)
	--]]
	Enable = RegisterUnitWatch,
	--[[ frame:Disable()
	Used to UnregisterUnitWatch for the given frame and hide it.

	* self - unit frame
	--]]
	Disable = function(self)
		UnregisterUnitWatch(self)
		self:Hide()
	end,
	--[[ frame:IsEnabled()
	Used to check if a unit frame is registered with the unit existence monitor. This is a reference to
	`UnitWatchRegistered`.

	* self - unit frame
	--]]
	IsEnabled = UnitWatchRegistered,
	--[[ frame:UpdateAllElements(event)
	Used to update all enabled elements on the given frame.

	* self  - unit frame
	* event - event name to pass to the elements' update functions (string)
	--]]
	UpdateAllElements = function(self, event)
		local unit = self.unit
		if(not unitExists(unit)) then return end

		assert(type(event) == 'string', "Invalid argument 'event' in UpdateAllElements.")

		if(self.PreUpdate) then
			--[[ Callback: frame:PreUpdate(event)
			Fired before the frame is updated.

			* self  - the unit frame
			* event - the event triggering the update (string)
			--]]
			self:PreUpdate(event)
		end

		for _, func in next, self.__elements do
			func(self, event, unit)
		end

		if(self.PostUpdate) then
			--[[ Callback: frame:PostUpdate(event)
			Fired after the frame is updated.

			* self  - the unit frame
			* event - the event triggering the update (string)
			--]]
			self:PostUpdate(event)
		end
	end,
} do
	frame_metatable.__index[k] = v
end

local function onShow(self)
	evalUnitAndUpdate(self, 'OnShow')
end

local function updatePet(self, event, unit)
	local petUnit
	if(unit == 'target') then
		return
	elseif(unit == 'player') then
		petUnit = 'pet'
	else
		-- Convert raid26 -> raidpet26
		petUnit = unit:gsub('^(%a+)(%d+)', '%1pet%2')
	end

	if(self.unit ~= petUnit) then return end

	evalUnitAndUpdate(self, event)
end

local function updateRaid(self, event)
	local unitGUID = UnitGUID(self.unit)
	if(unitGUID and unitGUID ~= self.unitGUID) then
		self.unitGUID = unitGUID

		self:UpdateAllElements(event)
	end
end

local function isEventlessUnit(unit)
	return unit:match('%w+target')
end

local function initObject(unit, style, styleFunc, header, ...)
	local num = select('#', ...)
	for i = 1, num do
		local object = select(i, ...)
		local objectUnit = object:GetAttribute('oUF-guessUnit') or unit
		local suffix = object:GetAttribute('unitsuffix')

		-- Handle the case where someone has modified the unitsuffix attribute in
		-- oUF-initialConfigFunction.
		if(suffix and not objectUnit:match(suffix)) then
			objectUnit = objectUnit .. suffix
		end

		object.__elements = {}
		object.style = style
		object = setmetatable(object, frame_metatable)

		-- Expose the frame through oUF.objects.
		tinsert(objects, object)

		-- We have to force update the frames when PEW fires.
		-- It's also important to evaluate units before running an update
		-- because sometimes events that are required for unit updates end up
		-- not firing because of loading screens. For instance, there's a slight
		-- delay between UNIT_EXITING_VEHICLE and UNIT_EXITED_VEHICLE during
		-- which a user can go through a loading screen after which the player
		-- frame will be stuck with the 'vehicle' unit.
		object:RegisterEvent('PLAYER_ENTERING_WORLD', evalUnitAndUpdate, true)

		if(not isEventlessUnit(objectUnit)) then
			object:RegisterEvent('UNIT_ENTERED_VEHICLE', evalUnitAndUpdate)
			object:RegisterEvent('UNIT_EXITED_VEHICLE', evalUnitAndUpdate)

			-- We don't need to register UNIT_PET for the player unit. We register it
			-- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE don't always
			-- have pet information when they fire for party and raid units.
			if(objectUnit ~= 'player') then
				object:RegisterEvent('UNIT_PET', updatePet)
			end
		end

		if(not header) then
			-- No header means it's a frame created through :Spawn().
			object:SetAttribute('*type1', 'target')
			object:SetAttribute('*type2', 'togglemenu')
			object:SetAttribute('toggleForVehicle', true)

			if(isEventlessUnit(objectUnit)) then
				oUF:HandleEventlessUnit(object)
			else
				oUF:HandleUnit(object)
			end
		else
			-- update the frame when its prev unit is replaced with a new one
			-- updateRaid relies on UnitGUID to detect the unit change
			object:RegisterEvent('GROUP_ROSTER_UPDATE', updateRaid, true)

			if(num > 1) then
				if(object:GetParent() == header) then
					object.hasChildren = true
				else
					object.isChild = true
				end
			end

			if(suffix == 'target') then
				oUF:HandleEventlessUnit(object)
			end
		end

		Private.UpdateUnits(object, objectUnit)

		styleFunc(object, objectUnit, not header)

		object:HookScript('OnAttributeChanged', onAttributeChanged)

		-- NAME_PLATE_UNIT_ADDED fires after the frame is shown, so there's no
		-- need to call UAE multiple times
		if(not object.isNamePlate) then
			object:SetScript('OnShow', onShow)

			-- Make Clique kinda happy
			_G.ClickCastFrames = _G.ClickCastFrames or {}
			_G.ClickCastFrames[object] = true
		end

		activeElements[object] = {}
		for element in next, elements do
			object:EnableElement(element, objectUnit)
		end

		for _, func in next, callback do
			func(object)
		end
	end
end

local function walkObject(object, unit)
	local parent = object:GetParent()
	local style = parent.style or style
	local styleFunc = styles[style]

	local header = parent:GetAttribute('oUF-headerType') and parent

	-- Check if we should leave the main frame blank.
	if(object:GetAttribute('oUF-onlyProcessChildren')) then
		object.hasChildren = true
		object:HookScript('OnAttributeChanged', onAttributeChanged)
		return initObject(unit, style, styleFunc, header, object:GetChildren())
	end

	return initObject(unit, style, styleFunc, header, object, object:GetChildren())
end

--[[ oUF:RegisterInitCallback(func)
Used to add a function to a table to be executed upon unit frame/header initialization.

* self - the global oUF object
* func - function to be added
--]]
function oUF:RegisterInitCallback(func)
	tinsert(callback, func)
end

--[[ oUF:RegisterMetaFunction(name, func)
Used to make a (table of) function(s) available to all unit frames.

* self - the global oUF object
* name - unique name of the function (string)
* func - function or a table of functions (function or table)
--]]
function oUF:RegisterMetaFunction(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(frame_metatable.__index[name]) then
		return
	end

	frame_metatable.__index[name] = func
end

--[[ oUF:RegisterStyle(name, func)
Used to register a style with oUF. This will also set the active style if it hasn't been set yet.

* self - the global oUF object
* name - name of the style
* func - function(s) defining the style (function or table)
--]]
function oUF:RegisterStyle(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(styles[name]) then return nierror(format('Style [%s] already registered.', name)) end
	if(not style) then style = name end

	styles[name] = func
end

--[[ oUF:SetActiveStyle(name)
Used to set the active style.

* self - the global oUF object
* name - name of the style (string)
--]]
function oUF:SetActiveStyle(name)
	argcheck(name, 2, 'string')
	if(not styles[name]) then return nierror('Style [%s] does not exist.', name) end

	style = name
end

--[[ oUF:GetActiveStyle()
Used to get the active style.

* self - the global oUF object
--]]
function oUF:GetActiveStyle()
	return style
end

do
	local function iter(_, n)
		-- don't expose the style functions.
		return (next(styles, n))
	end

	--[[ oUF:IterateStyles()
	Returns an iterator over all registered styles.

	* self - the global oUF object
	--]]
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

		for i = 1, select('#', ...) do
			local short = select(i, ...)

			local condition = conditions[short]
			if(condition) then
				cond = cond .. condition
			end
		end

		return cond .. 'hide'
	end
end

local function createName(unit, attributes)
	local name = 'oUF_' .. style:gsub('^oUF_?', ''):gsub('[^%a%d_]+', '')

	local raid, party, groupFilter, unitsuffix
	for att, val in next, attributes do
		if(att == 'oUF-initialConfigFunction') then
			unitsuffix = val:match('unitsuffix[%p%s]+(%a+)')
		elseif(att == 'showRaid') then
			raid = val ~= false and val ~= nil
		elseif(att == 'showParty') then
			party = val ~= false and val ~= nil
		elseif(att == 'groupFilter') then
			groupFilter = val
		end
	end

	local append
	if(raid) then
		if(groupFilter) then
			if(type(groupFilter) == 'number' and groupFilter > 0) then
				append = 'Raid' .. groupFilter
			elseif(groupFilter:match('MAINTANK')) then
				append = 'MainTank'
			elseif(groupFilter:match('MAINASSIST')) then
				append = 'MainAssist'
			else
				local _, count = groupFilter:gsub(',', '')
				if(count == 0) then
					append = 'Raid' .. groupFilter
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
		append = unit:gsub('^%l', strupper)
	end

	if(append) then
		name = name .. append .. (unitsuffix or '')
	end

	-- Change oUF_LilyRaidRaid into oUF_LilyRaid
	name = name:gsub('(%u%l+)([%u%l]*)%1', '%1')
	-- Change oUF_LilyTargettarget into oUF_LilyTargetTarget
	name = name:gsub('t(arget)', 'T%1')
	name = name:gsub('p(et)', 'P%1')
	name = name:gsub('f(ocus)', 'F%1')

	local base = name
	local i = 2
	while(_G[name]) do
		name = base .. i
		i = i + 1
	end

	return name
end

local function generateName(unit, ...)
	local name = 'oUF_' .. style:gsub('^oUF_?', ''):gsub('[^%a%d_]+', '')

	local raid, party, groupFilter, unitsuffix
	for i = 1, select('#', ...), 2 do
		local att, val = select(i, ...)
		if(att == 'oUF-initialConfigFunction') then
			unitsuffix = val:match('unitsuffix[%p%s]+(%a+)')
		elseif(att == 'showRaid') then
			raid = val ~= false and val ~= nil
		elseif(att == 'showParty') then
			party = val ~= false and val ~= nil
		elseif(att == 'groupFilter') then
			groupFilter = val
		end
	end

	local append
	if(raid) then
		if(groupFilter) then
			if(type(groupFilter) == 'number' and groupFilter > 0) then
				append = 'Raid' .. groupFilter
			elseif(groupFilter:match('MAINTANK')) then
				append = 'MainTank'
			elseif(groupFilter:match('MAINASSIST')) then
				append = 'MainAssist'
			else
				local _, count = groupFilter:gsub(',', '')
				if(count == 0) then
					append = 'Raid' .. groupFilter
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
		append = unit:gsub('^%l', strupper)
	end

	if(append) then
		name = name .. append .. (unitsuffix or '')
	end

	-- Change oUF_LilyRaidRaid into oUF_LilyRaid
	name = name:gsub('(%u%l+)([%u%l]*)%1', '%1')
	-- Change oUF_LilyTargettarget into oUF_LilyTargetTarget
	name = name:gsub('t(arget)', 'T%1')
	name = name:gsub('p(et)', 'P%1')
	name = name:gsub('f(ocus)', 'F%1')

	local base = name
	local i = 2
	while(_G[name]) do
		name = base .. i
		i = i + 1
	end

	return name
end

do
	local function styleProxy(self, frame)
		return walkObject(_G[frame])
	end

	-- There has to be an easier way to do this.
	local initialConfigFunction = [[
		local header = self:GetParent()
		local frames = table.new()
		table.insert(frames, self)
		self:GetChildList(frames)
		for i = 1, #frames do
			local frame = frames[i]
			local unit
			-- There's no need to do anything on frames with onlyProcessChildren
			if(not frame:GetAttribute('oUF-onlyProcessChildren')) then
				RegisterUnitWatch(frame)

				-- Attempt to guess what the header is set to spawn.
				local groupFilter = header:GetAttribute('groupFilter')

				if(type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]')) then
					local role = groupFilter:match('MAIN([AT])')
					if(role == 'T') then
						unit = 'maintank'
					else
						unit = 'mainassist'
					end
				elseif(header:GetAttribute('showRaid')) then
					unit = 'raid'
				elseif(header:GetAttribute('showParty')) then
					unit = 'party'
				end

				local headerType = header:GetAttribute('oUF-headerType')
				local suffix = frame:GetAttribute('unitsuffix')
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
				frame:SetAttribute('*type2', 'togglemenu')
				frame:SetAttribute('oUF-guessUnit', unit)
			end

			local body = header:GetAttribute('oUF-initialConfigFunction')
			if(body) then
				frame:Run(body, unit)
			end
		end

		header:CallMethod('styleFunction', self:GetName())

		local clique = header:GetFrameRef('clickcast_header')
		if(clique) then
			clique:SetAttribute('clickcast_button', self)
			clique:RunAttribute('clickcast_register')
		end
	]]

	local headerMixin = {}
	--[[ header:SetVisibility(visibility)
	Sets the macro conditional(s) controlling when to display the header (string).
	--]]
	function headerMixin:SetVisibility(visibility)
		argcheck(visibility, 2, 'string', 'nil')

		local _type, list = strsplit(' ', visibility, 2)
		if(list and _type == 'custom') then
			RegisterAttributeDriver(self, 'state-visibility', list)
			self.visibility = list
		else
			local condition = getCondition(strsplit(',', visibility))
			RegisterAttributeDriver(self, 'state-visibility', condition)
			self.visibility = condition
		end
	end

	--[[ oUF:SpawnHeader(overrideName, template, ...)
	Used to create a group header and apply the currently active style to it.

	* self         - the global oUF object
	* overrideName - unique global name to be used for the header. Defaults to an auto-generated name based on the name
	                 of the active style and other arguments passed to `:SpawnHeader` (string?)
	* template     - name of a template to be used for creating the header. Defaults to `'SecureGroupHeaderTemplate'`
	                 (string?)
	* ...          - further argument pairs. Consult [Group Headers](https://warcraft.wiki.gg/wiki/SecureGroupHeaderTemplate)
	                 for possible values. If preferred, the attributes can be an associative table.

	In addition to the standard group headers, oUF implements some of its own attributes. These can be supplied by the
	layout, but are optional. PingableUnitFrameTemplate is inherited for Ping support.

	* oUF-initialConfigFunction - can contain code that will be securely run at the end of the initial secure
	                              configuration (string?)
	* oUF-onlyProcessChildren   - can be used to force headers to only process children (boolean?)
	--]]
	function oUF:SpawnHeader(overrideName, template, attributes)
		if(not style) then return nierror('Unable to create frame. No styles have been registered.') end

		template = (template or 'SecureGroupHeaderTemplate')

		local isPetHeader = template:match('PetHeader')
		local name = overrideName or createName(nil, attributes)
		local header = Mixin(CreateFrame('Frame', name, UFParentHider, template), headerMixin)

		header:SetAttribute('template', 'SecureUnitButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate' .. (oUF.isRetail and ', PingableUnitFrameTemplate' or ''))

		for att, val in next, attributes do
			header:SetAttribute(att, val)
		end

		header.style = style
		header.styleFunction = styleProxy

		-- Expose the header through oUF.headers.
		tinsert(headers, header)

		-- We set it here so layouts can't directly override it.
		header:SetAttribute('initialConfigFunction', initialConfigFunction)
		header:SetAttribute('_initialAttributeNames', '_onenter,_onleave,refreshUnitChange,_onstate-vehicleui')
		header:SetAttribute('_initialAttribute-_onenter', [[
			local snippet = self:GetAttribute('clickcast_onenter')
			if(snippet) then
				self:Run(snippet)
			end
		]])
		header:SetAttribute('_initialAttribute-_onleave', [[
			local snippet = self:GetAttribute('clickcast_onleave')
			if(snippet) then
				self:Run(snippet)
			end
		]])
		header:SetAttribute('_initialAttribute-refreshUnitChange', [[
			local unit = self:GetAttribute('unit')
			if(unit) then
				RegisterStateDriver(self, 'vehicleui', '[@' .. unit .. ',unithasvehicleui]vehicle; novehicle')
			else
				UnregisterStateDriver(self, 'vehicleui')
			end
		]])
		header:SetAttribute('_initialAttribute-_onstate-vehicleui', [[
			local unit = self:GetAttribute('unit')
			if(newstate == 'vehicle' and unit and UnitPlayerOrPetInRaid(unit) and not UnitTargetsVehicleInRaidUI(unit)) then
				self:SetAttribute('toggleForVehicle', false)
			else
				self:SetAttribute('toggleForVehicle', true)
			end
		]])
		header:SetAttribute('oUF-headerType', isPetHeader and 'pet' or 'group')

		if(_G.Clique) then
			SecureHandlerSetFrameRef(header, 'clickcast_header', _G.Clique.header)
		end

		if(header:GetAttribute('showParty')) then
			self:DisableBlizzard('party')
		end

		return header
	end
end

--[[ oUF:Spawn(unit, overrideName)
Used to create a single unit frame and apply the currently active style to it.

* self         - the global oUF object
* unit         - the frame's unit (string)
* overrideName - unique global name to use for the unit frame. Defaults to an auto-generated name based on the unit
                 (string?)

oUF implements some of its own attributes. These can be supplied by the layout, but are optional.
PingableUnitFrameTemplate is inherited for Ping support.

* oUF-enableArenaPrep - can be used to toggle arena prep support. Defaults to true (boolean)
--]]
function oUF:Spawn(unit, overrideName, overrideTemplate) -- ElvUI adds overrideTemplate
	argcheck(unit, 2, 'string')
	if(not style) then return nierror('Unable to create frame. No styles have been registered.') end

	unit = unit:lower()

	local name = overrideName or createName(unit)
	local object = CreateFrame('Button', name, UFParentHider, overrideTemplate or (oUF.isRetail and 'SecureUnitButtonTemplate, PingableUnitFrameTemplate') or 'SecureUnitButtonTemplate')
	Private.UpdateUnits(object, unit)

	self:DisableBlizzard(unit)
	walkObject(object, unit)

	object:SetAttribute('unit', unit)
	RegisterUnitWatch(object)

	return object
end

do
	local hitInset = 10000 -- some large number that will ensure we have full coverage
	local function updateDriver(driver)
		if(SetNamePlateSize and IsLoggedIn()) then
			SetNamePlateSize(driver.plateWidth or 200, driver.plateHeight or 30)

			if SetNamePlateHitTestInsets then
				local enemyInset = driver.enemyNonInteractible and hitInset or -hitInset
				SetNamePlateHitTestInsets(NAMEPLATE_TYPE.Enemy, enemyInset, enemyInset, enemyInset, enemyInset)

				local friendlyInset = driver.friendlyNonInteractible and hitInset or -hitInset
				SetNamePlateHitTestInsets(NAMEPLATE_TYPE.Friendly, friendlyInset, friendlyInset, friendlyInset, friendlyInset)
			end

			if(driver.cvars) then
				for name, value in next, driver.cvars do
					SetCVar(name, value)
				end
			end
		end
	end

	local nameplateDriverMixin = {}
	--[[ nameplates:SetTargetCallback(callback)
	Sets a callback function to be triggered whenever a nameplate has been targeted.
	The payload for the callback is `(nameplate, event, unit)`.
	--]]
	function nameplateDriverMixin:SetTargetCallback(callback)
		argcheck(callback, 2, 'function', 'nil')
		self.targetCallback = callback
	end
	--[[ nameplates:SetAddedCallback(callback)
	Sets a callback function to be triggered whenever a nameplate has been added.
	The payload for the callback is `(nameplate, event, unit)`.
	--]]
	function nameplateDriverMixin:SetAddedCallback(callback)
		argcheck(callback, 2, 'function', 'nil')
		self.addedCallback = callback
	end
	--[[ nameplates:SetRemovedCallback(callback)
	Sets a callback function to be triggered whenever a nameplate has been removed.
	The payload for the callback is `(nameplate, event, unit)`.
	--]]
	function nameplateDriverMixin:SetRemovedCallback(callback)
		argcheck(callback, 2, 'function', 'nil')
		self.removedCallback = callback
	end

	--[[ nameplates:SetSize(width[, height])
	Sets the width and size for all nameplates.
	If only width is provided it will also be used for the height.
	The default width is `200`, and the default height is `30`.
	--]]
	function nameplateDriverMixin:SetSize(width, height)
		argcheck(width, 2, 'number')
		argcheck(height, 3, 'number', 'nil')

		self.plateWidth = width
		self.plateHeight = height or width

		updateDriver(self)
	end

	--[[ nameplates:SetEnemyInteractible(state)
	Sets the interactible state for enemy nameplates.
	They are interactible by default.
	--]]
	function nameplateDriverMixin:SetEnemyInteractible(state)
		self.enemyNonInteractible = not state

		updateDriver(self)
	end

	--[[ nameplates:SetFriendlyInteractible(state)
	Sets the interactible state for friendly nameplates.
	They are interactible by default.
	--]]
	function nameplateDriverMixin:SetFriendlyInteractible(state)
		self.friendlyNonInteractible = not state

		updateDriver(self)
	end

	--[[ nameplates:SetCVars(variables)
	Sets console variables from key/value table.
	--]]
	--[[ nameplates:SetCVars(name, value[, ...])
	Sets console variables from key/value parameters.
	--]]
	function nameplateDriverMixin:SetCVars(...)
		if(type(...) == 'table') then
			self.cvars = ...
		else
			self.cvars = {}
			for index = 1, select('#', ...), 2 do
				local name, value = select(index, ...)
				if(not name) then break end
				self.cvars[name] = value
			end
		end

		updateDriver(self)
	end

	local function driverEventHandler(self, event, unit)
		if(event == 'PLAYER_LOGIN') then
			updateDriver(self)
		elseif(event == 'PLAYER_TARGET_CHANGED') then
			local nameplate = GetNamePlateForUnit('target')
			if(not nameplate or not nameplate.unitFrame) then return end

			if(self.targetCallback) then
				self.targetCallback(nameplate.unitFrame, event, 'target')
			end

			-- UAE is called after the callback to reduce the number of
			-- ForceUpdate calls layouts have to do after changing things
			nameplate.unitFrame:UpdateAllElements(event)
		elseif(event == 'NAME_PLATE_UNIT_ADDED') then
			local nameplate = GetNamePlateForUnit(unit)
			if(not nameplate) then return end

			oUF:DisableBlizzardNamePlate(nameplate)

			if(not nameplate.unitFrame) then
				nameplate.style = self.style

				nameplate.unitFrame = CreateFrame('Button', self.prefix .. nameplate:GetName(), nameplate, oUF.isRetail and 'PingableUnitFrameTemplate' or '')
				nameplate.unitFrame:EnableMouse(false)
				nameplate.unitFrame:SetAllPoints()
				nameplate.unitFrame.isNamePlate = true

				Private.UpdateUnits(nameplate.unitFrame, unit)

				walkObject(nameplate.unitFrame, unit)
			else
				Private.UpdateUnits(nameplate.unitFrame, unit)
			end

			nameplate.unitFrame:SetAttribute('unit', unit)

			if(nameplate.UnitFrame) then
				if(nameplate.UnitFrame.WidgetContainer) then
					nameplate.UnitFrame.WidgetContainer:SetParent(nameplate.unitFrame)
					nameplate.UnitFrame.WidgetContainer:SetIgnoreParentAlpha(true)
					nameplate.unitFrame.WidgetContainer = nameplate.UnitFrame.WidgetContainer
				end
				if(nameplate.UnitFrame.SoftTargetFrame) then
					-- we keep this to render soft target interaction icons above the "target"
					nameplate.UnitFrame.SoftTargetFrame:SetParent(nameplate.unitFrame)
					nameplate.UnitFrame.SoftTargetFrame:SetIgnoreParentAlpha(true)
					nameplate.unitFrame.SoftTargetFrame = nameplate.UnitFrame.SoftTargetFrame
				end
			end

			if(self.addedCallback) then
				self.addedCallback(nameplate.unitFrame, event, unit)
			end

			-- UAE is called after the callback to reduce the number of
			-- ForceUpdate calls layouts have to do after changing things
			nameplate.unitFrame:UpdateAllElements(event)
		elseif(event == 'NAME_PLATE_UNIT_REMOVED') then
			local nameplate = GetNamePlateForUnit(unit)
			if(not nameplate or not nameplate.unitFrame) then return end

			nameplate.unitFrame:SetAttribute('unit', nil)

			if(self.removedCallback) then
				self.removedCallback(nameplate.unitFrame, event, unit)
			end
		end
	end

	--[[ oUF:SpawnNamePlates(prefix)
	Used to create nameplates and apply the currently active style to them.

	* self      - the global oUF object
	* prefix    - prefix for the global name of the nameplate. Defaults to an auto-generated prefix (string?)

	PingableUnitFrameTemplate is inherited for Ping support.
	--]]
	function oUF:SpawnNamePlates(namePrefix)
		if(not style) then return nierror('Unable to create frame. No styles have been registered.') end

		local driverName = (global or parent) .. '_NamePlateDriver'
		if(_G[driverName]) then return nierror('oUF nameplate driver has already been initialized.') end

		local nameplateDriver = Mixin(CreateFrame('Frame', driverName), nameplateDriverMixin)
		nameplateDriver:SetScript('OnEvent', driverEventHandler)

		nameplateDriver.style = style
		nameplateDriver.prefix = namePrefix or generateName()

		nameplateDriver:RegisterEvent('NAME_PLATE_UNIT_ADDED')
		nameplateDriver:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
		nameplateDriver:RegisterEvent('PLAYER_TARGET_CHANGED')

		if(IsLoggedIn()) then
			updateDriver(nameplateDriver)
		else
			nameplateDriver:RegisterEvent('PLAYER_LOGIN')
		end

		return nameplateDriver
	end
end

--[[ oUF:AddElement(name, update, enable, disable)
Used to register an element with oUF.

* self    - the global oUF object
* name    - unique name of the element (string)
* update  - used to update the element (function)
* enable  - used to enable the element for a given unit frame and unit (function)
* disable - used to disable the element for a given unit frame (function)
--]]
function oUF:AddElement(name, update, enable, disable)
	argcheck(name, 2, 'string')
	argcheck(update, 3, 'function', 'nil')
	argcheck(enable, 4, 'function')
	argcheck(disable, 5, 'function')

	if(elements[name]) then return nierror(format('Element [%s] is already registered.', name)) end

	elements[name] = {
		update = update,
		enable = enable,
		disable = disable
	}
end

function oUF:GetSpellInfo(spellID)
	local info = spellID and C_Spell_GetSpellInfo(spellID)
	if not info then return end

	return info.name, nil, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID
end

oUF.version = _VERSION
--[[ oUF.objects
Array containing all unit frames created by `oUF:Spawn`.
--]]
oUF.objects = objects
--[[ oUF.headers
Array containing all group headers created by `oUF:SpawnHeader`.
--]]
oUF.headers = headers

if(global) then
	if(parent ~= 'oUF' and global == 'oUF') then
		nierror(format('%s is doing it wrong and setting its global to "oUF".', parent))
	elseif(_G[global]) then
		nierror(format('%s is setting its global to an existing name "%s".', parent, global))
	else
		_G[global] = oUF
	end
end
