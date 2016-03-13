------------------------------------------------------------------------
-- Animation Functions
------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
--Lua functions
local tremove = tremove
local random = math.random

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
	elseif type == 'FlashLoop' then
		object.anim = object:CreateAnimationGroup("Flash")
		object.anim.fadein = object.anim:CreateAnimation("ALPHA", "FadeIn")
		object.anim.fadein:SetChange(1)
		object.anim.fadein:SetOrder(2)

		object.anim.fadeout = object.anim:CreateAnimation("ALPHA", "FadeOut")
		object.anim.fadeout:SetChange(-1)
		object.anim.fadeout:SetOrder(1)

		object.anim:SetScript("OnFinished", function(self, requested)
			if(not requested) then
				object.anim:Play()
			end
		end)
	elseif type == 'Shake' then
		object.shake = object:CreateAnimationGroup("Shake")
		object.shake:SetLooping("REPEAT")
		object.shake.path = object.shake:CreateAnimation("Path")
		object.shake.path[1] = object.shake.path:CreateControlPoint()
		object.shake.path[2] = object.shake.path:CreateControlPoint()
		object.shake.path[3] = object.shake.path:CreateControlPoint()
		object.shake.path[4] = object.shake.path:CreateControlPoint()
		object.shake.path[5] = object.shake.path:CreateControlPoint()
		object.shake.path[6] = object.shake.path:CreateControlPoint()

		object.shake.path:SetDuration(0.7)
		object.shake.path[1]:SetOffset(random(-9, 7), random(-7, 12))
		object.shake.path[1]:SetOrder(1)
		object.shake.path[2]:SetOffset(random(-5, 9), random(-9, 5))
		object.shake.path[2]:SetOrder(2)
		object.shake.path[3]:SetOffset(random(-5, 7), random(-7, 5))
		object.shake.path[3]:SetOrder(3)
		object.shake.path[4]:SetOffset(random(-9, 9), random(-9, 9))
		object.shake.path[4]:SetOrder(4)
		object.shake.path[5]:SetOffset(random(-5, 7), random(-7, 5))
		object.shake.path[5]:SetOrder(5)
		object.shake.path[6]:SetOffset(random(-9, 7), random(-9, 5))
		object.shake.path[6]:SetOrder(6)
	elseif type == 'Shake_Horizontal' then
		object.shakeh = object:CreateAnimationGroup("ShakeH")
		object.shakeh:SetLooping("REPEAT")
		object.shakeh.path = object.shakeh:CreateAnimation("Path")
		object.shakeh.path[1] = object.shakeh.path:CreateControlPoint()
		object.shakeh.path[2] = object.shakeh.path:CreateControlPoint()
		object.shakeh.path[3] = object.shakeh.path:CreateControlPoint()
		object.shakeh.path[4] = object.shakeh.path:CreateControlPoint()
		object.shakeh.path[5] = object.shakeh.path:CreateControlPoint()
		object.shakeh.path[6] = object.shakeh.path:CreateControlPoint()

		object.shakeh.path:SetDuration(2)
		object.shakeh.path[1]:SetOffset(-5, 0)
		object.shakeh.path[1]:SetOrder(1)
		object.shakeh.path[2]:SetOffset(5, 0)
		object.shakeh.path[2]:SetOrder(2)
		object.shakeh.path[3]:SetOffset(-2, 0)
		object.shakeh.path[3]:SetOrder(3)
		object.shakeh.path[4]:SetOffset(5, 0)
		object.shakeh.path[4]:SetOrder(4)
		object.shakeh.path[5]:SetOffset(-2, 0)
		object.shakeh.path[5]:SetOrder(5)
		object.shakeh.path[6]:SetOffset(5, 0)
		object.shakeh.path[6]:SetOrder(6)
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

function E:Shake(object)
	if not object.shake then
		E:SetUpAnimGroup(object, 'Shake')
	end

	object.shake:Play()
end

function E:StopShake(object)
	if object.shake then
		object.shake:Finish()
	end
end

function E:ShakeHorizontal(object)
	if not object.shakeh then
		E:SetUpAnimGroup(object, 'Shake_Horizontal')
	end

	object.shakeh:Play()
end

function E:StopShakeHorizontal(object)
	if object.shakeh then
		object.shakeh:Finish()
	end
end

function E:Flash(object, duration, loop)
	if not object.anim then
		E:SetUpAnimGroup(object, loop and "FlashLoop" or 'Flash')
	end

	if not object.anim.playing then
		object.anim.fadein:SetDuration(duration)
		object.anim.fadeout:SetDuration(duration)
		object.anim:Play()
		object.anim.playing = true
	end
end

function E:StopFlash(object)
	if object.anim and object.anim.playing then
		object.anim:Stop()
		object.anim.playing = nil;
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

local frameFadeManager = CreateFrame("FRAME");
local FADEFRAMES = {};

function E:UIFrameFade_OnUpdate(elapsed)
	local index = 1;
	local frame, fadeInfo;
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index];
		fadeInfo = FADEFRAMES[index].fadeInfo;
		-- Reset the timer if there isn't one, this is just an internal counter
		fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + elapsed;
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed;

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
		if ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
			if ( fadeInfo.mode == "IN" ) then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
			elseif ( fadeInfo.mode == "OUT" ) then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha);
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha);
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if ( fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  ) then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed;
			else
				-- Complete the fade and call the finished function if there is one
				E:UIFrameFadeRemoveFrame(frame);
				if ( fadeInfo.finishedFunc ) then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
					fadeInfo.finishedFunc = nil;
				end
			end
		end

		index = index + 1;
	end

	if ( #FADEFRAMES == 0 ) then
		frameFadeManager:SetScript("OnUpdate", nil);
	end
end

-- Generic fade function
function E:UIFrameFade(frame, fadeInfo)
	if (not frame) then
		return;
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = "IN";
	end
	local alpha;
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
		alpha = 0;
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
		alpha = 1.0;
	end
	frame:SetAlpha(fadeInfo.startAlpha);

	frame.fadeInfo = fadeInfo;
	if not frame:IsProtected() then
		frame:Show();
	end

	local index = 1;
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if ( FADEFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end
	FADEFRAMES[#FADEFRAMES + 1] = frame
	frameFadeManager:SetScript("OnUpdate", E.UIFrameFade_OnUpdate);
end

-- Convenience function to do a simple fade in
function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	E:UIFrameFade(frame, fadeInfo);
end

-- Convenience function to do a simple fade out
function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "OUT";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	E:UIFrameFade(frame, fadeInfo);
end

function E:tDeleteItem(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			tremove(table, index);
			break
		else
			index = index + 1;
		end
	end
end

function E:UIFrameFadeRemoveFrame(frame)
	E:tDeleteItem(FADEFRAMES, frame);
end