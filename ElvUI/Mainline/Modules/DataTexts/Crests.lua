local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local next = next
local format, floor = format, floor

local GetItemCount = GetItemCount
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local FRAGMENTS_EARNED = gsub(_G.ITEM_UPGRADE_FRAGMENTS_TOTAL, '%s*|c.+$', '')

local crests = {
	{ -- Flightstones
		id = 2245,
		fragment = false,
		color = _G.HEIRLOOM_BLUE_COLOR
	},
	{ -- Whelpling's Shadowflame Crest
		id = 204193,
		fragment = 204075,
		fragmentCap = 2409,
		color = _G.UNCOMMON_GREEN_COLOR
	},
	{ -- Drake's Shadowflame Crest
		id = 204195,
		fragment = 204076,
		fragmentCap = 2410,
		color = _G.RARE_BLUE_COLOR
	},
	{ -- Wyrm's Shadowflame Crest
		id = 204196,
		fragment = 204077,
		fragmentCap = 2411,
		color = _G.EPIC_PURPLE_COLOR
	},
	{ -- Aspect's Shadowflame Crest
		id = 204194,
		fragment = 204078,
		fragmentCap = 2412,
		color = _G.LEGENDARY_ORANGE_COLOR
	}
}

local currency = {}
local crestText = '|T%s:16:16:0:0:64:64:4:60:4:60|t %s / %s'
local fragmentText, fragmentSplit, fragmentAdd = '%s | %s', '%s / 15', '%s+%s'

local function GetFragmentText(text, crest, count, fragments)
	return format(fragmentText, text, crest.color:WrapTextInColorCode((fragments and fragments > 0) and format(fragmentAdd, count, fragments) or count))
end

local function GetCrestText(crest, currency)
	return crest.color:WrapTextInColorCode(format(crestText, currency.iconFileID, currency.quantity, currency.maxQuantity))
end

local function OnEvent(self)
	local text = ''
	for _, crest in next, crests do
		if crest.fragment then
			text = GetFragmentText(text, crest, GetItemCount(crest.id) or 0, floor((GetItemCount(crest.fragment) or 0) / 15))
		else
			currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
			text = crest.color:WrapTextInColorCode(currency.quantity)
		end
	end

	self.text:SetFormattedText(text)
end

local function OnEnter(self)
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(FRAGMENTS_EARNED)

	for _, crest in next, crests do
		local currency = C_CurrencyInfo_GetCurrencyInfo(crest.fragment and crest.fragmentCap or crest.id)
		if currency then
			if crest.fragment then
				if currency.maxQuantity > 0 then
					DT.tooltip:AddDoubleLine(GetCrestText(crest, currency), format(fragmentSplit, GetItemCount(crest.fragment) or 0))
				end
			else
				DT.tooltip:AddLine(GetCrestText(crest, currency))
			end
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext(format('%s %s', _G.EXPANSION_NAME9, _G.ARCHAEOLOGY_RUNE_STONES), _G.CURRENCY, {'BAG_UPDATE', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter)

