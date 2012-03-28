local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.mail ~= true then return end
	
	for i = 1, INBOXITEMS_TO_DISPLAY do
		local b = _G["MailItem"..i.."ExpireTime"]
		b:SetPoint("TOPRIGHT", "MailItem"..i, "TOPRIGHT", -5, -10)
		b.returnicon:SetPoint("TOPRIGHT", b, "TOPRIGHT", 20, 0)	

		S:HandleCheckBox(_G['PostalInboxCB'..i])
	end

	S:HandleButton(PostalSelectOpenButton, true)
	S:HandleButton(PostalSelectReturnButton, true)	
	S:HandleButton(PostalOpenAllButton, true)

	S:HandleNextPrevButton(Postal_ModuleMenuButton, true)
	Postal_ModuleMenuButton:SetPoint('TOPRIGHT', MailFrame, -58, -16)
	S:HandleNextPrevButton(Postal_BlackBookButton, true)
	Postal_BlackBookButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT', 5, 2)
	S:HandleNextPrevButton(Postal_OpenAllMenuButton, true)
	Postal_OpenAllMenuButton:SetPoint('LEFT', PostalOpenAllButton, 'RIGHT', 5, 0)
end

S:RegisterSkin('Postal', LoadSkin)