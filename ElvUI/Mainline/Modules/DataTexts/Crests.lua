local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local next = next
local format = format

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo

local CRESTS_EARNED = strsplit('%', _G.CURRENCY_SEASON_TOTAL_MAXIMUM)

local crests = {
	{ -- Flightstones
		id = 2245,
		color = _G.HEIRLOOM_BLUE_COLOR:GenerateHexColor()
	},
	{ -- Whelpling's Dreaming Crest
		id = 2706,
		color = _G.UNCOMMON_GREEN_COLOR:GenerateHexColor()
	},
	{ -- Drake's Dreaming Crest
		id = 2707,
		color = _G.RARE_BLUE_COLOR:GenerateHexColor()
	},
	{ -- Wyrm's Dreaming Crest
		id = 2708,
		color = _G.EPIC_PURPLE_COLOR:GenerateHexColor()
	},
	{ -- Aspect's Dreaming Crest
		id = 2709,
		color = _G.LEGENDARY_ORANGE_COLOR:GenerateHexColor()
	}
}

local crestIcon = '|T%s:16:16:0:0:64:64:4:60:4:60|t'
local crestText = '|c%s%s / %s|r'

local function GetCrestIcon(info)
	return format(crestIcon, info.iconFileID)
end

local function GetCrestText(crest, info)
	return format(crestText, crest.color, info.quantity, info.maxQuantity)
end

local function OnEvent(self)
	local text = ''
	for _, crest in next, crests do
		local currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
		if currency then
			text = format((text == '' and '%s|c%s%s|r') or '%s | |c%s%s|r', text, crest.color, currency.quantity)
		end
	end

	self.text:SetFormattedText(text)
end

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(CRESTS_EARNED)

	for _, crest in next, crests do
		local currency = C_CurrencyInfo_GetCurrencyInfo(crest.id)
		if currency then
			if currency.maxQuantity > 0 then
				DT.tooltip:AddDoubleLine(GetCrestIcon(currency), GetCrestText(crest, currency))
			end
		end
	end

	DT.tooltip:Show()
end

DT:RegisterDatatext(format('%s %s', _G.EXPANSION_NAME9, _G.ARCHAEOLOGY_RUNE_STONES), _G.CURRENCY, {'CHAT_MSG_CURRENCY', 'CURRENCY_DISPLAY_UPDATE'}, OnEvent, nil, nil, OnEnter)
