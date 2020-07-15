local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local pairs = pairs
local strjoin = strjoin
local HasNewMail = HasNewMail
local GetLatestThreeSenders = GetLatestThreeSenders
local HAVE_MAIL_FROM = HAVE_MAIL_FROM
local MAIL_LABEL = MAIL_LABEL

local displayString, lastPanel = ''

local function OnEvent(self)
	lastPanel = self
	self.text:SetFormattedText(displayString, HasNewMail() and "New Mail" or "No Mail")
end

local function OnEnter(self)
	local senders = { GetLatestThreeSenders() }
	if #senders > 0 then
		DT:SetupTooltip(self)
		DT.tooltip:AddLine(HasNewMail() and HAVE_MAIL_FROM or MAIL_LABEL, 1, 1, 1)
		DT.tooltip:AddLine(' ')
		for _, sender in pairs(senders) do
			DT.tooltip:AddLine(sender)
		end

		DT.tooltip:Show()
	end
end

local function ValueColorUpdate(hex)
	displayString = strjoin(hex, "%s|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Mail', nil, {'MAIL_INBOX_UPDATE', 'UPDATE_PENDING_MAIL', 'MAIL_CLOSED', 'MAIL_SHOW'}, OnEvent, nil, nil, OnEnter, nil, MAIL_LABEL)
