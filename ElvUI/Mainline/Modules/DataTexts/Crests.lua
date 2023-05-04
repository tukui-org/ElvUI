local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local next = next
local format, floor = format, floor

local GetItemCount = GetItemCount
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local FRAGMENTS_EARNED = gsub(_G.ITEM_UPGRADE_FRAGMENTS_TOTAL, '%s*|c.+$', '')

local crests = {
	[2245] = { -- Flightstones
		fragment = false,
		color = _G.HEIRLOOM_BLUE_COLOR
	},
	[204193] = { -- Whelpling's Shadowflame Crest
		fragment = 204075,
		fragmentCap = 2409,
		color = _G.UNCOMMON_GREEN_COLOR
	},
	[204195] = { -- Drake's Shadowflame Crest
		fragment = 204076,
		fragmentCap = 2410,
		color = _G.RARE_BLUE_COLOR
	},
	[204196] = { -- Wyrm's Shadowflame Crest
		fragment = 204077,
		fragmentCap = 2411,
		color = _G.EPIC_PURPLE_COLOR
	},
	[204194] = { -- Aspect's Shadowflame Crest
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
	for id, crest in next, crests do
		if crest.fragment then
			text = GetFragmentText(text, crest, GetItemCount(id) or 0, floor((GetItemCount(crest.fragment) or 0) / 15))
		else
			currency = C_CurrencyInfo_GetCurrencyInfo(id)
			text = crest.color:WrapTextInColorCode(currency.quantity)
		end
	end

	self.text:SetFormattedText(text)
end

local function OnEnter(self)
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(FRAGMENTS_EARNED)

	for id, crest in next, crests do
		local currency = C_CurrencyInfo_GetCurrencyInfo(crest.fragment and crest.fragmentCap or id)
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

