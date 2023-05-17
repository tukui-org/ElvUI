local MAJOR, MINOR = "LibDispel-1.0", 1
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local next = next
local GetCVar, SetCVar = GetCVar, SetCVar
local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
local IsPlayerSpell = IsPlayerSpell

local DebuffColors = CopyTable(DebuffTypeColor)
lib.DebuffTypeColor = DebuffColors

-- These dont exist in Blizzards color table
DebuffColors.Bleed = { r = 1, g = 0.2, b = 0.6 }
DebuffColors.EnemyNPC = { r = 0.9, g = 0.1, b = 0.1 }
DebuffColors.BadDispel = { r = 0.05, g = 0.85, b = 0.94 }
DebuffColors.Stealable = { r = 0.93, g = 0.91, b = 0.55 }

local DispelList = {}
lib.DispelList = DispelList

local BleedList = {}
lib.BleedList = BleedList

if Retail then
	BleedList[411101] = "Artifact Shards"
	BleedList[224435] = "Ashamane's Rip"
	BleedList[348074] = "Assailing Lance"
	BleedList[270084] = "Axe Barrage"
	BleedList[90098] = "Axe to the Head"
	BleedList[358126] = "Banshee's Blight"
	BleedList[256914] = "Barbed Blade"
	BleedList[189035] = "Barbed Cutlass"
	BleedList[217200] = "Barbed Shot"
	BleedList[194674] = "Barbed Spear"
	BleedList[256314] = "Barbed Strike"
	BleedList[231003] = "Barbed Talons"
	BleedList[392414] = "Beetle Charge"
	BleedList[392416] = "Beetle Charge"
	BleedList[392411] = "Beetle Thrust"
	BleedList[175747] = "Big Sharp Nasty Claws"
	BleedList[277077] = "Big Sharp Nasty Teeth"
	BleedList[186639] = "Big Sharp Nasty Teeth"
	BleedList[372796] = "Blazing Rush"
	BleedList[320147] = "Bleeding"
	BleedList[375416] = "Bleeding"
	BleedList[341863] = "Bleeding Out"
	BleedList[363831] = "Bleeding Soul"
	BleedList[326298] = "Bleeding Wound"
	BleedList[296777] = "Bleeding Wound"
	BleedList[74846] = "Bleeding Wound"
	BleedList[267080] = "Blight of G'huun"
	BleedList[267103] = "Blight of G'huun"
	BleedList[277592] = "Blood Frenzy"
	BleedList[254901] = "Blood Frenzy"
	BleedList[37487] = "Blood Heal"
	BleedList[265533] = "Blood Maw"
	BleedList[192925] = "Blood of the Assassinated"
	BleedList[113344] = "Bloodbath"
	BleedList[207690] = "Bloodlet"
	BleedList[124341] = "Bloodletting"
	BleedList[187647] = "Bloodletting Pounce"
	BleedList[186191] = "Bloodletting Slash"
	BleedList[210013] = "Bloodletting Slash"
	BleedList[139514] = "Bloodstorm"
	BleedList[385834] = "Bloodthirsty Charge"
	BleedList[277569] = "Bloodthirsty Rend"
	BleedList[367481] = "Bloody Bite"
	BleedList[348385] = "Bloody Cleave"
	BleedList[185698] = "Bloody Hack"
	BleedList[366075] = "Bloody Peck"
	BleedList[359587] = "Bloody Peck"
	BleedList[196189] = "Bloody Talons"
	BleedList[340374] = "Bloody Tantrum"
	BleedList[372570] = "Bold Ambush"
	BleedList[367521] = "Bone Bolt"
	BleedList[193639] = "Bone Chomp"
	BleedList[256880] = "Bone Splinter"
	BleedList[266035] = "Bone Splinter"
	BleedList[321807] = "Boneflay"
	BleedList[368701] = "Boon of Harvested Hope"
	BleedList[308342] = "Bore"
	BleedList[260701] = "Bramble Bolt"
	BleedList[260697] = "Bramble Bolt"
	BleedList[278175] = "Bramble Claw"
	BleedList[273900] = "Bramble Swipe"
	BleedList[257250] = "Bramblepelt"
	BleedList[411437] = "Brutal Lacerations"
	BleedList[63468] = "Careful Aim"
	BleedList[329906] = "Carnage"
	BleedList[78842] = "Carnivorous Bite"
	BleedList[41092] = "Carnivorous Bite"
	BleedList[50729] = "Carnivorous Bite"
	BleedList[308859] = "Carnivorous Bite"
	BleedList[122962] = "Carnivorous Bite"
	BleedList[59269] = "Carnivorous Bite"
	BleedList[32901] = "Carnivorous Bite"
	BleedList[36383] = "Carnivorous Bite"
	BleedList[30639] = "Carnivorous Bite"
	BleedList[39382] = "Carnivorous Bite"
	BleedList[144853] = "Carnivorous Bite"
	BleedList[41932] = "Carnivorous Bite"
	BleedList[39198] = "Carnivorous Bite"
	BleedList[177337] = "Carnivorous Bite"
	BleedList[303162] = "Carve Flesh"
	BleedList[339189] = "Chain Bleed"
	BleedList[265165] = "Charging Gore"
	BleedList[172889] = "Charging Slash"
	BleedList[219167] = "Chomp"
	BleedList[255595] = "Chomp"
	BleedList[369828] = "Chomp"
	BleedList[145263] = "Chomp"
	BleedList[144113] = "Chomp"
	BleedList[76507] = "Claw Puncture"
	BleedList[271798] = "Click"
	BleedList[65033] = "Constricting Rend"
	BleedList[31410] = "Coral Cut"
	BleedList[241465] = "Coral Cut"
	BleedList[182330] = "Coral Cut"
	BleedList[37973] = "Coral Cut"
	BleedList[129463] = "Crane Kick"
	BleedList[341475] = "Crimson Flurry"
	BleedList[384575] = "Crippling Bite"
	BleedList[230011] = "Cruel Garrote"
	BleedList[343722] = "Crushing Bite"
	BleedList[357665] = "Crystalline Flesh"
	BleedList[357657] = "Crystalshards"
	BleedList[333985] = "Culling Strike"
	BleedList[194636] = "Cursed Rend"
	BleedList[281711] = "Cut of Death"
	BleedList[391114] = "Cutting Winds"
	BleedList[280286] = "Dagger in the Back"
	BleedList[67280] = "Dagger Throw"
	BleedList[339789] = "Darksworn Blast"
	BleedList[339453] = "Darksworn Blast"
	BleedList[53602] = "Dart"
	BleedList[59349] = "Dart"
	BleedList[325037] = "Death Chakram"
	BleedList[361756] = "Death Chakram"
	BleedList[375893] = "Death Chakram"
	BleedList[55645] = "Death Plague"
	BleedList[55604] = "Death Plague"
	BleedList[36023] = "Deathblow"
	BleedList[36054] = "Deathblow"
	BleedList[360194] = "Deathmark"
	BleedList[314847] = "Decapitate"
	BleedList[314568] = "Deep Wound"
	BleedList[311744] = "Deep Wound"
	BleedList[43104] = "Deep Wound"
	BleedList[23256] = "Deep Wounds"
	BleedList[43100] = "Deep Wounds"
	BleedList[115767] = "Deep Wounds"
	BleedList[262115] = "Deep Wounds"
	BleedList[265948] = "Denticulated"
	BleedList[404980] = "Devastating Rend"
	BleedList[404951] = "Devastating Rend"
	BleedList[404982] = "Devastating Rend"
	BleedList[404978] = "Devastating Rend"
	BleedList[38848] = "Diminish Soul"
	BleedList[36789] = "Diminish Soul"
	BleedList[335105] = "Dinner Time"
	BleedList[242828] = "Dire Thrash"
	BleedList[288149] = "Dragon Claws"
	BleedList[373735] = "Dragon Strike"
	BleedList[372224] = "Dragonbone Axe"
	BleedList[112896] = "Drain Blood"
	BleedList[151475] = "Drain Life"
	BleedList[411924] = "Drilljaws"
	BleedList[89212] = "Eagle Claw"
	BleedList[30285] = "Eagle Claw"
	BleedList[372718] = "Earthen Shards"
	BleedList[95334] = "Elementium Spike Shield"
	BleedList[78859] = "Elementium Spike Shield"
	BleedList[244040] = "Eskhandar's Rake"
	BleedList[336628] = "Eternal Polearm"
	BleedList[186730] = "Exposed Wounds"
	BleedList[328897] = "Exsanguinated"
	BleedList[82766] = "Eye Gouge"
	BleedList[357953] = "Fanged Bite"
	BleedList[300610] = "Fanged Bite"
	BleedList[221759] = "Feathery Stab"
	BleedList[241212] = "Fel Slash"
	BleedList[238618] = "Fel Swipe"
	BleedList[193340] = "Fenri's Bite"
	BleedList[257036] = "Feral Charge"
	BleedList[200182] = "Festering Rip"
	BleedList[128087] = "Fierce Nibble"
	BleedList[37937] = "Flayed Flesh"
	BleedList[324149] = "Flayed Shot"
	BleedList[38056] = "Flesh Rip"
	BleedList[40199] = "Flesh Rip"
	BleedList[102066] = "Flesh Rip"
	BleedList[28913] = "Flesh Rot"
	BleedList[49678] = "Flesh Rot"
	BleedList[59007] = "Flesh Rot"
	BleedList[391140] = "Frenzied Assault"
	BleedList[392235] = "Furious Charge"
	BleedList[392236] = "Furious Charge"
	BleedList[225682] = "Furious Swipes"
	BleedList[29935] = "Gaping Maw"
	BleedList[273632] = "Gaping Maw"
	BleedList[38810] = "Gaping Maw"
	BleedList[36617] = "Gaping Maw"
	BleedList[96570] = "Gaping Wound"
	BleedList[97357] = "Gaping Wound"
	BleedList[403662] = "Garrote"
	BleedList[102925] = "Garrote"
	BleedList[37066] = "Garrote"
	BleedList[128903] = "Garrote"
	BleedList[229265] = "Garrote"
	BleedList[280321] = "Garrote"
	BleedList[360830] = "Garrote"
	BleedList[137497] = "Garrote"
	BleedList[8818] = "Garrote"
	BleedList[703] = "Garrote"
	BleedList[320007] = "Gash"
	BleedList[378020] = "Gash Frenzy"
	BleedList[213431] = "Gnawing Eagle"
	BleedList[273436] = "Gore"
	BleedList[48130] = "Gore"
	BleedList[59264] = "Gore"
	BleedList[319127] = "Gore"
	BleedList[337892] = "Gore"
	BleedList[32019] = "Gore"
	BleedList[270139] = "Gore"
	BleedList[328940] = "Gore"
	BleedList[332792] = "Gore"
	BleedList[256077] = "Gore"
	BleedList[329563] = "Goring Swipe"
	BleedList[158150] = "Goring Swipe"
	BleedList[259328] = "Gory Whirl"
	BleedList[48286] = "Grievous Slash"
	BleedList[196376] = "Grievous Tear"
	BleedList[43093] = "Grievous Throw"
	BleedList[76524] = "Grievous Whirl"
	BleedList[59262] = "Grievous Wound"
	BleedList[38772] = "Grievous Wound"
	BleedList[58517] = "Grievous Wound"
	BleedList[199847] = "Grievous Wound"
	BleedList[59682] = "Grievous Wound"
	BleedList[80051] = "Grievous Wound"
	BleedList[31956] = "Grievous Wound"
	BleedList[38801] = "Grievous Wound"
	BleedList[240559] = "Grievous Wound"
	BleedList[240449] = "Grievous Wound"
	BleedList[43937] = "Grievous Wound"
	BleedList[346770] = "Grinding Bite"
	BleedList[318187] = "Gushing Wound"
	BleedList[165308] = "Gushing Wound"
	BleedList[385042] = "Gushing Wound"
	BleedList[260582] = "Gushing Wound"
	BleedList[332678] = "Gushing Wound"
	BleedList[35321] = "Gushing Wound"
	BleedList[38363] = "Gushing Wound"
	BleedList[288091] = "Gushing Wound"
	BleedList[403589] = "Gushing Wound"
	BleedList[39215] = "Gushing Wound"
	BleedList[166638] = "Gushing Wound"
	BleedList[158341] = "Gushing Wounds"
	BleedList[52401] = "Gut Rip"
	BleedList[51275] = "Gut Rip"
	BleedList[333478] = "Gut Slice"
	BleedList[222491] = "Gutripper"
	BleedList[393817] = "Hardened Shards"
	BleedList[114881] = "Hawk Rend"
	BleedList[204968] = "Hemoraging Barbs"
	BleedList[396675] = "Hemorrhaging Rend"
	BleedList[253516] = "Hexabite"
	BleedList[394371] = "Hit the Mark"
	BleedList[354334] = "Hook'd!"
	BleedList[392332] = "Horn Gore"
	BleedList[333235] = "Horn Rush"
	BleedList[392841] = "Hungry Chomp"
	BleedList[277431] = "Hunter Toxin"
	BleedList[176147] = "Ignite"
	BleedList[217868] = "Impale"
	BleedList[62331] = "Impale"
	BleedList[48261] = "Impale"
	BleedList[59256] = "Impale"
	BleedList[219680] = "Impale"
	BleedList[58459] = "Impale"
	BleedList[29583] = "Impale"
	BleedList[121247] = "Impale"
	BleedList[59268] = "Impale"
	BleedList[276868] = "Impale"
	BleedList[79444] = "Impale"
	BleedList[62418] = "Impale"
	BleedList[83783] = "Impale"
	BleedList[397092] = "Impaling Horn"
	BleedList[270343] = "Internal Bleeding"
	BleedList[381628] = "Internal Bleeding"
	BleedList[154953] = "Internal Bleeding"
	BleedList[260016] = "Itchy Bite"
	BleedList[258075] = "Itchy Bite"
	BleedList[166639] = "Item - Druid T17 Feral 4P Bonus Proc Driver"
	BleedList[377732] = "Jagged Bite"
	BleedList[365877] = "Jagged Blade"
	BleedList[257544] = "Jagged Cut"
	BleedList[323406] = "Jagged Gash"
	BleedList[264210] = "Jagged Mandible"
	BleedList[256715] = "Jagged Maw"
	BleedList[254280] = "Jagged Maw"
	BleedList[277309] = "Jagged Maw"
	BleedList[260741] = "Jagged Nettles"
	BleedList[215506] = "Jagged Quills"
	BleedList[218506] = "Jagged Slash"
	BleedList[370742] = "Jagged Strike"
	BleedList[358224] = "Jagged Swipe"
	BleedList[342250] = "Jagged Swipe"
	BleedList[325022] = "Jagged Swipe"
	BleedList[344993] = "Jagged Swipe"
	BleedList[325024] = "Jaws of Stone"
	BleedList[262677] = "Keelhaul"
	BleedList[337729] = "Kerim's Laceration"
	BleedList[220874] = "Lacerate"
	BleedList[76807] = "Lacerate"
	BleedList[247012] = "Lacerate"
	BleedList[185855] = "Lacerate"
	BleedList[282444] = "Lacerating Claws"
	BleedList[289373] = "Lacerating Pounce"
	BleedList[42395] = "Lacerating Slash"
	BleedList[162951] = "Lacerating Spines"
	BleedList[196313] = "Lacerating Talons"
	BleedList[186594] = "Laceration"
	BleedList[205437] = "Laceration"
	BleedList[257971] = "Leaping Thrash"
	BleedList[348726] = "Lethal Shot"
	BleedList[390583] = "Logcutter"
	BleedList[10266] = "Lung Puncture"
	BleedList[367726] = "Lupine's Slash"
	BleedList[120699] = "Lynx Rush"
	BleedList[241644] = "Mangle"
	BleedList[79828] = "Mangle"
	BleedList[208467] = "Mangle"
	BleedList[288539] = "Mangle"
	BleedList[286269] = "Mangle"
	BleedList[288266] = "Mangle"
	BleedList[99100] = "Mangle"
	BleedList[31041] = "Mangle"
	BleedList[85415] = "Mangle"
	BleedList[209336] = "Mangle"
	BleedList[75930] = "Mangle"
	BleedList[217142] = "Mangle"
	BleedList[280940] = "Mangle"
	BleedList[208945] = "Mangle"
	BleedList[269576] = "Master Marksman"
	BleedList[385511] = "Messy"
	BleedList[386116] = "Messy"
	BleedList[361175] = "Midnight"
	BleedList[392341] = "Mighty Swipe"
	BleedList[325021] = "Mistveil Tear"
	BleedList[126901] = "Mortal Rend"
	BleedList[93675] = "Mortal Wound"
	BleedList[381672] = "Mutilated Flesh"
	BleedList[211672] = "Mutilated Flesh"
	BleedList[394021] = "Mutilated Flesh"
	BleedList[340431] = "Mutilated Flesh"
	BleedList[208470] = "Necrotic Thrash"
	BleedList[209858] = "Necrotic Wound"
	BleedList[357322] = "Night Glaive"
	BleedList[207662] = "Nightmare Wounds"
	BleedList[385060] = "Odyn's Fury"
	BleedList[66620] = "Old Wounds"
	BleedList[52873] = "Open Wound"
	BleedList[394628] = "Peck"
	BleedList[377344] = "Peck"
	BleedList[162921] = "Peck"
	BleedList[332610] = "Penetrating Insight"
	BleedList[182325] = "Phantasmal Wounds"
	BleedList[302474] = "Phantom Laceration"
	BleedList[270329] = "Pheromone Bomb"
	BleedList[259983] = "Pierce"
	BleedList[355087] = "Piercing Quill"
	BleedList[88859] = "Pincer Pierce"
	BleedList[174423] = "Pinning Spines"
	BleedList[331340] = "Plague Swipe"
	BleedList[356620] = "Pouch of Razor Fragments"
	BleedList[161229] = "Pounce"
	BleedList[229127] = "Powershot"
	BleedList[182795] = "Primal Mangle"
	BleedList[184175] = "Primal Rake"
	BleedList[390834] = "Primal Rend"
	BleedList[55276] = "Puncture"
	BleedList[368401] = "Puncture"
	BleedList[84642] = "Puncture"
	BleedList[15976] = "Puncture"
	BleedList[59826] = "Puncture"
	BleedList[133074] = "Puncture"
	BleedList[360775] = "Puncture"
	BleedList[154489] = "Puncturing Horns"
	BleedList[391098] = "Puncturing Impalement"
	BleedList[242376] = "Puncturing Strike"
	BleedList[161117] = "Puncturing Tusk"
	BleedList[336810] = "Ragged Claws"
	BleedList[400941] = "Ragged Slash"
	BleedList[120560] = "Rake"
	BleedList[292611] = "Rake"
	BleedList[24332] = "Rake"
	BleedList[242931] = "Rake"
	BleedList[283700] = "Rake"
	BleedList[27638] = "Rake"
	BleedList[54668] = "Rake"
	BleedList[223954] = "Rake"
	BleedList[371472] = "Rake"
	BleedList[130191] = "Rake"
	BleedList[292610] = "Rake"
	BleedList[53499] = "Rake"
	BleedList[24331] = "Rake"
	BleedList[223111] = "Rake"
	BleedList[36332] = "Rake"
	BleedList[65406] = "Rake"
	BleedList[283699] = "Rake"
	BleedList[262557] = "Rake"
	BleedList[27556] = "Rake"
	BleedList[115871] = "Rake"
	BleedList[125099] = "Rake"
	BleedList[147396] = "Rake"
	BleedList[217369] = "Rake"
	BleedList[155722] = "Rake"
	BleedList[1822] = "Rake"
	BleedList[185539] = "Rapid Rupture"
	BleedList[197952] = "Rapid Rupture"
	BleedList[92945] = "Rapier Pierce"
	BleedList[295929] = "Rats!"
	BleedList[315311] = "Ravage"
	BleedList[29906] = "Ravage"
	BleedList[164427] = "Ravage"
	BleedList[262143] = "Ravenous Claws"
	BleedList[196497] = "Ravenous Leap"
	BleedList[385638] = "Razor Fragments"
	BleedList[135892] = "Razor Slice"
	BleedList[81043] = "Razor Slice"
	BleedList[353068] = "Razor Trap"
	BleedList[195506] = "Razorsharp Axe"
	BleedList[258798] = "Razorsharp Teeth"
	BleedList[214676] = "Razorsharp Teeth"
	BleedList[29574] = "Rend"
	BleedList[237346] = "Rend"
	BleedList[36991] = "Rend"
	BleedList[144304] = "Rend"
	BleedList[152623] = "Rend"
	BleedList[13443] = "Rend"
	BleedList[283419] = "Rend"
	BleedList[43246] = "Rend"
	BleedList[17504] = "Rend"
	BleedList[359981] = "Rend"
	BleedList[223572] = "Rend"
	BleedList[362819] = "Rend"
	BleedList[37662] = "Rend"
	BleedList[140276] = "Rend"
	BleedList[14087] = "Rend"
	BleedList[16393] = "Rend"
	BleedList[18106] = "Rend"
	BleedList[217163] = "Rend"
	BleedList[54708] = "Rend"
	BleedList[59239] = "Rend"
	BleedList[144263] = "Rend"
	BleedList[12054] = "Rend"
	BleedList[204175] = "Rend"
	BleedList[48880] = "Rend"
	BleedList[16509] = "Rend"
	BleedList[53317] = "Rend"
	BleedList[29578] = "Rend"
	BleedList[228275] = "Rend"
	BleedList[13445] = "Rend"
	BleedList[43931] = "Rend"
	BleedList[18075] = "Rend"
	BleedList[59343] = "Rend"
	BleedList[140396] = "Rend"
	BleedList[146927] = "Rend"
	BleedList[14118] = "Rend"
	BleedList[16403] = "Rend"
	BleedList[18200] = "Rend"
	BleedList[265232] = "Rend"
	BleedList[59691] = "Rend"
	BleedList[36965] = "Rend"
	BleedList[274089] = "Rend"
	BleedList[144264] = "Rend"
	BleedList[152357] = "Rend"
	BleedList[13318] = "Rend"
	BleedList[17153] = "Rend"
	BleedList[21949] = "Rend"
	BleedList[114860] = "Rend"
	BleedList[228281] = "Rend"
	BleedList[140275] = "Rend"
	BleedList[254575] = "Rend"
	BleedList[279133] = "Rend"
	BleedList[13738] = "Rend"
	BleedList[18078] = "Rend"
	BleedList[54703] = "Rend"
	BleedList[265074] = "Rend"
	BleedList[241092] = "Rend"
	BleedList[76594] = "Rend"
	BleedList[11977] = "Rend"
	BleedList[16406] = "Rend"
	BleedList[260400] = "Rend"
	BleedList[18202] = "Rend"
	BleedList[388539] = "Rend"
	BleedList[394062] = "Rend"
	BleedList[327258] = "Rend"
	BleedList[394063] = "Rend"
	BleedList[314533] = "Rend"
	BleedList[772] = "Rend"
	BleedList[270979] = "Rend and Tear"
	BleedList[3147] = "Rend Flesh"
	BleedList[42397] = "Rend Flesh"
	BleedList[221770] = "Rend Flesh"
	BleedList[125206] = "Rend Flesh"
	BleedList[256969] = "Rend Flesh"
	BleedList[275895] = "Rend of Kimbul"
	BleedList[365336] = "Rending Bite"
	BleedList[366275] = "Rending Bite"
	BleedList[285875] = "Rending Bite"
	BleedList[136654] = "Rending Charge"
	BleedList[266505] = "Rending Claw"
	BleedList[289848] = "Rending Claw"
	BleedList[258143] = "Rending Claws"
	BleedList[184025] = "Rending Claws"
	BleedList[174820] = "Rending Claws"
	BleedList[173876] = "Rending Claws"
	BleedList[194639] = "Rending Claws"
	BleedList[341833] = "Rending Cleave"
	BleedList[272273] = "Rending Cleave"
	BleedList[369408] = "Rending Slash"
	BleedList[396641] = "Rending Slash"
	BleedList[166185] = "Rending Slash"
	BleedList[388377] = "Rending Slash"
	BleedList[390194] = "Rending Slash"
	BleedList[158453] = "Rending Swipe"
	BleedList[391308] = "Rending Swoop"
	BleedList[275011] = "Rending Whirl"
	BleedList[260025] = "Rending Whirl"
	BleedList[256476] = "Rending Whirl"
	BleedList[173299] = "Rip"
	BleedList[59989] = "Rip"
	BleedList[133081] = "Rip"
	BleedList[71926] = "Rip"
	BleedList[251332] = "Rip"
	BleedList[208946] = "Rip"
	BleedList[57661] = "Rip"
	BleedList[259873] = "Rip"
	BleedList[292626] = "Rip"
	BleedList[36590] = "Rip"
	BleedList[188353] = "Rip"
	BleedList[79829] = "Rip"
	BleedList[283708] = "Rip"
	BleedList[288535] = "Rip"
	BleedList[33912] = "Rip"
	BleedList[1079] = "Rip"
	BleedList[366884] = "Ripped Secrets"
	BleedList[155065] = "Ripping Claw"
	BleedList[299474] = "Ripping Slash"
	BleedList[82753] = "Ritual of Bloodletting"
	BleedList[93587] = "Ritual of Bloodletting"
	BleedList[80028] = "Rock Bore"
	BleedList[15583] = "Rupture"
	BleedList[145417] = "Rupture"
	BleedList[360826] = "Rupture"
	BleedList[14874] = "Rupture"
	BleedList[283667] = "Rupture"
	BleedList[14903] = "Rupture"
	BleedList[175014] = "Rupture"
	BleedList[1943] = "Rupture"
	BleedList[353919] = "Rury's Sleepy Tantrum"
	BleedList[75388] = "Rusty Cut"
	BleedList[332835] = "Ruthless Strikes"
	BleedList[353466] = "Sadistic Glee"
	BleedList[175461] = "Sadistic Slice"
	BleedList[265019] = "Savage Cleave"
	BleedList[376997] = "Savage Peck"
	BleedList[64666] = "Savage Pounce"
	BleedList[64374] = "Savage Pounce"
	BleedList[50871] = "Savage Rend"
	BleedList[388301] = "Savage Tear"
	BleedList[257170] = "Savage Tempest"
	BleedList[169752] = "Scent of Blood"
	BleedList[81690] = "Scent of Blood"
	BleedList[258718] = "Scratched!"
	BleedList[372860] = "Searing Wounds"
	BleedList[5597] = "Serious Wound"
	BleedList[5598] = "Serious Wound"
	BleedList[19771] = "Serrated Bite"
	BleedList[119840] = "Serrated Blade"
	BleedList[120166] = "Serrated Blade"
	BleedList[344312] = "Serrated Edge"
	BleedList[172657] = "Serrated Edge"
	BleedList[87395] = "Serrated Slash"
	BleedList[277517] = "Serrated Slash"
	BleedList[128051] = "Serrated Slash"
	BleedList[155701] = "Serrated Slash"
	BleedList[173307] = "Serrated Spear"
	BleedList[169584] = "Serrated Spines"
	BleedList[315711] = "Serrated Strike"
	BleedList[266231] = "Severing Axe"
	BleedList[270487] = "Severing Blade"
	BleedList[388912] = "Severing Slash"
	BleedList[222494] = "Severing Strike"
	BleedList[222499] = "Severing Strike"
	BleedList[183952] = "Shadow Claws"
	BleedList[213990] = "Shard Bore"
	BleedList[355416] = "Sharpened Hide"
	BleedList[356445] = "Sharpened Hide"
	BleedList[264145] = "Shatter"
	BleedList[264150] = "Shatter"
	BleedList[159238] = "Shattered Bleed"
	BleedList[259382] = "Shell Slash"
	BleedList[303215] = "Shell Slash"
	BleedList[344464] = "Shield Spike"
	BleedList[270338] = "Shrapnel Bomb"
	BleedList[215442] = "Shred"
	BleedList[217041] = "Shred"
	BleedList[27555] = "Shred"
	BleedList[163276] = "Shredded Tendons"
	BleedList[42658] = "Sic'em!"
	BleedList[363830] = "Sickle of the Lion"
	BleedList[33865] = "Singe"
	BleedList[136753] = "Slashing Talons"
	BleedList[253384] = "Slaughter"
	BleedList[302295] = "Slicing Claw"
	BleedList[345548] = "Spare Meat Hook"
	BleedList[24192] = "Speed Slash"
	BleedList[356808] = "Spiked"
	BleedList[198563] = "Spineshatter"
	BleedList[75161] = "Spinning Rake"
	BleedList[81568] = "Spinning Slash"
	BleedList[81569] = "Spinning Slash"
	BleedList[387809] = "Splatter!"
	BleedList[396716] = "Splinterbark"
	BleedList[261882] = "Steel Jaw Trap"
	BleedList[162487] = "Steel Trap"
	BleedList[201199] = "Steel Trap Expert"
	BleedList[273909] = "Steelclaw Trap"
	BleedList[172019] = "Stingtail Venom"
	BleedList[320200] = "Stitchneedle"
	BleedList[186365] = "Sweeping Blade"
	BleedList[329516] = "Swift Slash"
	BleedList[381692] = "Swift Stab"
	BleedList[128238] = "Swift Strike"
	BleedList[391725] = "Swooping Dive"
	BleedList[391313] = "Swooping Dive"
	BleedList[317561] = "Swooping Lunge"
	BleedList[170936] = "Talador Venom"
	BleedList[229923] = "Talon Rend"
	BleedList[375201] = "Talon Rip"
	BleedList[394787] = "Talon Shred"
	BleedList[271873] = "Talon Slash"
	BleedList[263144] = "Talon Slash"
	BleedList[176256] = "Talon Sweep"
	BleedList[328910] = "Tantrum"
	BleedList[391356] = "Tear"
	BleedList[386640] = "Tear Flesh"
	BleedList[264556] = "Tearing Strike"
	BleedList[91348] = "Tenderize"
	BleedList[361024] = "Thief's Blade"
	BleedList[256965] = "Thorned Barrage"
	BleedList[129307] = "Thousand Nibbles"
	BleedList[405233] = "Thrash"
	BleedList[292576] = "Thrash"
	BleedList[219339] = "Thrash"
	BleedList[106830] = "Thrash"
	BleedList[177422] = "Thrash"
	BleedList[182846] = "Thrash"
	BleedList[172035] = "Thrash"
	BleedList[77758] = "Thrash"
	BleedList[397364] = "Thunderous Roar"
	BleedList[98282] = "Tiny Rend"
	BleedList[334669] = "Tirnenn Wrath"
	BleedList[215537] = "Trauma"
	BleedList[258825] = "Vampiric Bite"
	BleedList[130897] = "Vicious Bite"
	BleedList[221422] = "Vicious Bite"
	BleedList[69203] = "Vicious Bite"
	BleedList[396007] = "Vicious Peck"
	BleedList[35144] = "Vicious Rend"
	BleedList[125624] = "Vicious Rend"
	BleedList[16095] = "Vicious Rend"
	BleedList[14331] = "Vicious Rend"
	BleedList[131662] = "Vicious Stabbing"
	BleedList[170367] = "Vicious Throw"
	BleedList[140274] = "Vicious Wound"
	BleedList[368651] = "Vicious Wound"
	BleedList[157344] = "Vital Strike"
	BleedList[158667] = "Warleader's Spear"
	BleedList[266191] = "Whirling Axe"
	BleedList[59824] = "Whirling Slash"
	BleedList[59825] = "Whirling Slash"
	BleedList[55249] = "Whirling Slash"
	BleedList[55250] = "Whirling Slash"
	BleedList[339163] = "Wicked Gash"
	BleedList[322796] = "Wicked Gash"
	BleedList[327814] = "Wicked Gash"
	BleedList[331415] = "Wicked Gash"
	BleedList[240539] = "Wild Bite"
	BleedList[225465] = "Wild Charge"
	BleedList[225466] = "Wild Slash"
	BleedList[167334] = "Windfang Bite"
	BleedList[58830] = "Wounding Strike"
	BleedList[52771] = "Wounding Strike"
	BleedList[411101] = "Artifact Shards"
	BleedList[411437] = "Brutal Lacerations"
	BleedList[411924] = "Drilljaws"
	BleedList[403662] = "Garrote"
	BleedList[403589] = "Gushing Wound"
	BleedList[405233] = "Thrash"
end

local BadList = {} -- Dispels that backfire
lib.BadList = BadList

if Retail then
	BadList[34914] = 'Vampiric Touch'		-- horrifies
	BadList[233490] = 'Unstable Affliction'	-- silences
end

local BlockList = {} -- Blocked from AuraHighlight
lib.BlockList = BlockList

if Retail then
	BlockList[140546] = 'Fully Mutated'
	BlockList[136184] = 'Thick Bones'
	BlockList[136186] = 'Clear Mind'
	BlockList[136182] = 'Improved Synapses'
	BlockList[136180] = 'Keen Eyesight'
	BlockList[105171] = 'Deep Corruption'
	BlockList[108220] = 'Deep Corruption'
	BlockList[116095] = 'Disable' -- Slow
end

function lib:GetDebuffTypeColor()
	return DebuffColors
end

function lib:GetBleedList()
	return BleedList
end

function lib:GetBadList()
	return BadList
end

function lib:GetBlockList()
	return BlockList
end

function lib:GetMyDispelTypes()
	return DispelList
end

function lib:IsDispellableByMe(debuffType)
	return DispelList[debuffType]
end

do
	local _, myClass = UnitClass("player")
	local WarlockPetSpells = {
		[89808] = 'Singe',
		[19505] = 'Devour Magic Rank 1',
		[19731] = 'Devour Magic Rank 2',
		[19734] = 'Devour Magic Rank 3',
		[19736] = 'Devour Magic Rank 4',
		[27276] = 'Devour Magic Rank 5',
		[27277] = 'Devour Magic Rank 6',
		[48011] = 'Devour Magic Rank 7'
	}

	local function CheckSpell(spellID, pet)
		return IsSpellKnownOrOverridesKnown(spellID, pet) and true or nil
	end

	local function CheckPetSpells()
		if Retail then
			return CheckSpell(89808, true)
		else
			for spellID in next, WarlockPetSpells do
				if CheckSpell(spellID, true) then
					return true
				end
			end
		end
	end

	local function UpdateDispels(_, event, arg1)
		if event == 'CHARACTER_POINTS_CHANGED' and arg1 > 0 then
			return -- Not interested in gained points from leveling
		end

		-- this will fix a problem where spells dont show as existing because they are 'hidden'
		local undoRanks = Wrath and GetCVar('ShowAllSpellRanks') ~= '1' and SetCVar('ShowAllSpellRanks', 1)

		if event == 'UNIT_PET' then
			DispelList.Magic = CheckPetSpells()
		elseif myClass == 'DRUID' then
			local cure = Retail and CheckSpell(88423) -- Nature's Cure
			local corruption = CheckSpell(2782) -- Remove Corruption (retail), Curse (classic)
			DispelList.Magic = cure
			DispelList.Curse = cure or corruption
			DispelList.Poison = cure or (Retail and corruption) or CheckSpell(2893) or CheckSpell(8946) -- Abolish Poison / Cure Poison
		elseif myClass == 'MAGE' then
			DispelList.Curse = CheckSpell(475) -- Remove Curse
		elseif myClass == 'MONK' then
			local mwDetox = CheckSpell(115450) -- Detox (Mistweaver)
			local detox = mwDetox or CheckSpell(218164) -- Detox (Brewmaster or Windwalker)
			DispelList.Magic = mwDetox
			DispelList.Disease = detox
			DispelList.Poison = detox
		elseif myClass == 'PALADIN' then
			local cleanse = CheckSpell(4987) -- Cleanse
			local purify = CheckSpell(1152) -- Purify
			local toxins = cleanse or purify or CheckSpell(213644) -- Cleanse Toxins
			DispelList.Magic = cleanse
			DispelList.Poison = toxins
			DispelList.Disease = toxins
		elseif myClass == 'PRIEST' then
			local dispel = CheckSpell(527) -- Dispel Magic
			DispelList.Magic = dispel or CheckSpell(32375)
			DispelList.Disease = Retail and (IsPlayerSpell(390632) or CheckSpell(213634)) or not Retail and (CheckSpell(552) or CheckSpell(528)) -- Purify Disease / Abolish Disease / Cure Disease
		elseif myClass == 'SHAMAN' then
			local purify = Retail and CheckSpell(77130) -- Purify Spirit
			local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit
			local toxins = Retail and CheckSpell(383013) or CheckSpell(526) -- Poison Cleansing Totem (Retail), Cure Toxins (TBC/Classic)

			DispelList.Magic = purify
			DispelList.Curse = cleanse
			DispelList.Poison = toxins or (not Retail and cleanse)
			DispelList.Disease = not Retail and (cleanse or toxins)
		elseif myClass == 'EVOKER' then
			local naturalize = CheckSpell(360823) -- Naturalize (Preservation)
			local expunge = CheckSpell(365585) -- Expunge (Devastation)
			local cauterizing = CheckSpell(374251) -- Cauterizing Flame

			DispelList.Magic = naturalize
			DispelList.Poison = naturalize or expunge or cauterizing
			DispelList.Disease = cauterizing
			DispelList.Curse = cauterizing
			DispelList.Bleed = cauterizing
		end

		if undoRanks then
			SetCVar('ShowAllSpellRanks', 0)
		end
	end

	local frame = CreateFrame('Frame')
	frame:SetScript('OnEvent', UpdateDispels)
	frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
	frame:RegisterEvent('PLAYER_LOGIN')

	if myClass == 'WARLOCK' then
		frame:RegisterUnitEvent('UNIT_PET', 'player')
	end

	if Wrath then
		frame:RegisterEvent('PLAYER_TALENT_UPDATE')
	elseif Retail then
		frame:RegisterEvent('LEARNED_SPELL_IN_TAB')
		frame:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
	end
end
