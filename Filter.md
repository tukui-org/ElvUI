## Friendly Nameplates  
___
### Player  
**Buffs:**  
big defensive:player, external defensive, raid in combat:player  
**Debuffs:**  
blocklist, all  
### Friendly Player  
**Buffs:**  
big defensive, external defensive, raid in combat:player  
**Debuffs:**  
blocklist, raid:player  
### Friendly NPC  
**Buffs:**  
big defensive, external defensive, raid in combat:player  
**Debuffs:**  
blocklist, raid:player  

## Enemy Nameplates  
___
### Enemy Player  
**Custom:**  
blocklist, crowd control  
**Buffs:**  
big defensive, external defensive, raid player dispellable, is stealable  
**Debuffs:**  
blocklist, nameplate show personal, block crowd control  
### Enemy NPC  
**Custom:**  
blocklist, crowd control  
**Buffs:**  
is boss or role aura, is stealable, important  
**Debuffs:**  
blocklist, nameplate show personal, block crowd control  

## Individual Units  
___
### Player  
**Buffs:**  
big defensive:player, external defensive  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
### Pet  
**Buffs:**  
external defensive, raid:player  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
### Target  
**Custom:**  
blocklist, crowd control  
**Buffs:**  
is boss or role aura, is stealable, important, is from player or player pet(for mounts etc?)  
**Debuffs:**  
blocklist, nameplate show personal  

### Focus  
**Buffs:**  
is boss or role aura, is stealable, important, raid:player, big defensive, external defensive  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
### TargetTarget  
**Show all and auras enable off by default**  
### TargetTargetTarget  
**Show all and auras enable off by default**  
### FocusTarget  
**Show all and auras enable off by default**  
### PetTarget  
**Show all and auras enable off by default**  

## Group Units  
___
### Arena  
**Buffs:**  
big defensive, external defensive, raid player dispellable, is stealable, raid:player  
**Debuffs:**  
blocklist, nameplate show personal, block crowd control  
### Boss  
**Buffs:**  
is boss or role aura, is stealable, important  
**Debuffs:**  
blocklist, nameplate show personal  
### Party  
**Buffs:**  
big defensive, external defensive, whitelist include(can we? innervate, power infusion)  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
### Raid  
**Buffs:**  
big defensive, external defensive, whitelist include(can we? innervate, power infusion)  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
### Tank  
**Buffs:**  
is boss or role aura, is stealable, important, raid:player, big defensive, external defensive  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
### Assist  
**Show all and auras enable off by default**  
### Raid Pet  
**Show all and auras enable off by default**  

## Filter strings  
___
`HELPFUL` include buffs 
`HARMFUL` include debuffs 
`PLAYER` include unit: player, pet, vehicle 
`RAID` (buff: player can apply) (debuff: player can dispel) 
`RAID_PLAYER_DISPELLABLE` (buff: someone can purge/steal) (debuff: someone can dispel) 
`RAID_IN_COMBAT` (combine with helpful and player for self-cast hots, matches our AuraWatch table of IDs) 
`CANCELABLE` (buffs to cancel, player only) 
`INCLUDE_NAME_PLATE_ONLY` (when used include nameplate-only auras, otherwise excludes nameplate-only auras) 
`EXTERNAL_DEFENSIVE` (buffs: pain suppression, iron bark, time dilation) 
`CROWD CONTROL` (debuffs: stun, fear, silence, slow) 
`BIG_DEFENSIVE` (buffs: bubble, ice block, blur, barkskin) 
`IMPORTANT` (special helpful auras that show on enemy even if non-stealable) 
`DISPELLABLE` (dispellable/purgeable/stealable by at least one class in the game, even if none of the raid classes can handle it) 
## Candidate filters
___
`isFromPlayerOrPlayerPet` (From any player or pet)  
`isRoleAura` (Role aura - tank/heal/dps?)  
`isPriorityAura` (Priority aura)  
`isStealable` (Stealable)  
`nameplateShowAll` (Nameplate: Show all)  
`nameplateShowPersonal` (Nameplate: Personal)  
`canApplyAura` (Can apply aura)  
`isBossAura` (Boss aura - important shit, was used on last boss this season)  
`isBossOrRoleAura` (the "either-or" between `isRoleAura` and `isBossAura`)  