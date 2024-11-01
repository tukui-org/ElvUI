local LibStub = _G.LibStub
local MAJOR, MINOR = 'LibAceConfigHelper', 13
local ACH = LibStub:NewLibrary(MAJOR, MINOR)
local LSM = LibStub('LibSharedMedia-3.0')

if not ACH then return end
local type, pairs = type, pairs

ACH.FontValues = {
	NONE = 'None',
	OUTLINE = 'Outline',
	THICKOUTLINE = 'Thick',
	SHADOW = '|cff888888Shadow|r',
	SHADOWOUTLINE = '|cff888888Shadow|r Outline',
	SHADOWTHICKOUTLINE = '|cff888888Shadow|r Thick',
	MONOCHROME = '|cFFAAAAAAMono|r',
	MONOCHROMEOUTLINE = '|cFFAAAAAAMono|r Outline',
	MONOCHROMETHICKOUTLINE = '|cFFAAAAAAMono|r Thick'
}

local function insertWidth(opt, width)
	if type(width) == 'number' and width > 5 then
		opt.customWidth = width
	else
		opt.width = width
	end
end

local function insertConfirm(opt, confirm)
	local confirmType = type(confirm)
	opt.confirm = confirmType == 'function' and confirm or true -- func|bool
	opt.confirmText = confirmType == 'string' and confirm or nil
end

function ACH:Color(name, desc, order, alpha, width, get, set, disabled, hidden)
	local optionTable = { type = 'color', name = name, desc = desc, order = order, hasAlpha = alpha, get = get, set = set, disabled = disabled, hidden = hidden }

	if width then insertWidth(optionTable, width) end

	return optionTable
end

function ACH:Description(name, order, fontSize, image, imageCoords, imageWidth, imageHeight, width, hidden)
	local optionTable = { type = 'description', name = name or '', order = order, fontSize = fontSize, image = image, imageCoords = imageCoords, imageWidth = imageWidth, imageHeight = imageHeight, hidden = hidden }

	if width then insertWidth(optionTable, width) end

	return optionTable
end

function ACH:Execute(name, desc, order, func, image, confirm, width, get, set, disabled, hidden)
	local optionTable = { type = 'execute', name = name, desc = desc, order = order, func = func, image = image, get = get, set = set, disabled = disabled, hidden = hidden }

	if width then insertWidth(optionTable, width) end
	if confirm then insertConfirm(optionTable, confirm) end

	return optionTable
end

function ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden, func)
	return { type = 'group', childGroups = childGroups, name = name, desc = desc, order = order, set = set, get = get, disabled = disabled, hidden = hidden, func = func, args = {} }
end

function ACH:Header(name, order, get, set, hidden)
	return { type = 'header', name = name or '', order = order, get = get, set = set, hidden = hidden }
end

function ACH:Input(name, desc, order, multiline, width, get, set, disabled, hidden, validate)
	local optionTable = { type = 'input', name = name, desc = desc, order = order, multiline = multiline, get = get, set = set, disabled = disabled, hidden = hidden, validate = validate }

	if width then insertWidth(optionTable, width) end

	return optionTable
end

function ACH:Select(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
	local optionTable = { type = 'select', name = name, desc = desc, order = order, values = values or {}, get = get, set = set, disabled = disabled, hidden = hidden, sortByValue = sortByValue }

	if width then insertWidth(optionTable, width) end
	if confirm then insertConfirm(optionTable, confirm) end

	return optionTable
end

function ACH:MultiSelect(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
	local optionTable = { type = 'multiselect', name = name, desc = desc, order = order, values = values or {}, get = get, set = set, disabled = disabled, hidden = hidden, sortByValue = sortByValue }

	if width then insertWidth(optionTable, width) end
	if confirm then insertConfirm(optionTable, confirm) end

	return optionTable
end

function ACH:Toggle(name, desc, order, tristate, confirm, width, get, set, disabled, hidden)
	local optionTable = { type = 'toggle', name = name, desc = desc, order = order, tristate = tristate, get = get, set = set, disabled = disabled, hidden = hidden }

	if width then insertWidth(optionTable, width) end
	if confirm then insertConfirm(optionTable, confirm) end

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
	local optionTable = { type = 'range', name = name, desc = desc, order = order, get = get, set = set, disabled = disabled, hidden = hidden }

	if width then insertWidth(optionTable, width) end
	if values and type(values) == 'table' then
		for key, value in pairs(values) do
			optionTable[key] = value
		end
	end

	return optionTable
end

function ACH:Spacer(order, width, hidden)
	local optionTable = { name = ' ', type = 'description', order = order, hidden = hidden }

	if width then insertWidth(optionTable, width) end

	return optionTable
end

local function SharedMediaSelect(controlType, name, desc, order, values, width, get, set, disabled, hidden)
	local optionTable = { type = 'select', dialogControl = controlType, name = name, desc = desc, order = order, values = values, get = get, set = set, disabled = disabled, hidden = hidden }

	if width then insertWidth(optionTable, width) end

	return optionTable
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

function ACH:FontFlags(name, desc, order, width, get, set, disabled, hidden)
	local optionTable = { type = 'select', name = name, desc = desc, order = order, get = get, set = set, disabled = disabled, hidden = hidden, values = ACH.FontValues, sortByValue = true }

	if width then insertWidth(optionTable, width) end

	return optionTable
end
