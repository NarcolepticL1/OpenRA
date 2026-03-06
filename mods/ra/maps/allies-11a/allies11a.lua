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
APPROACH
First of all I tried to stick to the original level spirit more than copying verbatim triggers/events. Working on top of @yuantse and @JovialFeline code

ORIGINAL VS ORA VERSION
Again the redeployable MCV changes a few things. At the start of the level the player starts with 2 mcvs. I want to change this a bit (See BALANCE).

BALANCE
First of all the second MCV the player has would only be available on EASY. In Normal the MCV will arrive after X time. In HARD there will be no extra
MCV. If the player wants to secure the right side, he/she must migrate there with the only MCV. 
The closest soviet base doesn't have sams so aircrafts can do quick work of it. I think is better to give the AI (USSR) sams but these will be built after
X time. The X amount will depend on difficulty, so, if the player is quick enough, he/she can weaken the soviet enough so they become less of a threat.


MCV-Deploy
Aircrafts
Spy
PowerPlants and island fortification 


As mentioned before, AI will send attacks occasionally but the bulk of the AI efforts will be in protecting the base and other behaviors that make it hard
for the VIP unit to leave the base. Among these changes

OTHER
No secondary objective yet


TL;DR
- Change dog locations, add a way for AI to rebuild them to defend against spies
- Change top power plants and island fortifications to new player (not USSR and not BadGuy)
]]

local alert = {}

local IsNaval
local AlertUSSR
local AlertBadGuy
local CreateZoneTriggers
local PrepareBadGuyAlerts

local InitialSovietPatrols
local InitialSovietWarning

local InitialAlliedReinforcements

local TimerExpiredSendCruisers
local TimerExpiredSendNavy

local ForwardComDiscovery

---------------------------------------

local StartingCashReserves = { easy = 7000, normal = 6000, hard = 5000, challenge = 5000 }

local OnlyOneMCV = { easy = false, normal = false, hard = true, challenge = true }

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

-- Remove
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

local BadGuyAlerted = false
local USSRAlerted = false

local FcomDiscovered = false

---@param a actor
---@return boolean
function IsNaval(a)
	return Utils.Any({ "ca", "dd", "lst", "pt", "ss" }, function(shipType)
		return a.Type == shipType
	end)
end

------------------------------------
------ 	ALERT START	 ---------------
------------------------------------
local function __ALERTS__() end -- Used as marker for outliner. Remove when ready

-- BadGuy AI can be initiated by:
-- - Dealing damage to any building (includes "brik")
-- - Player has land units or structures on the east side of the map
-- - X time has passed
-- - USSR player is defeated

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
		alert.AlertBadGuy()
	end)

	local mainWestStructures = USSR.GetActorsByTypes({ "afld", "barr", "dome", "fact", "proc", "spen", "stek", "weap" })
	Utils.Do(mainWestStructures, function(structure)
		Trigger.OnKilledOrCaptured(structure, alert.AlertBadGuy)
	end)
end

function InitialSovietPatrols()
	local mmt_patrol = { mmth1, mmth2 }
	local path_patrol = {
	MammothPatrolWP1.Location, MammothPatrolWP2.Location, MammothPatrolWP3.Location,
	MammothPatrolWP4.Location, MammothPatrolWP5.Location, MammothPatrolWP6.Location,
	MammothPatrolWP7.Location, MammothPatrolWP8.Location, MammothPatrolWP9.Location, 
	MammothPatrolWP10.Location
}

	Utils.Do(mmt_patrol, function(t)
		mmth1.Patrol(path_patrol, true, DateTime.Seconds(12))
		mmth2.Patrol(path_patrol, true, DateTime.Seconds(12))
	end)

	OnAnyDamaged(mmt_patrol, function(victim, attacker)
		if victim.Health < victim.MaxHealth * 0.75 and attacker.Owner == Greece then
			victim.Stance = "AttackAnything"
			--Trigger.ClearAll(victim)
			alert.AlertUSSR()
		end
	end)
end

function InitialSovietWarning()
	OnAnyDamaged(USSRBase, function(victim, attacker)
		if victim.Health < victim.MaxHealth * 0.75 and attacker.Owner == Greece then
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

function TimerExpiredSendCruisers()
	if SentCruisers then
		return
	end
	SentCruisers = true
	Trigger.AfterDelay(DateTime.Seconds(10), function()
		local left_ca = Reinforcements.Reinforce(England, EnglandLeftLateNavy.actors, EnglandLeftLateNavy.entryPath)[1]
		Utils.Do(SeaLeftPatrolPath, function(wp)
			Trigger.OnAddedToWorld(left_ca, function()
				left_ca.Move(wp)
			end)
			Trigger.OnKilled(left_ca, function()
				Media.PlaySpeechNotification(Greece, "AlliedForcesFallen")
				USSR.MarkCompletedObjective(USSRObj)
			end)
		end)
		local right_ca = Reinforcements.Reinforce(England, EnglandRightLateNavy.actors, EnglandRightLateNavy.entryPath)[1]
		Utils.Do(SeaRightPatrolPath, function(wp)
			Trigger.OnAddedToWorld(right_ca, function()
				right_ca.Move(wp)
			end)
			Trigger.OnKilled(right_ca, function()
				Media.PlaySpeechNotification(Greece, "AlliedForcesFallen")
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

function TimerExpiredSendNavy()
	if SentNavy then
		return
	end
	SentNavy = true
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Media.PlaySpeechNotification(Greece, "AlliedForcesApproaching")
		local sea1Units = Reinforcements.Reinforce(England, EnglandLeftEarlyNavy.actors, EnglandLeftEarlyNavy.entryPath)
		Utils.Do(sea1Units, function(a)
			Trigger.OnAddedToWorld(a, function()
				a.Patrol(SeaLeftPatrolPath, false, DateTime.Seconds(2))
			end)
			Trigger.OnEnteredFootprint(EdgeOfRiverTriggerActivator, function(a)
				if a.Owner == England and a.Type == "dd" or a.Type == "pt" then
					a.Destroy()
				end
			end)
		end)
		local sea2Units = Reinforcements.Reinforce(England, EnglandRightEarlyNavy.actors, EnglandRightEarlyNavy.entryPath)
		Utils.Do(sea2Units, function(a)
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

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
local function __MAIN_TRIGGERS__() end -- Used as marker for outliner. Remove when ready

InitTriggers = function()
	Greece.Cash = StartingCashReserves[Difficulty]

	InitialAlliedReinforcements()

	InitialSovietPatrols()
	InitialSovietWarning()

	--alert.PrepareBadGuyAlerts()
	--Trigger.AfterDelay(AlertUSSRDelay, function()
		--alert.AlertUSSR()
	--end)

	ForwardComDiscovery()

	Trigger.OnTimerExpired(TimerExpiredSendNavy)
end

PrepareObjectives = function()
	InitObjectives(Greece)

	ClearNavalChannel = AddPrimaryObjective(Greece, "clear-the-naval-channel")

	DenyAllies = AddPrimaryObjective(USSR, "Eliminate all Allied forces.")

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
end

WorldLoaded = function()
	Camera.Position = DefaultCameraPosition.CenterPosition

	Greece = Player.GetPlayer("Greece")
	USSR = Player.GetPlayer("USSR")
	BadGuy = Player.GetPlayer("BadGuy")
	Turkey = Player.GetPlayer("Turkey")
	England = Player.GetPlayer("England")
	Neutral = Player.GetPlayer("Neutral")

	InitTriggers()
	--PrepareObjectives()

	SetupAIActivities()
	--CheckBeachGuardVacancy()
	--D(BeachGuardPositions[1].location)
	--D(BeachGuardPositions[2].location)
	--D(BeachGuardPositions[3].location)
	--D(BeachGuardPositions[4].location)
	--D(Actor328.Location)


	DateTime.TimeLimit = DateTime.Minutes(60)
end
