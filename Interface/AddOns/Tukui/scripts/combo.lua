-- a lightweight mod based on BRH

BRH_ComboSkill = 40;

BRH_FinishSkill = 35;

tCombo_FontSizePixel=40;


function tComboFrame_OnLoad()
	if TukuiDB["combo"].enable == true then
		this:RegisterEvent("UNIT_COMBO_POINTS");
		this:RegisterEvent("UNIT_ENERGY");
	end

	this.fadeInTime = 0.2;		-- fade in time(sec)
	this.holdTime = 1.0;		-- hold time(sec)
	this.fadeOutTime = 0.8;		-- fade out time(sec)
	this.flowTime = this.fadeInTime + this.holdTime + this.fadeOutTime;
	this.PI = 3.141592;

	this:Hide();

	--tCombo_Register();
	BubbleTextString:SetTextHeight(tCombo_FontSizePixel);
	BubbleTextString:SetFont(TukuiDB["media"].dmgfont, tCombo_FontSizePixel, "OUTLINE");
end

function tComboFrame_OnEvent(event)
	if ( event == "UNIT_ENERGY" ) then
		if ( arg1 == "player" ) then
			SetBubbleTextColor();
		end
	end
	if ( event == "UNIT_COMBO_POINTS" ) then
		if( GetComboPoints(PlayerFrame.unit, "target")>0 )then
			SetBubbleText();
			tCombo_Show();
		else
			this:Hide();
		end
	end
end

function tCombo_OnUpdate()
	local elapsed = GetTime() - this.startTime;

	local fadeInTime = this.fadeInTime;
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime);
		this:SetAlpha(alpha);
		BubbleTextString:SetTextHeight(tCombo_FontSizePixel * alpha + 1);
		this:SetPoint("CENTER", "UIParent", "CENTER", 0,100, tCombo_FontSizePixel*alpha );
		return;
	end
	local holdTime = this.holdTime;
	if ( elapsed < (fadeInTime + holdTime) ) then
		this:SetAlpha(1.0);
		BubbleTextString:SetTextHeight(tCombo_FontSizePixel + 1);
		this:SetPoint("CENTER", "UIParent", "CENTER", 0, 100, tCombo_FontSizePixel );
		return;
	end
	local fadeOutTime = this.fadeOutTime;
	if ( elapsed < (fadeInTime + holdTime + fadeOutTime) ) then
		local alpha = 1.0 - ((elapsed - holdTime - fadeInTime) / fadeOutTime);
		this:SetAlpha(alpha);
		BubbleTextString:SetTextHeight(tCombo_FontSizePixel * alpha + 1);
		this:SetPoint("CENTER", "UIParent", "CENTER", 0,100, tCombo_FontSizePixel*alpha );
		return;
	end
	this:Hide();
end

function SetBubbleTextColor()
	local mana = UnitMana("player");
	local r,g,b;

	if( mana >= BRH_ComboSkill )then
		r = 0.1;
		g = 1.0;
		b = 0.1; -- green
	elseif( mana >= BRH_FinishSkill )then
		r = 0.0;
		g = 0.39;
		b = 0.88; -- blue
	else
		r = 1.0;
		g = 0.1;
		b = 0.1; -- red
	end

	BubbleTextString:SetTextColor(r, g, b);
end

function SetBubbleText()
	local combo = GetComboPoints(PlayerFrame.unit, "target");
	BubbleTextString:SetText(combo);
	SetBubbleTextColor();
end

function tCombo_Show()
	this.startTime = GetTime();
	this:Show();
end





