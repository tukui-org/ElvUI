  
  --rActionButtonStyler - roth 2009

if buttonskin == true then
	  
	  local FONT					= "Fonts\\ARIALN.ttf"
	  local _G = _G
	  
	  ---------------------------------------
	  -- CONFIG 
	  ---------------------------------------
	  
	  --TEXTURES
	  --default border texture  
	  local rb2_normal_texture    = "Interface\\AddOns\\Tukui\\media\\gloss"
	  --texture when a button flashs --> button becomes ready
	  local rb2_flash_texture     = "Interface\\AddOns\\Tukui\\media\\flash"
	  --hover textures
	  local rb2_hover_texture     = "Interface\\AddOns\\Tukui\\media\\hover"    
	  --texture if you push that button
	  local rb2_pushed_texture    = "Interface\\AddOns\\Tukui\\media\\pushed"
	  --texture that is active when the button is in active state (next melee swing attacks mostly)
	  local rb2_checked_texture   = "Interface\\AddOns\\Tukui\\media\\checked" 
	  --texture used for equipped items, this can differ since you may want to apply a different vertexcolor
	  local rb2_equipped_texture  = "Interface\\AddOns\\Tukui\\media\\gloss"

	  --FONT
	  --the font you want to use for your button texts
	  local button_font = "Fonts\\FRIZQT__.TTF"
		
	  --COLORS
	  --color you want to appy to the standard texture (red, green, blue in RGB)
	  --local color = { r = 0.6, g = 0.6, b = 0.6, }
	  --want class color? just comment in this:
	  --local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	  --color for equipped border texture (red, green, blue in RGB)
	  --local color_equipped = { r = 0.6, g = 0.6, b = 0.6, }
	  
	  --color when out of range
	  local range_color = { r = 0.8, g = 0.1, b = 0.1, }
		
	--color when out of power (mana)
	  local mana_color = { r = 0.1, g = 0.3, b = 1, }

	  --color when button is usable
	  local usable_color = { r = 1, g = 1, b = 1, }
	  
	  --color when button is unusable (example revenge not active, since you have not blocked yet)
	  local unusable_color = { r = 0.4, g = 0.4, b = 0.4, }

	  -- !!!IMPORTANT!!! - read this before editing the value blow
	  -- !!!do not set this below 0.1 ever!!!
	  -- you have 120 actionbuttons on screen (most of you have at 80) and each of them will get updated on this timer in seconds
	  -- default is 1, it is needed for the rangecheck
	  -- if you dont want it just set the timer to 999 and the cpu usage will be near zero
	  -- if you set the timer to 0 it will update all your 120 buttons on every single frame
	  -- so if you have 120FPS it will call the function 14.400 times a second!
	  -- if the timer is 1 it will call the function 120 times a second (depends on actionbuttons in screen)
	  local update_timer = 1

	  ---------------------------------------
	  -- CONFIG END
	  ---------------------------------------

	  -- DO NOT TOUCH ANYTHING BELOW!

	  ---------------------------------------
	  -- FUNCTIONS
	  ---------------------------------------
	  
	  --initial style func
	  local function rActionButtonStyler_AB_style(self)
	  
		local action = self.action
		local name = self:GetName()
		local bu  = _G[name]
		local ic  = _G[name.."Icon"]
		local co  = _G[name.."Count"]
		local bo  = _G[name.."Border"]
		local ho  = _G[name.."HotKey"]
		local cd  = _G[name.."Cooldown"]
		local na  = _G[name.."Name"]
		local fl  = _G[name.."Flash"]
		local nt  = _G[name.."NormalTexture"]
		
		nt:SetHeight(42)
		nt:SetWidth(42)
		nt:SetPoint("Center", 0, 0)
		bo:Hide()
		
		ho:SetFont(button_font, 18, "OUTLINE")
		co:SetFont(button_font, 18, "OUTLINE")
		na:SetFont(button_font, 12, "OUTLINE")
		if hide_hotkey == true then
		  ho:Hide()
		end
		na:Hide()
	  
		fl:SetTexture(rb2_flash_texture)
		bu:SetHighlightTexture(rb2_hover_texture)
		bu:SetPushedTexture(rb2_pushed_texture)
		bu:SetCheckedTexture(rb2_checked_texture)
		bu:SetNormalTexture(rb2_normal_texture)
	  
		ic:SetTexCoord(0.1,0.9,0.1,0.9)
		ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)

		if ( IsEquippedAction(action) ) then
		  bu:SetNormalTexture(rb2_equipped_texture)
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		else
		  bu:SetNormalTexture(rb2_normal_texture)
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		end  

		--fix totem bars
		if ( self.buttonType == "MULTICASTACTIONBUTTON" ) then
		  nt:SetAlpha(0)
		end
	  
	  end
	  
	  --style pet buttons
	  local function rActionButtonStyler_AB_stylepet()
		
		for i=1, NUM_PET_ACTION_SLOTS do
		  local name = "PetActionButton"..i
		  local bu  = _G[name]
		  local ic  = _G[name.."Icon"]
		  local fl  = _G[name.."Flash"]
		  local nt  = _G[name.."NormalTexture2"]
	  
		  nt:ClearAllPoints()
		  nt:SetPoint("TOPLEFT", bu, "TOPLEFT", -1, 1)
		  nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 1, -1)
		  
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		  
		  fl:SetTexture(rb2_flash_texture)
		  bu:SetHighlightTexture(rb2_hover_texture)
		  bu:SetPushedTexture(rb2_pushed_texture)
		  bu:SetCheckedTexture(rb2_checked_texture)
		  bu:SetNormalTexture(rb2_normal_texture)
		
		  ic:SetTexCoord(0.1,0.9,0.1,0.9)
		  ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		  ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
		  
		end  
	  end
	  
	  --style shapeshift buttons
	  local function rActionButtonStyler_AB_styleshapeshift()    
		for i=1, NUM_SHAPESHIFT_SLOTS do
		  local name = "ShapeshiftButton"..i
		  local bu  = _G[name]
		  local ic  = _G[name.."Icon"]
		  local fl  = _G[name.."Flash"]
		  local nt  = _G[name.."NormalTexture"]
	  
		  nt:ClearAllPoints()
		  nt:SetPoint("TOPLEFT", bu, "TOPLEFT", -1, 1)
		  nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 1, -1)
		  
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		  
		  fl:SetTexture(rb2_flash_texture)
		  bu:SetHighlightTexture(rb2_hover_texture)
		  bu:SetPushedTexture(rb2_pushed_texture)
		  bu:SetCheckedTexture(rb2_checked_texture)
		  bu:SetNormalTexture(rb2_normal_texture)
		
		  ic:SetTexCoord(0.1,0.9,0.1,0.9)
		  ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		  ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)  
		end    
	  end
	  
	  --fix the grid display
	  --the default function has a bug and once you move a button the alpha stays at 0.5, this gets fixed here
	  local function rActionButtonStyler_AB_fixgrid(button)
		local name = button:GetName()
		local action = button.action
		local nt  = _G[name.."NormalTexture"]
		if ( IsEquippedAction(action) ) then
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		else
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		end  
		--fix totem bars
		if ( button.buttonType == "MULTICASTACTIONBUTTON" ) then
		  nt:SetAlpha(0)
		end
	  end
	  
	  --update the button colors onUpdateUsable
	  local function rActionButtonStyler_AB_usable(self)
		local name = self:GetName()
		local action = self.action
		local nt  = _G[name.."NormalTexture"]
		local icon = _G[name.."Icon"]
		if ( IsEquippedAction(action) ) then
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		else
		  nt:SetVertexColor(unpack(TUKUI_BORDER_COLOR))
		end  
		--fix totem bars
		if ( self.buttonType == "MULTICASTACTIONBUTTON" ) then
		  nt:SetAlpha(0)
		end
		local isUsable, notEnoughMana = IsUsableAction(action)
		if (ActionHasRange(action) and IsActionInRange(action) == 0) then
		  icon:SetVertexColor(range_color.r,range_color.g,range_color.b,1)
		  return
		elseif (notEnoughMana) then
		  icon:SetVertexColor(mana_color.r,mana_color.g,mana_color.b,1)
		  return
		elseif (isUsable) then
		  icon:SetVertexColor(usable_color.r,usable_color.g,usable_color.b,1)
		  return
		else
		  icon:SetVertexColor(unusable_color.r,unusable_color.g,unusable_color.b,1);
		  return
		end
	  end
	  
	  --rewrite of the onupdate func
	  --much less cpu usage needed
	  local function rActionButtonStyler_AB_onupdate(self,elapsed)
		local t = self.rABS_range
		if (not t) then
		  self.rABS_range = 0
		  return
		end
		t = t + elapsed
		if (t<update_timer) then
		  self.rABS_range = t
		  return
		else
		  self.rABS_range = 0
		  if(not ActionHasRange(self.action)) then
			return
		  end
		  rActionButtonStyler_AB_usable(self)
		end
	  end
	  
	  --hotkey func
	  --is only needed when you want to hide the hotkeys and use the default barmod (Dominos does not need this)
	  local function rActionButtonStyler_AB_hotkey(self, actionButtonType)
		if (not actionButtonType) then
		  actionButtonType = "ACTIONBUTTON";
		end
		local hotkey = _G[self:GetName().."HotKey"]
		local key = GetBindingKey(actionButtonType..self:GetID()) or GetBindingKey("CLICK "..self:GetName()..":LeftButton");
		local text = GetBindingText(key, "KEY_", 1);
		hotkey:SetText(text);
		hotkey:Hide()
	  end 
	  

	  ---------------------------------------
	  -- CALLS // HOOKS
	  ---------------------------------------
	  
	  hooksecurefunc("ActionButton_Update",   rActionButtonStyler_AB_style)
	  hooksecurefunc("ActionButton_UpdateUsable",   rActionButtonStyler_AB_usable)
	  
	  --rewrite default onUpdateFunc, the new one uses much less CPU power
	  ActionButton_OnUpdate = rActionButtonStyler_AB_onupdate
	  
	  --fix grid
	  hooksecurefunc("ActionButton_ShowGrid", rActionButtonStyler_AB_fixgrid)
	  
	  --call the special func to hide hotkeys after entering combat with the default actionbar
	  if hide_hotkey == true then
		hooksecurefunc("ActionButton_UpdateHotkeys", rActionButtonStyler_AB_hotkey)
	  end
	  
	  hooksecurefunc("ShapeshiftBar_OnLoad",   rActionButtonStyler_AB_styleshapeshift)
	  hooksecurefunc("ShapeshiftBar_Update",   rActionButtonStyler_AB_styleshapeshift)
	  hooksecurefunc("ShapeshiftBar_UpdateState",   rActionButtonStyler_AB_styleshapeshift)
	  hooksecurefunc("PetActionBar_Update",   rActionButtonStyler_AB_stylepet)

end	  
