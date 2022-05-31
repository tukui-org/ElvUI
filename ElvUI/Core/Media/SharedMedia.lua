local E, L, V, P, G = unpack(ElvUI)
local LSM = E.Libs.LSM

local format, ipairs, type, pcall = format, ipairs, type, pcall
local westAndRU = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western

E.Media = {
	Fonts = {},
	Sounds = {},
	Arrows = {},
	MailIcons = {},
	RestIcons = {},
	ChatEmojis = {},
	ChatLogos = {},
	Textures = {},
	CombatIcons = {
		DEFAULT = [[Interface\CharacterFrame\UI-StateIcon]],
		PLATINUM = [[Interface\Challenges\ChallengeMode_Medal_Platinum]],
		ATTACK = [[Interface\CURSOR\Attack]],
		ALERT = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]],
		ALERT2 = [[Interface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon]],
		ARTHAS = [[Interface\LFGFRAME\UI-LFR-PORTRAIT]],
		SKULL = [[Interface\LootFrame\LootPanel-Icon]]
	}
}

local MediaKey = {
	font	= 'Fonts',
	sound	= 'Sounds',
	arrow	= 'Arrows',
	mail	= 'MailIcons',
	resting = 'RestIcons',
	emoji	= 'ChatEmojis',
	logo	= 'ChatLogos',
	texture	= 'Textures'
}

local MediaPath = {
	font	= [[Interface\AddOns\ElvUI\Core\Media\Fonts\]],
	sound	= [[Interface\AddOns\ElvUI\Core\Media\Sounds\]],
	arrow	= [[Interface\AddOns\ElvUI\Core\Media\Arrows\]],
	mail	= [[Interface\AddOns\ElvUI\Core\Media\MailIcons\]],
	resting = [[Interface\AddOns\ElvUI\Core\Media\RestIcons\]],
	emoji	= [[Interface\AddOns\ElvUI\Core\Media\ChatEmojis\]],
	logo	= [[Interface\AddOns\ElvUI\Core\Media\ChatLogos\]],
	texture	= [[Interface\AddOns\ElvUI\Core\Media\Textures\]]
}

do
	local t, d = '|T%s%s|t', ''
	function E:TextureString(texture, data)
		return format(t, texture, data or d)
	end
end

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

AddMedia('texture','GlowTex',		'ElvUI GlowBorder', 'border')
AddMedia('texture','NormTex',		'ElvUI Gloss',	'statusbar')
AddMedia('texture','NormTex2',		'ElvUI Norm',	'statusbar')
AddMedia('texture','NormTex3',		'ElvUI Norm1',	'statusbar')
AddMedia('texture','White8x8',		'ElvUI Blank', {'statusbar','background'})
AddMedia('texture','Minimalist',	true, 'statusbar')
AddMedia('texture','Melli',			true, 'statusbar')

for i = 0, 7 do -- mail icons
	AddMedia('mail','Mail'..i)
end

for i = 0, 2 do -- resting icons
	AddMedia('resting','Resting'..i)
end

-- nameplate target arrows
AddMedia('arrow', 'ArrowRed')
for i = 0, 72 do
	AddMedia('arrow', 'Arrow'..i)
end

AddMedia('texture','Arrow')
AddMedia('texture','ArrowRight')
AddMedia('texture','ArrowUp')
AddMedia('texture','ArrowUpGlow')
AddMedia('texture','Backpack')
AddMedia('texture','BagNewItemGlow')
AddMedia('texture','BagQuestIcon')
AddMedia('texture','BagUpgradeIcon')
AddMedia('texture','Black8x8')
AddMedia('texture','BubbleTex')
AddMedia('texture','ChatEmojis')
AddMedia('texture','ChatLogos')
AddMedia('texture','Close')
AddMedia('texture','Coins')
AddMedia('texture','Combat')
AddMedia('texture','Copy')
AddMedia('texture','Cross')
AddMedia('texture','DPS')
AddMedia('texture','ExitVehicle')
AddMedia('texture','Healer')
AddMedia('texture','Help')
AddMedia('texture','Highlight')
AddMedia('texture','Invisible')
AddMedia('texture','LeaderHQ')
AddMedia('texture','LogoBottom')
AddMedia('texture','LogoBottomSmall')
AddMedia('texture','LogoTop')
AddMedia('texture','LogoTopSmall')
AddMedia('texture','Minus')
AddMedia('texture','MinusButton')
AddMedia('texture','Pause')
AddMedia('texture','PetBroom')
AddMedia('texture','PhaseBorder')
AddMedia('texture','PhaseCenter')
AddMedia('texture','Planks')
AddMedia('texture','Play')
AddMedia('texture','Plus')
AddMedia('texture','PlusButton')
AddMedia('texture','Reset')
AddMedia('texture','RoleIcons')
AddMedia('texture','RolesHQ')
AddMedia('texture','SkullIcon')
AddMedia('texture','Smooth')
AddMedia('texture','Spark')
AddMedia('texture','Tank')
AddMedia('texture','TukuiLogo')

AddMedia('emoji','Angry')
AddMedia('emoji','Blush')
AddMedia('emoji','BrokenHeart')
AddMedia('emoji','CallMe')
AddMedia('emoji','Cry')
AddMedia('emoji','Facepalm')
AddMedia('emoji','Grin')
AddMedia('emoji','Heart')
AddMedia('emoji','HeartEyes')
AddMedia('emoji','Joy')
AddMedia('emoji','Kappa')
AddMedia('emoji','Meaw')
AddMedia('emoji','MiddleFinger')
AddMedia('emoji','Murloc')
AddMedia('emoji','OkHand')
AddMedia('emoji','OpenMouth')
AddMedia('emoji','Poop')
AddMedia('emoji','Rage')
AddMedia('emoji','SadKitty')
AddMedia('emoji','Scream')
AddMedia('emoji','ScreamCat')
AddMedia('emoji','SemiColon')
AddMedia('emoji','SlightFrown')
AddMedia('emoji','Smile')
AddMedia('emoji','Smirk')
AddMedia('emoji','Sob')
AddMedia('emoji','StuckOutTongue')
AddMedia('emoji','StuckOutTongueClosedEyes')
AddMedia('emoji','Sunglasses')
AddMedia('emoji','Thinking')
AddMedia('emoji','ThumbsUp')
AddMedia('emoji','Wink')
AddMedia('emoji','ZZZ')

AddMedia('logo','ElvBlue')
AddMedia('logo','ElvGreen')
AddMedia('logo','ElvOrange')
AddMedia('logo','ElvPink')
AddMedia('logo','ElvPurple')
AddMedia('logo','ElvYellow')
AddMedia('logo','ElvRed')
AddMedia('logo','ElvSimpy')

AddMedia('logo','Bathrobe')
AddMedia('logo','Rainbow')
AddMedia('logo','Hibiscus')
AddMedia('logo','Gem')
AddMedia('logo','Beer')
AddMedia('logo','PalmTree')
AddMedia('logo','TyroneBiggums')
AddMedia('logo','SuperBear')

E.Media.CombatIcons.COMBAT = E.Media.Textures.Combat

do -- LSM Font Preloader ~Simpy
	local preloader = CreateFrame('Frame')
	preloader:SetPoint('TOP', UIParent, 'BOTTOM', 0, -500)
	preloader:SetSize(100, 100)

	local cacheFont = function(key, data)
		local loadFont = preloader:CreateFontString()
		loadFont:SetAllPoints()

		if pcall(loadFont.SetFont, loadFont, data, 14) then
			pcall(loadFont.SetText, loadFont, 'cache')
		end
	end

	-- Preload ElvUI Invisible
	cacheFont('Invisible', E.Media.Fonts.Invisible)

	-- Lets load all the fonts in LSM to prevent fonts not being ready
	local sharedFonts = LSM:HashTable('font')
	for key, data in next, sharedFonts do
		cacheFont(key, data)
	end

	-- Now lets hook it so we can preload any other AddOns add to LSM
	hooksecurefunc(LSM, 'Register', function(_, mediatype, key, data)
		if not mediatype or type(mediatype) ~= 'string' then return end

		if mediatype:lower() == 'font' then
			cacheFont(key, data)
		end
	end)
end
