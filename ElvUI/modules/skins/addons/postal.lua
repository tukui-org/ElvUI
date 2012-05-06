local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.mail ~= true then return end
	
	for i = 1, INBOXITEMS_TO_DISPLAY do
		local b = _G["MailItem"..i.."ExpireTime"]
		b:SetPoint("TOPRIGHT", "MailItem"..i, "TOPRIGHT", -5, -10)
		b.returnicon:SetPoint("TOPRIGHT", b, "TOPRIGHT", 20, 0)	
		
		if _G['PostalInboxCB'..i] then
			S:HandleCheckBox(_G['PostalInboxCB'..i])
		end
	end

	if PostalSelectOpenButton and not PostalSelectOpenButton.handled then
		S:HandleButton(PostalSelectOpenButton, true)
		PostalSelectOpenButton.handled = true;
	end	
	
	if Postal_OpenAllMenuButton and not Postal_OpenAllMenuButton.handled then
		S:HandleNextPrevButton(Postal_OpenAllMenuButton, true)
		Postal_OpenAllMenuButton:SetPoint('LEFT', PostalOpenAllButton, 'RIGHT', 5, 0)
		Postal_OpenAllMenuButton.handled = true;
	end	

	if PostalOpenAllButton and not PostalOpenAllButton.handled then
		S:HandleButton(PostalOpenAllButton, true)
		PostalOpenAllButton.handled = true;
	end	
	
	if PostalSelectReturnButton then
		S:HandleButton(PostalSelectReturnButton, true)	
	end

	if Postal_ModuleMenuButton then
		S:HandleNextPrevButton(Postal_ModuleMenuButton, true)
		Postal_ModuleMenuButton:SetPoint('TOPRIGHT', MailFrame, -58, -16)
	end
	
	if Postal_BlackBookButton then
		S:HandleNextPrevButton(Postal_BlackBookButton, true)
		Postal_BlackBookButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT', 5, 2)
	end
		
	local Postal = LibStub("AceAddon-3.0"):GetAddon("Postal")
	local Postal_OpenAll = Postal:GetModule("OpenAll")	
	Postal_OpenAll.OnEnable_ = Postal_OpenAll.OnEnable
	function Postal_OpenAll:OnEnable(self)
		Postal_OpenAll.OnEnable_(self)
		if Postal_OpenAllMenuButton and not Postal_OpenAllMenuButton.handled then
			S:HandleNextPrevButton(Postal_OpenAllMenuButton, true)
			Postal_OpenAllMenuButton:SetPoint('LEFT', PostalOpenAllButton, 'RIGHT', 5, 0)
			Postal_OpenAllMenuButton.handled = true;
		end

		if PostalOpenAllButton and not PostalOpenAllButton.handled then
			S:HandleButton(PostalOpenAllButton, true)
			PostalOpenAllButton.handled = true;
		end
	end

	local Postal_Select = Postal:GetModule("OpenAll")		
	Postal_Select.OnEnable_ = Postal_Select.OnEnable
	function Postal_Select:OnEnable()
		Postal_Select.OnEnable_(self)
		
		for i = 1, INBOXITEMS_TO_DISPLAY do
			if _G['PostalInboxCB'..i] and not _G['PostalInboxCB'..i].handled then
				S:HandleCheckBox(_G['PostalInboxCB'..i])
				_G['PostalInboxCB'..i].handled = true;
			end
		end		
	end
end

S:RegisterSkin('Postal', LoadSkin)