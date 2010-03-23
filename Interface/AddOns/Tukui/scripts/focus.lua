if TukuiDB["focus"].enable == true then

	local function SetFocusHotkey(frame)
		frame:SetAttribute(TukuiDB["focus"].arenamodifier.."-type"..TukuiDB["focus"].arenamouseButton,"focus")
	end

	local function CreateFrame_Hook(type, name, parent, template)
		if template == "SecureUnitButtonTemplate" then
			SetFocusHotkey(_G[name])
		end
	end

	hooksecurefunc("CreateFrame", CreateFrame_Hook)

	-- Keybinding override so that models can be shift/alt/ctrl+clicked
	local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
	f:SetAttribute("type1","macro")
	f:SetAttribute("macrotext","/focus mouseover")
	SetOverrideBindingClick(FocuserButton,true,TukuiDB["focus"].arenamodifier.."-BUTTON"..TukuiDB["focus"].arenamouseButton,"FocuserButton")

	-- Set the keybindings on the default unit frames since we won't get any CreateFrame notification about them
	local duf = {
		oUF_Arena1,
		oUF_Arena2,
		oUF_Arena3,
		oUF_Arena4,
		oUF_Arena5,
	}

	for i,frame in pairs(duf) do
		SetFocusHotkey(frame)
	end
end