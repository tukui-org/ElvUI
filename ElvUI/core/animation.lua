------------------------------------------------------------------------
-- Animation Functions (Credit AlleyCat, Hydra)
------------------------------------------------------------------------
local ElvDB = ElvDB

ElvDB.SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(1)
end

ElvDB.Flash = function(self, duration)
	if not self.anim then
		ElvDB.SetUpAnimGroup(self)
	end

	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:Play()
end

ElvDB.StopFlash = function(self)
	if self.anim then
		self.anim:Finish()
	end
end

ElvDB.AnimGroup = function (self,x,y,duration)
	self.anim = self:CreateAnimationGroup("Move_In")
	self.anim.in1 = self.anim:CreateAnimation("Translation")
	self.anim.in1:SetDuration(0)
	self.anim.in1:SetOrder(1)
	self.anim.in2 = self.anim:CreateAnimation("Translation")
	self.anim.in2:SetDuration(duration)
	self.anim.in2:SetOrder(2)
	self.anim.in2:SetSmoothing("OUT")
	self.anim_o = self:CreateAnimationGroup("Move_Out")
	self.anim_out2 = self.anim_o:CreateAnimation("Translation")
	self.anim_out2:SetDuration(duration)
	self.anim_out2:SetOrder(1)
	self.anim_out2:SetSmoothing("IN")
	self.anim.in1:SetOffset(x,y)
	self.anim.in2:SetOffset(-x,-y)
	self.anim_out2:SetOffset(x,y)
	self.anim_o:SetScript("OnFinished",function() self:Hide() end)
end

ElvDB.SlideIn = function(self)
	if not self.anim then
		ElvDB.AnimGroup(self)
	end

	self.anim_o:Stop()
	self:Show()
	self.anim:Play()
end

ElvDB.SlideOut = function(self)
	if self.anim then
		self.anim:Finish()
	end

	self.anim:Stop()
	self.anim_o:Play()
end