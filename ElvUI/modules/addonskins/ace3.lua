local E, C, L, DB = unpack(select(2, ...))
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI then return end

local oldRegisterAsWidget = AceGUI.RegisterAsWidget

AceGUI.RegisterAsWidget = function(self, widget)
	local TYPE = widget.type
	--print(TYPE)
	if TYPE == "CheckBox" then
		widget.checkbg:Kill()
		widget.highlight:Kill()
		
		if not widget.skinnedCheckBG then
			widget.skinnedCheckBG = CreateFrame('Frame', nil, widget.frame)
			widget.skinnedCheckBG:SetTemplate('Default')
			widget.skinnedCheckBG:Point('TOPLEFT', widget.checkbg, 'TOPLEFT', 4, -4)
			widget.skinnedCheckBG:Point('BOTTOMRIGHT', widget.checkbg, 'BOTTOMRIGHT', -4, 4)
		end
		
		if widget.skinnedCheckBG.oborder then
			widget.check:SetParent(widget.skinnedCheckBG.oborder)
		else
			widget.check:SetParent(widget.skinnedCheckBG)
		end
	elseif TYPE == "Dropdown" then
		local frame = widget.dropdown
		local button = widget.button
		local text = widget.text
		frame:StripTextures()

		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -20, 0)
		
		E.SkinNextPrevButton(button, true)
		
		if not frame.backdrop then
			frame:CreateBackdrop("Default")
			frame.backdrop:Point("TOPLEFT", 20, -2)
			frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		end
		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', function(this)
			local self = this.obj
			self.pullout.frame:SetTemplate('Default', true)
		end)	
	elseif TYPE == "EditBox" then
	
	end
	return oldRegisterAsWidget(self, widget)
end

