------------------------------------------------------------------------
-- Animation Functions
------------------------------------------------------------------------
local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local random = random
local tremove = tremove
--WoW API / Variables

function E:SetUpAnimGroup(object, type, ...)
	if not type then type = 'Flash' end

	if type:sub(1, 5) == 'Flash' then
		object.anim = object:CreateAnimationGroup("Flash")
		object.anim.fadein = object.anim:CreateAnimation("ALPHA", "FadeIn")
		object.anim.fadein:SetFromAlpha(0)
		object.anim.fadein:SetToAlpha(1)
		object.anim.fadein:SetOrder(2)

		object.anim.fadeout = object.anim:CreateAnimation("ALPHA", "FadeOut")
		object.anim.fadeout:SetFromAlpha(1)
		object.anim.fadeout:SetToAlpha(0)
		object.anim.fadeout:SetOrder(1)
		if type == 'FlashLoop' then
			object.anim:SetScript("OnFinished", function(_, requested)
				if(not requested) then
					object.anim:Play()
				end
			end)
		end
	elseif type:sub(1, 5) == 'Shake' then
		local shake = object:CreateAnimationGroup(type)
		shake:SetLooping("REPEAT")
		shake.path = object.shake:CreateAnimation("Path")
		local offsets
		if type == 'Shake' then
			shake.path:SetDuration(0.7)
			offsets = {
				{random(-9, 7), random(-7, 12)},
				{random(-5, 9), random(-9, 5)},
				{random(-5, 7), random(-7, 5)},
				{random(-9, 9), random(-9, 9)},
				{random(-5, 7), random(-7, 5)},
				{random(-9, 7), random(-9, 5)},
			}
		elseif type == 'ShakeH' then
			shake.path:SetDuration(2)
			offsets = {-5, 5, -2, 5, -2, 5}
		end

		for i = 1, 6 do
			shake.path[i] = shake.path:CreateControlPoint()
			shake.path[i]:SetOffset(offsets[i], 0)
			shake.path[i]:SetOrder(i)
		end

		object[type:lower()] = shake
	else
		local x, y, duration, customName = ...
		if not customName then
			customName = 'anim'
		end
		object[customName] = object:CreateAnimationGroup("Move_In")

		object[customName].in1 = object[customName]:CreateAnimation("Translation")
		object[customName].in1:SetDuration(0)
		object[customName].in1:SetOrder(1)
		object[customName].in1:SetOffset(E:Scale(x), E:Scale(y))

		object[customName].in2 = object[customName]:CreateAnimation("Translation")
		object[customName].in2:SetDuration(duration)
		object[customName].in2:SetOrder(2)
		object[customName].in2:SetSmoothing("OUT")
		object[customName].in2:SetOffset(E:Scale(-x), E:Scale(-y))

		object[customName].out1 = object:CreateAnimationGroup("Move_Out")
		object[customName].out1:SetScript("OnFinished", function() object:Hide() end)

		object[customName].out2 = object[customName].out1:CreateAnimation("Translation")
		object[customName].out2:SetDuration(duration)
		object[customName].out2:SetOrder(1)
		object[customName].out2:SetSmoothing("IN")
		object[customName].out2:SetOffset(E:Scale(x), E:Scale(y))
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
		E:SetUpAnimGroup(object, 'ShakeH')
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
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
	end
	frame:SetAlpha(fadeInfo.startAlpha);

	frame.fadeInfo = fadeInfo;
	if not frame:IsProtected() then
		frame:Show();
	end

	for index = 1, #FADEFRAMES do
		-- If frame is already set to fade then return
		if ( FADEFRAMES[index] == frame ) then
			return;
		end
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

function E:UIFrameFadeRemoveFrame(frame)
	for index = 1, #FADEFRAMES do
		if ( frame == FADEFRAMES[index] ) then
			tremove(FADEFRAMES, index);
			break
		end
	end
end
