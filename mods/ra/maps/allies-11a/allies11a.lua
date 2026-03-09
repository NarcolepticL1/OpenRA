--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

--------------------------------------------------------------------
----------------    SUMMARY OF LEVEL IMPLEMENTATION	----------------
--------------------------------------------------------------------
--[[

## Disclaimer
I tried to stick to the original level spirit more than copying verbatim triggers/events (which I don't have access to). I used @yuantse code and @JovialFeline code and notes.

## Design
To my understanding of the original level, western AI attack the player as is usual but also creates combat groups to defend the beach side to prevent the player from moving his MCV to the east side of the map. Original AI also created submarine reinforcements that usually failed to enter the world (they got stuck out of map bounds).

## Deviantions, balance and creative liberties
- Removed hinds/soviet hpads to keep coherency with other ORA campaign levels.
- Heli are too strong on this mission so I added the option for AI to re/build sams (after X time) on west soviet base in "normal" and "hard" (otherwise it wouldn't have any reliable AA option).
- Added extra power plants to USSR to be able to support sams and don't get outage regularly (those replace the hpads).
- Because of redeployable MCVs, player will only get one on hard difficulty. Just to spice things up.
- Air attack waves are infinite because AA options are quite good against them.
- The mission gets a bit ore starved at some point (for both the player and west soviet base) so I added a mine to help this issue. The player will still need to fight to get it
- Increased crystal amount on channel island to make it more enticing when ore runs out (from ~350 to 1500). Original levels has same crystal tile amount but of higher yield.
- Moved some dogs around, added a few more, and gave the AI the option to train and replace them. 
- Spy can steal up to 3000 cash.
- Added a third player (Turkey) to better convey player energy relation.
- Removed passage from USSR base to Turkey power plants. Since allies now have TRAN and longer range mobile artillery on top of lsts, I thought this change made sense (allies-11b doesn't have a land path towards power plants).
- Added LST and marine attack logic to USSR if player moves quickly to east side (mostly to have it for allies-11b).
- Set some actors to defend stance (USSR v2rl and island submarines)
- Original level had 2 hours before England navy arrived. Reduced it to one (normal speed) to fit briefing. Also level doesn't justify more time than that.

## Things missing and possible improvements
Aside from any original triggers; some things that would be nice to have/fix:
- AI selling non-essential buildings if HP of it is too low and resources are scarce.
- USSR Spen submarine attacks behave unreliably. Sometimes subs attack (IdleHunt) sometimes they don't.
- Wasn't able to fully check if plane air waves used BadGuy airfields if not destroyed and if USSR airfields aren't availabla (or the other way around).
- Beach blocker units are set to "defend" stance to make it harder for the player to move towards the east side. "Defend" stance ignores player buildings.

]]

local alert = {}

local IsNaval
local CheckSecuredArea

local AlertUSSR
local AlertBadGuy
local CreateZoneTriggers
local PrepareBadGuyAlerts

local InitialSovietPatrols
local InitialSovietWarning

local TurkeyDefensiveCall

local InitialAlliedReinforcements

local TimerExpiredSendCruisers
local TimerExpiredSendNavy

local ForwardComDiscovery
local EnemySubsReinforcements

local FinishTimer

---------------------------------------

local StartingCashReserves = { easy = 7000, normal = 6000, hard = 5000, challenge = 5000 }
local StartingCash

local OnlyOneMCVCheck = { easy = false, normal = false, hard = true, challenge = true }
local OnlyOneMCV

local AlertUSSRDelays = { easy = DateTime.Minutes(4), normal = DateTime.Minutes(3), hard = DateTime.Minutes(2), challenge = DateTime.Minutes(2) }
local AlertUSSRDelay


local McvReinforcements1 = { actors = { "mcv" }, entryPath = { MCVEntry1.Location, MCVDst1.Location } }
local McvReinforcements2 = { actors = { "mcv" }, entryPath = { MCVEntry2.Location, MCVDst2.Location } }
local McvReinforcements3 = { actors = { "mcv" }, entryPath = { MCVEntry3.Location, MCVDst3.Location } }

local EnglandLeftEarlyNavy = { actors = { "pt", "pt", "dd", "dd" }, entryPath = { EnglandLeftEntry.Location } }
local EnglandRightEarlyNavy = { actors = { "pt", "pt", "dd", "dd" }, entryPath = { EnglandRightEntry.Location } }
local EnglandLeftLateNavy = { actors = { "ca" }, entryPath = { EnglandLeftEntry.Location } }
local EnglandRightLateNavy = { actors = { "ca" }, entryPath = { EnglandRightEntry.Location } }

---@type cpos[]
local SeaLeftPatrolPath = {
EnglandLeftEntry.Location, EnglandLeftWP1.Location, EnglandLeftWP2.Location, EnglandLeftWP3.Location, EnglandLeftWP4.Location, EnglandLeftWP5.Location, EnglandLeftDst.Location, EnglandLeftExit.Location
}

---@type cpos[]
local SeaRightPatrolPath = { 
EnglandRightEntry.Location, EnglandRightWP1.Location, EnglandRightWP2.Location, EnglandRightWP3.Location, EnglandRightWP4.Location, EnglandRightWP5.Location, EnglandRightDst.Location, EnglandRightExit.Location 
}

local SentNavy = false
local SentCruisers = false

local TimeHasEnded = false

-- Change this to a more proper method
local EdgeOfRiverTriggerActivator =
{
	CPos.New(66,19), CPos.New(67,19), CPos.New(68,19), CPos.New(69,19), CPos.New(70,19), CPos.New(71,19),
	CPos.New(72,19), CPos.New(73,19), CPos.New(74,19), CPos.New(75,19), CPos.New(76,19), CPos.New(77,19),
	CPos.New(78,19), CPos.New(79,19), CPos.New(80,19), CPos.New(81,19), CPos.New(82,19), CPos.New(83,19),
	CPos.New(84,19), CPos.New(85,19), CPos.New(86,19), CPos.New(87,19), CPos.New(88,19), CPos.New(89,19),
	CPos.New(90,19), CPos.New(91,19), CPos.New(92,19), CPos.New(93,19), CPos.New(94,19), CPos.New(95,19),
	CPos.New(96,19), CPos.New(97,19), CPos.New(98,19), CPos.New(99,19), CPos.New(100,19), CPos.New(102,19),
	CPos.New(66,20), CPos.New(67,20), CPos.New(68,20), CPos.New(69,20), CPos.New(70,20), CPos.New(71,20),
	CPos.New(72,20), CPos.New(73,20), CPos.New(74,20), CPos.New(75,20), CPos.New(76,20), CPos.New(77,20),
	CPos.New(78,20), CPos.New(79,20), CPos.New(80,20), CPos.New(81,20), CPos.New(82,20), CPos.New(83,20),
	CPos.New(84,20), CPos.New(85,20), CPos.New(86,20), CPos.New(87,20), CPos.New(88,20), CPos.New(89,20),
	CPos.New(90,20), CPos.New(91,20), CPos.New(92,20), CPos.New(93,20), CPos.New(94,20), CPos.New(95,20),
	CPos.New(96,20), CPos.New(97,20), CPos.New(98,20), CPos.New(99,20), CPos.New(100,20), CPos.New(101,20)
}

local USSRBase = {
	USSRFact, USSRPower1, USSRPower2, USSRPower3, USSRPower4, USSRPower5, USSRPower6, USSRPower7, USSRProc, USSRBarr, USSRWeap,
	USSRSpen, USSRKenn, USSRAfld1, USSRAfld2, USSRAfld3, USSRAfld4, USSRDome, USSRStek, USSRFtur1, USSRFtur2, USSRTsla1, USSRTsla2
}

local IslandDefenses = 
	{ IslandTsla1, IslandTsla2, IslandTsla3, IslandTsla4, IslandTsla5, IslandTsla6,
	IslandSam1, IslandSam2, IslandSam3, IslandSub1, IslandSub2, IslandSub3, IslandSub4
}

local BadGuyAlerted = false
local USSRAlerted = false
local USSRTurkey = false

local FcomDiscovered = false

------------------------------------
------ 	UTILS START	 ---------------
------------------------------------
local function __UTILS__() end -- Used as marker for outliner. Remove when ready

---@param a actor
---@return boolean
function IsNaval(a)
	return Utils.Any({ "ca", "dd", "pt", "lst", "ss", "syrd", "spen" }, function(navalType)
		return a.Type == navalType
	end)
end

---@param action fun(actor: actor): boolean
---@return boolean
function CheckSecuredArea(action)
	local nw = WPos.New( (CPos.New(61, 19)).X * 1024,  (CPos.New(61, 19)).Y * 1024, 0)
    local se = WPos.New( (CPos.New(105, 103)).X * 1024, (CPos.New(105, 103)).Y * 1024, 0)
	
	local actors = Map.ActorsInBox( nw, se, function(a)
		return (a.Owner == Greece or a.Owner == England) and action(a)
    end)

	return #actors > 0
end

------------------------------------
------ 	UTILS END	 ---------------
------------------------------------

------------------------------------
------ 	ALERT START	 ---------------
------------------------------------
local function __ALERTS__() end -- Used as marker for outliner. Remove when ready

-- BadGuy AI can be initiated by:
-- - Dealing damage to any building (includes "brik")
-- - Player has land units or structures on the east side of the map
-- - X time has passed
-- - USSR player is defeated

function alert.AlertTurkey()
	if USSRTurkey then
		return
	end
	USSRTurkey = true

	EnemySubsReinforcements()
end

function alert.AlertUSSR()
	if USSRAlerted then
		return
	end
	USSRAlerted = true

	RunUSSRActivities()
end

function alert.AlertBadGuy()
	if BadGuyAlerted then
		return
	end
	BadGuyAlerted = true
	RunBadGuyActivities()
end

--- Create an imitation of the eastern land area's original zone footprint.
---@param action fun()
function alert.CreateZoneTriggers(action)
	local cells = { CPos.New(93, 96), CPos.New(103, 86), CPos.New(87, 69), CPos.New(97, 63), CPos.New(95, 48), CPos.New(102, 31) }
	local triggers = { }

	Utils.Do(cells, function(location)
		local id = Trigger.OnEnteredProximityTrigger(Map.CenterOfCell(location), WDist.FromCells(10), function(actor)
			if actor.Owner ~= Greece or not actor.HasProperty("Health") or actor.CenterPosition.Z > 0 or IsNaval(actor) then
				return
			end
			Utils.Do(triggers, Trigger.RemoveProximityTrigger)
			action()
		end)

		triggers[#triggers + 1] = id
	end)
end

--- Activate the east base once Allies attack it, land somewhere east of
--- the river that isn't on Turkey's beach, or do enough damage to USSR.
function alert.PrepareBadGuyAlerts()
	alert.CreateZoneTriggers(alert.AlertBadGuy)
	local eastBase = BadGuy.GetActorsByTypes({ "apwr", "fact", "fcom", "powr", "brik" })

	OnAnyDamaged(eastBase, function(_, attacker)
		if attacker.Owner.Faction == "soviet" then
			return
		end
		--Trigger.Clear(_, "OnDamaged") Could have conflicts with repairBuilding()
		alert.AlertBadGuy()
	end)

	local mainWestStructures = USSR.GetActorsByTypes({ "afld", "barr", "dome", "fact", "proc", "spen", "stek", "weap" })
	Utils.Do(mainWestStructures, function(structure)
		Trigger.OnKilledOrCaptured(structure, alert.AlertBadGuy)
	end)
end

function alert.TurkeyDefensiveCall()
	OnAnyDamaged(IslandDefenses, function(victim, attacker)
		alert.AlertTurkey()
		Trigger.Clear(victim, "OnDamaged")
	end)
end

function InitialSovietPatrols()
	local mmt_patrol = { mmth1, mmth2 }
	local path_patrol = {
	MammothPatrolWP1.Location, MammothPatrolWP2.Location, MammothPatrolWP3.Location,
	MammothPatrolWP4.Location, MammothPatrolWP5.Location, MammothPatrolWP6.Location,
	MammothPatrolWP7.Location, MammothPatrolWP8.Location, MammothPatrolWP9.Location,
	MammothPatrolWP10.Location }

	Utils.Do(mmt_patrol, function(t)
		mmth1.Patrol(path_patrol, true, DateTime.Seconds(12))
		mmth2.Patrol(path_patrol, true, DateTime.Seconds(12))
	end)

	OnAnyDamaged(mmt_patrol, function(victim, attacker)
		if victim.Health < victim.MaxHealth * 0.75 and attacker.Owner == Greece then
			Utils.Do(mmt_patrol, function(u)
				if not u.IsDead then
					u.Stance = "AttackAnything"
					u.Stop()
					Trigger.Clear(u, "OnDamaged")
					IdleHunt(u)
					alert.AlertUSSR()
				end
			end)
		end
	end)
end

function InitialSovietWarning()
	OnAnyDamaged(USSRBase, function(victim, attacker)
		if victim.Health < victim.MaxHealth * 0.75 and attacker.Owner == Greece then
			--Trigger.Clear(victim, "OnDamaged") Could have conflicts with repairBuilding()
			alert.AlertUSSR()
		end
	end)
end

function InitialAlliedReinforcements()
	if OnlyOneMCV == false then
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(Greece, "ReinforcementsArrived")
			Reinforcements.Reinforce(Greece, McvReinforcements1.actors, McvReinforcements1.entryPath)
		end)
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Reinforcements.Reinforce(Greece, McvReinforcements2.actors, McvReinforcements2.entryPath)
		end)
	else
		Reinforcements.Reinforce(Greece, McvReinforcements3.actors, McvReinforcements3.entryPath)
	end
end

function TimerExpiredSendNavy()
	if SentNavy then
		return
	end
	SentNavy = true
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Media.PlaySpeechNotification(Greece, "AlliedForcesApproaching")

		local seaLeftUnits = Reinforcements.Reinforce(England, EnglandLeftEarlyNavy.actors, EnglandLeftEarlyNavy.entryPath)
		Utils.Do(seaLeftUnits, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Patrol(SeaLeftPatrolPath, false, DateTime.Seconds(2))
			end)
			Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a)
				if a.Owner == England and a.Type == "dd" or a.Type == "pt" then
					a.Destroy()
				end
			end)
		end)

		local seaRightUnits = Reinforcements.Reinforce(England, EnglandRightEarlyNavy.actors, EnglandRightEarlyNavy.entryPath)
		Utils.Do(seaRightUnits, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Patrol(SeaRightPatrolPath, false, DateTime.Seconds(2))
			end)
			Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a)
				if a.Owner == England and a.Type == "dd" or a.Type == "pt" then
					a.Destroy()
				end
			end)
		end)

	end)
	Trigger.AfterDelay(DateTime.Seconds(10), TimerExpiredSendCruisers)
end

function TimerExpiredSendCruisers()
	if SentCruisers then
		return
	end
	SentCruisers = true
	Trigger.AfterDelay(DateTime.Seconds(8), function()
		local cruisers = {}

		Cruiser1.Owner = England
		table.insert(cruisers, Cruiser1)
		Cruiser1.MoveIntoWorld(EnglandLeftEntry.Location)
		Utils.Do(SeaLeftPatrolPath, function(wp)
			Trigger.OnAddedToWorld(Cruiser1, function()
				Cruiser1.Move(wp)
			end)
		end)
		Cruiser2.Owner = England
		table.insert(cruisers, Cruiser2)
		Cruiser2.MoveIntoWorld(EnglandRightEntry.Location)
		Utils.Do(SeaRightPatrolPath, function(wp)
			Trigger.OnAddedToWorld(Cruiser2, function()
				Cruiser2.Move(wp)
			end)
		end)

		Trigger.OnAnyKilled(cruisers, function()
			Media.PlaySpeechNotification(Greece, "AlliedForcesFallen")
			Trigger.AfterDelay(DateTime.Seconds(2), function()
				USSR.MarkCompletedObjective(USSRObj)
			end)
		end)

		local count = 0
		Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a, id)
			if a.Owner == England and a.Type =="ca" then
				count = count + 1
				a.Destroy()
				if count == 2 then
					Greece.MarkCompletedObjective(ClearNavalChannel)
					Trigger.RemoveFootprintTrigger(id)
				end
			end
		end)
	end)
end

function ForwardComDiscovery()
	Trigger.OnDiscovered(BGFcom, function(_, discoverer)
		if discoverer ~= Greece then
			return
		end

		if FcomDiscovered == true then
			return
		end
		FcomDiscovered = true
		DestroyCommandCenter = AddSecondaryObjective(Greece, "destroy-center-submarine-reinforcements")
	end)
end

-- Constant out of map attack if eastern Forward Command is not dead
function EnemySubsReinforcements()
    if BGFcom.IsDead then
		return
	end

	Media.DisplayMessage(UserInterface.GetFluentMessage("enemy-subs-alerted"), "Command")

	if CheckSecuredArea(IsNaval) then
		local leftSpawnPoint = EnglandLeftExit.Location
		local rightSpawnPoint = EnglandRightExit.Location

		Trigger.AfterDelay(DateTime.Seconds(1), function()
			local subsLeft = Reinforcements.Reinforce(USSR, {"ss", "ss"}, { leftSpawnPoint, leftSpawnPoint + CVec.New(0, 2) })
			local subsRight = Reinforcements.Reinforce(USSR, {"ss", "ss"}, { rightSpawnPoint, rightSpawnPoint + CVec.New(0, 2) })
			--This could be refactored
			Utils.Do(subsLeft, function(u)
				if not u.IsDead then
					IdleHunt(u)
				end
			end)
			Utils.Do(subsRight, function(u)
				if not u.IsDead then
					IdleHunt(u)
				end
			end)
		end)
	end

    Trigger.AfterDelay(DateTime.Minutes(3), function()
        EnemySubsReinforcements()
    end)
end

function FinishTimer()
   	DateTime.TimeLimit = 0
	for i = 0, 5, 1 do
		local c = TimerColor
		if i % 2 == 0 then
			c = HSLColor.White
		end
        Trigger.AfterDelay(DateTime.Seconds(i), function()
              UserInterface.SetMissionText(UserInterface.GetFluentMessage("the-navy-has-arrived"), c)
        end)
    end
	Trigger.AfterDelay(DateTime.Seconds(6), function() UserInterface.SetMissionText("") end)
end

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
local function __MAIN_TRIGGERS__() end -- Used as marker for outliner. Remove when ready

SetDifficulty = function()
	OnlyOneMCV = OnlyOneMCVCheck[Difficulty]
	StartingCash = StartingCashReserves[Difficulty]

	AlertUSSRDelay = AlertUSSRDelays[Difficulty]
end

InitTriggers = function()
	Greece.Cash = StartingCash

	InitialAlliedReinforcements()

	InitialSovietPatrols()
	InitialSovietWarning()

	alert.PrepareBadGuyAlerts()
	Trigger.AfterDelay(AlertUSSRDelay, function()
		alert.AlertUSSR()
	end)

	alert.TurkeyDefensiveCall()

	ForwardComDiscovery()

	Trigger.OnTimerExpired( function()
		TimerExpiredSendNavy()
		FinishTimer()
	end)
end

PrepareObjectives = function()
	InitObjectives(Greece)

	ClearNavalChannel = AddPrimaryObjective(Greece, "clear-the-naval-channel")

	USSRObj = AddPrimaryObjective(USSR, "Eliminate all Allied forces.")

	Trigger.OnPlayerLost(Greece, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(USSR, "MissionFailed")
		end)
	end)
	Trigger.OnPlayerWon(Greece, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(USSR, "MissionAccomplished")
		end)
	end)

	Trigger.OnKilledOrCaptured(BGFcom, function()
		-- Ensure an objective since it is possible to bypass the OnDiscovered.
		DestroyCommandCenter = DestroyCommandCenter or Greece.AddSecondaryObjective(UserInterface.GetFluentMessage("destroy-center-submarine-reinforcements"))
		Greece.MarkCompletedObjective(DestroyCommandCenter)
	end)
end

--------------------------------------------------------------------
--------------------------------------------------------------------
--------------------------------------------------------------------
local function __CORE_TRIGGERS__() end -- Used as marker for outliner. Remove when ready

Tick = function()
	if Greece.HasNoRequiredUnits() then
		USSR.MarkCompletedObjective(USSRObj)
	end

	if USSR.HasNoRequiredUnits() and BadGuy.HasNoRequiredUnits and Turkey.HasNoRequiredUnits() then
		if not TimeHasEnded then
			TimeHasEnded = true
			FinishTimer()
			TimerExpiredSendNavy()
		end
	end
	--UserInterface.SetMissionText("USSR: " .. tostring(USSR.Cash) .. " | " .. "BadGuy: " .. tostring(BadGuy.Cash)  )
end

WorldLoaded = function()
	Camera.Position = DefaultCameraPosition.CenterPosition

	Greece = Player.GetPlayer("Greece")
	USSR = Player.GetPlayer("USSR")
	BadGuy = Player.GetPlayer("BadGuy")
	Turkey = Player.GetPlayer("Turkey")
	England = Player.GetPlayer("England")
	Neutral = Player.GetPlayer("Neutral")

	SetDifficulty()
	InitTriggers()
	PrepareObjectives()

	SetupAIActivities()

	TimerColor = Player.GetPlayer("Greece").Color
	DateTime.TimeLimit = DateTime.Minutes(60) --60
end
