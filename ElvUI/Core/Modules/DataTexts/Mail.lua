local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local next = next
local pairs = pairs
local strjoin = strjoin
local HasNewMail = HasNewMail
local GetLatestThreeSenders = GetLatestThreeSenders
local HAVE_MAIL_FROM = HAVE_MAIL_FROM
local MAIL_LABEL = MAIL_LABEL

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, HasNewMail() and L["New Mail"] or L["No Mail"])
end

local function OnEnter()
	DT.tooltip:ClearLines()

	local senders = { GetLatestThreeSenders() }
	if not next(senders) then return end

	DT.tooltip:AddLine(HasNewMail() and HAVE_MAIL_FROM or MAIL_LABEL, 1, 1, 1)
	DT.tooltip:AddLine(' ')

	for _, sender in pairs(senders) do
		DT.tooltip:AddLine(sender)
	end

	DT.tooltip:Show()
end

local function ApplySettings(_, hex)
	displayString = strjoin('', hex, '%s|r')
end

DT:RegisterDatatext('Mail', nil, {'MAIL_INBOX_UPDATE', 'UPDATE_PENDING_MAIL', 'MAIL_CLOSED', 'MAIL_SHOW'}, OnEvent, nil, nil, OnEnter, nil, MAIL_LABEL, nil, ApplySettings)
