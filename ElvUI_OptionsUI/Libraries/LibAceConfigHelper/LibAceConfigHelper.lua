local LibStub = LibStub
local MAJOR, MINOR = "LibAceConfigHelper", 1
local ACH = LibStub:NewLibrary(MAJOR, MINOR)

if not ACH then return end

local wipe = wipe
local optionTable = {}

function ACH:Color(name, desc, order, arg, alpha, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "color"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.hasAlpha = alpha
	optionTable.arg = arg
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden

	return optionTable
end

function ACH:Description(name, order, fontSize, hidden)
	wipe(optionTable)

	optionTable.type = "description"
	optionTable.name = name
	optionTable.order = order
	optionTable.hidden = hidden
	optionTable.fontSize = fontSize

	return optionTable
end

function ACH:Execute(name, desc, order, arg, func, confirm, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "execute"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.arg = arg
	optionTable.func = func
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden
	optionTable.confirm = confirm and true
	optionTable.confirmText = confirm

	return optionTable
end

function ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "group"
	optionTable.childGroups = childGroups
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.set = set
	optionTable.get = get
	optionTable.hidden = hidden
	optionTable.disabled = disabled
	optionTable.args = {}

	return optionTable
end

function ACH:Header(name, order, hidden)
	wipe(optionTable)

	optionTable.type = "header"
	optionTable.name = name
	optionTable.order = order
	optionTable.hidden = hidden

	return optionTable
end

function ACH:Input(name, desc, order, arg, values, width, get, set, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "input"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.arg = arg
	optionTable.width = width
	optionTable.get = get
	optionTable.set = set
	optionTable.disabled = disabled
	optionTable.hidden = hidden
	optionTable.values = values

	return optionTable
end

function ACH:Select(name, desc, order, arg, values, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "select"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.values = values
	optionTable.arg = arg
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden

	return optionTable
end

function ACH:MultiSelect(name, desc, order, arg, values, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "multiselect"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.values = values
	optionTable.arg = arg
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden

	return optionTable
end

function ACH:Toggle(name, desc, order, arg, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "toggle"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.arg = arg
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden

	return optionTable
end

-- Values are the following: key = value
-- min - min value
-- max - max value
-- softMin - "soft" minimal value, used by the UI for a convenient limit while allowing manual input of values up to min/max
-- softMax - "soft" maximal value, used by the UI for a convenient limit while allowing manual input of values up to min/max
-- step - step value: "smaller than this will break the code" (default=no stepping limit)
-- bigStep - a more generally-useful step size. Support in UIs is optional.
-- isPercent (boolean) - represent e.g. 1.0 as 100%, etc. (default=false)

function ACH:Range(name, desc, order, values, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "range"
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden

	for key, value in pairs(values) do
		optionTable[key] = value
	end

	return optionTable
end

function ACH:SharedMediaSelect(type, name, desc, order, arg, values, width, disabled, hidden)
	wipe(optionTable)

	optionTable.type = "select"
	optionTable.dialogControl = type
	optionTable.name = name
	optionTable.desc = desc
	optionTable.order = order
	optionTable.values = values
	optionTable.arg = arg
	optionTable.width = width
	optionTable.disabled = disabled
	optionTable.hidden = hidden

	return optionTable
end

function ACH:SharedMediaFont(name, desc, order, arg, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Font", name, desc, order, arg, values, width, disabled, hidden)
end

function ACH:SharedMediaSound(name, desc, order, arg, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Sound", name, desc, order, arg, values, width, disabled, hidden)
end

function ACH:SharedMediaStatusbar(name, desc, order, arg, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Statusbar", name, desc, order, arg, values, width, disabled, hidden)
end

function ACH:SharedMediaBackground(name, desc, order, arg, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Background", name, desc, order, arg, values, width, disabled, hidden)
end

function ACH:SharedMediaBorder(name, desc, order, arg, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Border", name, desc, order, arg, values, width, disabled, hidden)
end
