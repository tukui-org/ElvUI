local LibStub = LibStub
local MAJOR, MINOR = 'LibAceConfigHelper', 1
local ACH = LibStub:NewLibrary(MAJOR, MINOR)
local LSM = LibStub('LibSharedMedia-3.0')

if not ACH then return end

function ACH:Color(name, desc, order, alpha, width, get, set, disabled, hidden)
	return { type = 'color', name = name, desc = desc, order = order, hasAlpha = alpha, width = width, get = get, set = set, disabled = disabled, hidden = hidden }
end

function ACH:Description(name, order, fontSize, image, imageCoords, imageWidth, imageHeight, width, hidden)
	return { type = 'description', name = name, order = order, fontSize = fontSize, image = image, imageCoords = imageCoords, imageWidth = imageWidth, imageHeight = imageHeight, width = width, hidden = hidden }
end

function ACH:Execute(name, desc, order, func, image, confirm, width, get, set, disabled, hidden)
	local optionTable = { type = 'execute', name = name, desc = desc, order = order, func = func, image = image, width = width, get = get, set = set, disabled = disabled, hidden = hidden }

	if confirm then
		local confirmType = type(confirm)
		if confirmType == 'boolean' then
			optionTable.confirm = true
		elseif confirmType == 'string' then
			optionTable.confirm = true
			optionTable.confirmText = confirm
		elseif confirmType == 'function' then
			optionTable.confirm = confirm
		end
	end

	return optionTable
end

function ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden, func)
	return { type = 'group', childGroups = childGroups, name = name, desc = desc, order = order, set = set, get = get, hidden = hidden, disabled = disabled, func = func, args = {} }
end

function ACH:Header(name, order, get, set, hidden)
	return { type = 'header', name = name, order = order, get = get, set = set, hidden = hidden }
end

function ACH:Input(name, desc, order, multiline, width, get, set, disabled, hidden, validate)
	return { type = 'input', name = name, desc = desc, order = order, multiline = multiline, width = width, get = get, set = set, disabled = disabled, hidden = hidden, validate = validate }
end

function ACH:Select(name, desc, order, values, confirm, width, get, set, disabled, hidden)
	local optionTable = { type = 'select', name = name, desc = desc, order = order, values = values, width = width, get = get, set = set, disabled = disabled, hidden = hidden }

	if confirm then
		local confirmType = type(confirm)
		if confirmType == 'boolean' then
			optionTable.confirm = true
		elseif confirmType == 'string' then
			optionTable.confirm = true
			optionTable.confirmText = confirm
		elseif confirmType == 'function' then
			optionTable.confirm = confirm
		end
	end

	return optionTable
end

function ACH:MultiSelect(name, desc, order, values, confirm, width, get, set, disabled, hidden)
	local optionTable = { type = 'multiselect', name = name, desc = desc, order = order, values = values, width = width, get = get, set = set, disabled = disabled, hidden = hidden }

	if confirm then
		local confirmType = type(confirm)
		if confirmType == 'boolean' then
			optionTable.confirm = true
		elseif confirmType == 'string' then
			optionTable.confirm = true
			optionTable.confirmText = confirm
		elseif confirmType == 'function' then
			optionTable.confirm = confirm
		end
	end

	return optionTable
end

function ACH:Toggle(name, desc, order, tristate, confirm, width, get, set, disabled, hidden)
	local optionTable = { type = 'toggle', name = name, desc = desc, order = order, tristate  = tristate, width = width, get = get, set = set, disabled = disabled, hidden = hidden }

	if confirm then
		local confirmType = type(confirm)
		if confirmType == 'boolean' then
			optionTable.confirm = true
		elseif confirmType == 'string' then
			optionTable.confirm = true
			optionTable.confirmText = confirm
		elseif confirmType == 'function' then
			optionTable.confirm = confirm
		end
	end

	return optionTable
end

-- Values are the following: key = value
-- min - min value
-- max - max value
-- softMin - 'soft' minimal value, used by the UI for a convenient limit while allowing manual input of values up to min/max
-- softMax - 'soft' maximal value, used by the UI for a convenient limit while allowing manual input of values up to min/max
-- step - step value: 'smaller than this will break the code' (default=no stepping limit)
-- bigStep - a more generally-useful step size. Support in UIs is optional.
-- isPercent (boolean) - represent e.g. 1.0 as 100%, etc. (default=false)

function ACH:Range(name, desc, order, values, width, get, set, disabled, hidden)
	local optionTable = { type = 'range', name = name, desc = desc, order = order, width = width, get = get, set = set, disabled = disabled, hidden = hidden }

	for key, value in pairs(values) do
		optionTable[key] = value
	end

	return optionTable
end

function ACH:Spacer(order, width)
	return { name = ' ', type = 'description', order = order, width = width }
end

local function SharedMediaSelect(type, name, desc, order, values, width, get, set, disabled, hidden)
	return { type = 'select', dialogControl = type, name = name, desc = desc, order = order, values = values, width = width, get = get, set = set, disabled = disabled, hidden = hidden }
end

function ACH:SharedMediaFont(name, desc, order, width, get, set, disabled, hidden)
	return SharedMediaSelect('LSM30_Font', name, desc, order, function() return LSM:HashTable('font') end, width, get, set, disabled, hidden)
end

function ACH:SharedMediaSound(name, desc, order, width, get, set, disabled, hidden)
	return SharedMediaSelect('LSM30_Sound', name, desc, order, function() return LSM:HashTable('sound') end, width, get, set, disabled, hidden)
end

function ACH:SharedMediaStatusbar(name, desc, order, width, get, set, disabled, hidden)
	return SharedMediaSelect('LSM30_Statusbar', name, desc, order, function() return LSM:HashTable('statusbar') end, width, get, set, disabled, hidden)
end

function ACH:SharedMediaBackground(name, desc, order, width, get, set, disabled, hidden)
	return SharedMediaSelect('LSM30_Background', name, desc, order, function() return LSM:HashTable('background') end, width, get, set, disabled, hidden)
end

function ACH:SharedMediaBorder(name, desc, order, width, get, set, disabled, hidden)
	return SharedMediaSelect('LSM30_Border', name, desc, order, function() return LSM:HashTable('border') end, width, get, set, disabled, hidden)
end
