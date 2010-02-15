-- this file is to set a focus without always typing /focus on unit.
-- the main usage for this mini mod is for my ouf_tukz arena, but it also work when you mouseover a target

-- default key to set focus on arena frame or mousever unit is "shift + mouse button 2 (right one)"

if focuskey == true then

	local function SetFocusHotkey(frame)
		frame:SetAttribute(arenamodifier.."-type"..arenamouseButton,"focus")
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
	SetOverrideBindingClick(FocuserButton,true,arenamodifier.."-BUTTON"..arenamouseButton,"FocuserButton")

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