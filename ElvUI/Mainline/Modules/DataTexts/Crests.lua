local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local next = next
local format = format
local strsub = strsub

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local CRESTS_EARNED = strsplit('%', _G.CURRENCY_SEASON_TOTAL_MAXIMUM)

local crests = {
	{ -- Flightstones
		id = 2245,
		color = _G.HEIRLOOM_BLUE_COLOR
	},
	{ -- Whelpling's Dreaming Crest
		id = 2706,
		color = _G.UNCOMMON_GREEN_COLOR
	},
	{ -- Drake's Dreaming Crest
		id = 2707,
		color = _G.RARE_BLUE_COLOR
	},
	{ -- Wyrm's Dreaming Crest
		id = 2708,
		color = _G.EPIC_PURPLE_COLOR
	},
	{ -- Aspect's Dreaming Crest
		id = 2709,
		color = _G.LEGENDARY_ORANGE_COLOR
	}
}

local crestIcon = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local crestText = '%s / %s'

local function GetCrestIcon(crest, info)
	return crest.color:WrapTextInColorCode(format(crestIcon, info.iconFileID))
end

local function GetCrestText(crest, info)
	return crest.color:WrapTextInColorCode(format(crestText, info.quantity, info.maxQuantity))
end

local function OnEvent(self)
	local text = ''
	for _, crest in next, crests do
		local currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
		if currency then
			text = format('%s | %s', text, crest.color:WrapTextInColorCode(currency.quantity))
		end
	end

	self.text:SetFormattedText(strsub(text, 4, -1))
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(CRESTS_EARNED)

	for _, crest in next, crests do
		local currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
		if currency then
			if currency.maxQuantity > 0 then
				DT.tooltip:AddDoubleLine(GetCrestIcon(crest, currency), GetCrestText(crest, currency))
			end
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext(format('%s %s', _G.EXPANSION_NAME9, _G.ARCHAEOLOGY_RUNE_STONES), _G.CURRENCY, {'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter)
