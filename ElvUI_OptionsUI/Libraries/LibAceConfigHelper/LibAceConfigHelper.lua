local LibStub = LibStub
local MAJOR, MINOR = "LibAceConfigHelper", 1
local ACH = LibStub:NewLibrary(MAJOR, MINOR)

if not ACH then return end

function ACH:Color(name, desc, order, alpha, width, disabled, hidden)
	return { type = "color", name = name, desc = desc, order = order, hasAlpha = alpha, width = width, disabled = disabled, hidden = hidden }
end

function ACH:Description(name, order, fontSize, hidden)
	return { type = "description", name = name, order = order, hidden = hidden, fontSize = fontSize }
end

function ACH:Execute(name, desc, order, func, confirm, width, disabled, hidden)
	return { type = "execute", name = name, desc = desc, order = order, func = func, width = width, disabled = disabled, hidden = hidden, confirm = confirm and true, confirmText = confirm }
end

function ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden)
	return { type = "group", childGroups = childGroups, name = name, desc = desc, order = order, set = set, get = get, hidden = hidden, disabled = disabled, args = {} }
end

function ACH:Header(name, order, hidden)
	return { type = "header", name = name, order = order, hidden = hidden }
end

function ACH:Input(name, desc, order, values, width, get, set, disabled, hidden)
	return { type = "input", name = name, desc = desc, order = order, width = width, get = get, set = set, disabled = disabled, hidden = hidden, values = values }
end

function ACH:Select(name, desc, order, values, width, disabled, hidden)
	return { type = "select", name = name, desc = desc, order = order, values = values, width = width, disabled = disabled, hidden = hidden }
end

function ACH:MultiSelect(name, desc, order, values, width, disabled, hidden)
	return { type = "multiselect" ,name = name, desc = desc, order = order, values = values, width = width, disabled = disabled, hidden = hidden }
end

function ACH:Toggle(name, desc, order, width, disabled, hidden)
	return { type = "toggle", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden }
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
	local optionTable = { type = "range", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden }

	for key, value in pairs(values) do
		optionTable[key] = value
	end

	return optionTable
end

function ACH:SharedMediaSelect(type, name, desc, order, values, width, disabled, hidden)
	return { type = "select", dialogControl = type, name = name, desc = desc, order = order, values = values, width = width, disabled = disabled, hidden = hidden }
end

function ACH:SharedMediaFont(name, desc, order, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Font", name, desc, order, values, width, disabled, hidden)
end

function ACH:SharedMediaSound(name, desc, order, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Sound", name, desc, order, values, width, disabled, hidden)
end

function ACH:SharedMediaStatusbar(name, desc, order, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Statusbar", name, desc, order, values, width, disabled, hidden)
end

function ACH:SharedMediaBackground(name, desc, order, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Background", name, desc, order, values, width, disabled, hidden)
end

function ACH:SharedMediaBorder(name, desc, order, values, width, disabled, hidden)
	return ACH:SharedMediaSelect("LSM30_Border", name, desc, order, values, width, disabled, hidden)
end
