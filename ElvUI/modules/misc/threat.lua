local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local THREAT = E:NewModule('Threat', 'AceEvent-3.0');

E.Threat = THREAT

function THREAT:UpdatePosition()
	if self.db.position == 'RIGHTCHAT' then
		self.bar:SetInside(RightChatDataPanel)
		self.bar:SetParent(RightChatDataPanel)
	else
		self.bar:SetInside(LeftChatDataPanel)
		self.bar:SetParent(LeftChatDataPanel)	
	end
	
	self.bar.text:FontTemplate(nil, self.db.textSize)
	self.bar:SetFrameStrata('MEDIUM')
end

function THREAT:Update()
	local _, status, percent = UnitDetailedThreatSituation('player', 'target')
	
	if percent and percent > 0 and (IsInGroup() or UnitExists('pet')) then
		local name = UnitName('target')
		self.bar:Show()
		self.bar:SetStatusBarColor(GetThreatStatusColor(status))
		self.bar.text:SetFormattedText('%s: %.0f%%', name, percent)
		self.bar:SetValue(percent)
	else
		self.bar:Hide()
	end
end

function THREAT:ToggleEnable()
	if self.db.enable then
		self:RegisterEvent('PLAYER_TARGET_CHANGED', 'Update')
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', 'Update')
		self:RegisterEvent('GROUP_ROSTER_UPDATE', 'Update')
		self:RegisterEvent('UNIT_PET', 'Update')
		self:Update()
	else
		self.bar:Hide()
		self:UnregisterEvent('PLAYER_TARGET_CHANGED')
		self:UnregisterEvent('UNIT_THREAT_LIST_UPDATE')
		self:UnregisterEvent('GROUP_ROSTER_UPDATE')
		self:UnregisterEvent('UNIT_PET')
	end
end

function THREAT:Initialize()
	self.db = E.db.general.threat
	
	self.bar = CreateFrame('StatusBar', 'ElvUI_ThreatBar', UIParent)
	self.bar:SetStatusBarTexture(E['media'].normTex)
	self.bar:SetMinMaxValues(0, 100)
	self.bar:CreateBackdrop('Default')
	
	self.bar.text = self.bar:CreateFontString(nil, 'OVERLAY')
	self.bar.text:FontTemplate(nil, self.db.textSize)
	self.bar.text:SetPoint('CENTER', self.bar, 'CENTER')
	
	self:UpdatePosition()
	self:ToggleEnable()
end

E:RegisterModule(THREAT:GetName())