local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format, floor = format, floor

local GetItemCount = GetItemCount
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local crests = {
	{ --Flightstones
		id = 2245,
		fragment = false,
		color = _G.HEIRLOOM_BLUE_COLOR
	},
	{ --Whelpling's Shadowflame Crest
		id = 204193,
		fragment = 204075,
		fragmentCap = 2409,
		color = _G.UNCOMMON_GREEN_COLOR
	},
	{ --Drake's Shadowflame Crest
		id = 204195,
		fragment = 204076,
		fragmentCap = 2410,
		color = _G.RARE_BLUE_COLOR
	},
	{ --Wyrm's Shadowflame Crest
		id = 204196,
		fragment = 204077,
		fragmentCap = 2411,
		color = _G.EPIC_PURPLE_COLOR
	},
	{ --Aspect's Shadowflame Crest
		id = 204194,
		fragment = 204078,
		fragmentCap = 2412,
		color = _G.LEGENDARY_ORANGE_COLOR
	}
}

local currency = {}

local function OnEvent(self, _)
	local payload = ''
	for _, crest in pairs(crests) do
		if crest.fragment then
			local count = GetItemCount(crest.id)
			local fragmentCount = floor(GetItemCount(crest.fragment)/15)
			if fragmentCount > 0 then
				payload = format('%s | %s', payload, crest.color:WrapTextInColorCode(format('%s+%s', count, fragmentCount)))
			else
				payload = format('%s | %s', payload, crest.color:WrapTextInColorCode(count))
			end
		else
			 currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
			 payload = crest.color:WrapTextInColorCode(currency.quantity)
		end
	end
	self.text:SetFormattedText(payload)
end

local function OnEnter(self)
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(strsplit('|c', _G.ITEM_UPGRADE_FRAGMENTS_TOTAL))
	for _, crest in pairs(crests) do
		if crest.fragment then
			currency = C_CurrencyInfo_GetCurrencyInfo(crest.fragmentCap)
			if currency.maxQuantity > 0 then
				DT.tooltip:AddDoubleLine(crest.color:WrapTextInColorCode(format('|T%s:16:16:0:0:64:64:4:60:4:60|t %s / %s', currency.iconFileID, currency.quantity, currency.maxQuantity)), format('%s/15', GetItemCount(crest.fragment)))
			end
		else
			currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
			DT.tooltip:AddLine(crest.color:WrapTextInColorCode(format('|T%s:16:16:0:0:64:64:4:60:4:60|t %s / %s', currency.iconFileID, currency.quantity, currency.maxQuantity)))
		end
	end
	DT.tooltip:Show()
end

DT:RegisterDatatext(format('%s %s', _G.EXPANSION_NAME9, _G.ARCHAEOLOGY_RUNE_STONES), _G.CURRENCY, {'BAG_UPDATE', 'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter)

