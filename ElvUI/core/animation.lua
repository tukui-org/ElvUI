------------------------------------------------------------------------
-- Animation Functions
------------------------------------------------------------------------
local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB

function E:SetUpAnimGroup(object, type, ...)
	if not type then type = 'Flash' end
	
	if type == 'Flash' then
		object.anim = object:CreateAnimationGroup("Flash")
		object.anim.fadein = object.anim:CreateAnimation("ALPHA", "FadeIn")
		object.anim.fadein:SetChange(1)
		object.anim.fadein:SetOrder(2)

		object.anim.fadeout = object.anim:CreateAnimation("ALPHA", "FadeOut")
		object.anim.fadeout:SetChange(-1)
		object.anim.fadeout:SetOrder(1)
	else
		local x, y, duration, customName = ...
		if not customName then
			customName = 'anim'
		end
		object[customName] = object:CreateAnimationGroup("Move_In")
		object[customName].in1 = object[customName]:CreateAnimation("Translation")
		object[customName].in1:SetDuration(0)
		object[customName].in1:SetOrder(1)
		object[customName].in2 = object[customName]:CreateAnimation("Translation")
		object[customName].in2:SetDuration(duration)
		object[customName].in2:SetOrder(2)
		object[customName].in2:SetSmoothing("OUT")
		object[customName].out1 = object:CreateAnimationGroup("Move_Out")
		object[customName].out2 = object[customName].out1:CreateAnimation("Translation")
		object[customName].out2:SetDuration(duration)
		object[customName].out2:SetOrder(1)
		object[customName].out2:SetSmoothing("IN")
		object[customName].in1:SetOffset(E:Scale(x), E:Scale(y))
		object[customName].in2:SetOffset(E:Scale(-x), E:Scale(-y))
		object[customName].out2:SetOffset(E:Scale(x), E:Scale(y))
		object[customName].out1:SetScript("OnFinished", function() object:Hide() end)	
	end
end

function E:Flash(object, duration)
	if not object.anim then
		E:SetUpAnimGroup(object, 'Flash')
	end

	object.anim.fadein:SetDuration(duration)
	object.anim.fadeout:SetDuration(duration)
	object.anim:Play()
end

function E:StopFlash(object)
	if object.anim then
		object.anim:Finish()
	end
end

function E:SlideIn(object, customName)
	if not customName then
		customName = 'anim'
	end
	if not object[customName] then return end
	
	object[customName].out1:Stop()
	object:Show()
	object[customName]:Play()
end

function E:SlideOut(object, customName)
	if not customName then
		customName = 'anim'
	end
	if not object[customName] then return end
	
	object[customName]:Finish() 
	object[customName]:Stop()
	object[customName].out1:Play()
end