local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

E.Media = {
	Fonts = {},
	Sounds = {},
	ChatEmojis = {},
	ChatLogos = {},
	Textures = {}
}

local format = format
local westAndRU = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western

function E:TextureString(texture, data)
	return format('|T%s%s|t', texture, data or '')
end

local MediaKey = {
	font	= 'Fonts',
	sound	= 'Sounds',
	emoji	= 'ChatEmojis',
	logo	= 'ChatLogos',
	texture	= 'Textures'
}

local MediaPath = {
	font	= [[Interface\AddOns\ElvUI\Media\Fonts\]],
	sound	= [[Interface\AddOns\ElvUI\Media\Sounds\]],
	emoji	= [[Interface\AddOns\ElvUI\Media\ChatEmojis\]],
	logo	= [[Interface\AddOns\ElvUI\Media\ChatLogos\]],
	texture	= [[Interface\AddOns\ElvUI\Media\Textures\]]
}

local function AddMedia(Type, File, Name, CustomType, Mask)
	local path = MediaPath[Type]
	if path then
		local key = File:gsub('%.%w-$','')
		local file = path .. File

		local pathKey = MediaKey[Type]
		if pathKey then E.Media[pathKey][key] = file end

		if Name then -- Register to LSM
			local nameKey = (Name == true and key) or Name
			if type(CustomType) == 'table' then
				for _, name in ipairs(CustomType) do
					LSM:Register(name, nameKey, file, Mask)
				end
			else
				LSM:Register(CustomType or Type, nameKey, file, Mask)
			end
		end
	end
end

-- Name as true will add the Key as it's name
AddMedia('font','ActionMan.ttf',			'Action Man')
AddMedia('font','ContinuumMedium.ttf',		'Continuum Medium')
AddMedia('font','DieDieDie.ttf',			'Die Die Die!')
AddMedia('font','PTSansNarrow.ttf',			'PT Sans Narrow', nil, westAndRU)
AddMedia('font','IIBMPlexMonoRegular.ttf',	'IBM Plex Mono', nil, westAndRU)
AddMedia('font','Expressway.ttf',			true, nil, westAndRU)
AddMedia('font','Homespun.ttf',				true, nil, westAndRU)
AddMedia('font','Invisible.ttf')

AddMedia('sound','AwwCrap.ogg',					'Awww Crap')
AddMedia('sound','BbqAss.ogg',					'BBQ Ass')
AddMedia('sound','DumbShit.ogg',				'Dumb Shit')
AddMedia('sound','MamaWeekends.ogg',			'Mama Weekends')
AddMedia('sound','RunFast.ogg',					'Runaway Fast')
AddMedia('sound','StopRunningSlimeBall.ogg',	'Stop Running')
AddMedia('sound','Whisper.ogg',					'Whisper Alert')
AddMedia('sound','YankieBangBang.ogg',			'Big Yankie Devil')
AddMedia('sound','HelloKitty.ogg')
AddMedia('sound','HarlemShake.ogg')

AddMedia('texture','GlowTex.tga',		'ElvUI GlowBorder', 'border')
AddMedia('texture','NormTex.tga',		'ElvUI Gloss',	'statusbar')
AddMedia('texture','NormTex2.tga',		'ElvUI Norm',	'statusbar')
AddMedia('texture','White8x8.tga',		'ElvUI Blank', {'statusbar','background'})
AddMedia('texture','Minimalist.tga',	true, 'statusbar')
AddMedia('texture','Melli.tga',			true, 'statusbar')

AddMedia('texture','Arrow.tga')
AddMedia('texture','ArrowRight.tga')
AddMedia('texture','ArrowUp.tga')
AddMedia('texture','BagNewItemGlow.tga')
AddMedia('texture','BagQuestIcon.tga')
AddMedia('texture','BagUpgradeIcon.tga')
AddMedia('texture','Black8x8.tga')
AddMedia('texture','BubbleTex.tga')
AddMedia('texture','ChatEmojis')
AddMedia('texture','ChatLogos')
AddMedia('texture','Close.tga')
AddMedia('texture','Combat.tga')
AddMedia('texture','Copy.tga')
AddMedia('texture','Cross.tga')
AddMedia('texture','DPS.tga')
AddMedia('texture','ExitVehicle.tga')
AddMedia('texture','Healer.tga')
AddMedia('texture','HelloKitty.tga')
AddMedia('texture','HelloKittyChat.tga')
AddMedia('texture','Highlight.tga')
AddMedia('texture','Leader.tga')
AddMedia('texture','Logo.tga')
AddMedia('texture','LogoSmall.tga')
AddMedia('texture','Mail.tga')
AddMedia('texture','Minus.tga')
AddMedia('texture','MinusButton.tga')
AddMedia('texture','Pause.tga')
AddMedia('texture','PhaseIcons.tga')
AddMedia('texture','Play.tga')
AddMedia('texture','Plus.tga')
AddMedia('texture','PlusButton.tga')
AddMedia('texture','Reset.tga')
AddMedia('texture','Resting.tga')
AddMedia('texture','Resting1.tga')
AddMedia('texture','RoleIcons.tga')
AddMedia('texture','SkullIcon.tga')
AddMedia('texture','Smooth.tga')
AddMedia('texture','Spark.tga')
AddMedia('texture','Tank.tga')
AddMedia('texture','TukuiLogo.tga')

AddMedia('emoji','Angry.tga')
AddMedia('emoji','Blush.tga')
AddMedia('emoji','BrokenHeart.tga')
AddMedia('emoji','CallMe.tga')
AddMedia('emoji','Cry.tga')
AddMedia('emoji','Facepalm.tga')
AddMedia('emoji','Grin.tga')
AddMedia('emoji','Heart.tga')
AddMedia('emoji','HeartEyes.tga')
AddMedia('emoji','Joy.tga')
AddMedia('emoji','Kappa.tga')
AddMedia('emoji','Meaw.tga')
AddMedia('emoji','MiddleFinger.tga')
AddMedia('emoji','Murloc.tga')
AddMedia('emoji','OkHand.tga')
AddMedia('emoji','OpenMouth.tga')
AddMedia('emoji','Poop.tga')
AddMedia('emoji','Rage.tga')
AddMedia('emoji','SadKitty.tga')
AddMedia('emoji','Scream.tga')
AddMedia('emoji','ScreamCat.tga')
AddMedia('emoji','SemiColon.tga')
AddMedia('emoji','SlightFrown.tga')
AddMedia('emoji','Smile.tga')
AddMedia('emoji','Smirk.tga')
AddMedia('emoji','Sob.tga')
AddMedia('emoji','StuckOutTongue.tga')
AddMedia('emoji','StuckOutTongueClosedEyes.tga')
AddMedia('emoji','Sunglasses.tga')
AddMedia('emoji','Thinking.tga')
AddMedia('emoji','ThumbsUp.tga')
AddMedia('emoji','Wink.tga')
AddMedia('emoji','ZZZ.tga')

AddMedia('logo','ElvRainbow.tga')
AddMedia('logo','ElvMelon.tga')
AddMedia('logo','ElvBlue.tga')
AddMedia('logo','ElvGreen.tga')
AddMedia('logo','ElvOrange.tga')
AddMedia('logo','ElvPink.tga')
AddMedia('logo','ElvPurple.tga')
AddMedia('logo','ElvYellow.tga')
AddMedia('logo','ElvRed.tga')
AddMedia('logo','Bathrobe.tga')
AddMedia('logo','HelloKitty.tga')
AddMedia('logo','Illuminati.tga')
AddMedia('logo','MrHankey.tga')
AddMedia('logo','Rainbow.tga')
AddMedia('logo','TyroneBiggums.tga')
AddMedia('logo','Burger.tga')
AddMedia('logo','Clover.tga')
AddMedia('logo','Cupcake.tga')
AddMedia('logo','Hibiscus.tga')
AddMedia('logo','Lion.tga')
AddMedia('logo','Skull.tga')
AddMedia('logo','Unicorn.tga')
AddMedia('logo','FoxDeathKnight.tga')
AddMedia('logo','FoxDemonHunter.tga')
AddMedia('logo','FoxDruid.tga')
AddMedia('logo','FoxHunter.tga')
AddMedia('logo','FoxMage.tga')
AddMedia('logo','FoxMonk.tga')
AddMedia('logo','FoxPaladin.tga')
AddMedia('logo','FoxPriest.tga')
AddMedia('logo','FoxRogue.tga')
AddMedia('logo','FoxShaman.tga')
AddMedia('logo','FoxWarlock.tga')
AddMedia('logo','FoxWarrior.tga')
AddMedia('logo','DeathlyHallows.tga')
AddMedia('logo','GoldShield.tga')
