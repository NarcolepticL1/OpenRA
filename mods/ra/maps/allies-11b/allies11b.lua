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
- Change dog locations, add a way for AI to rebuild (no inf queue usage) them to defend against spies
- Change top power plants and island fortifications to new player (not USSR and not BadGuy)
]]

--This function is to allow usage of outliner. Remove at some point
local function __DATA__() end

local alert = {}

local IsNaval
local CheckSecuredArea

local AlertUSSR
local AlertBadGuy
local AlertTurkey

local CreateZoneTriggers
local PrepareBadGuyAlerts
local TurkeyDefensiveCall

local InitialSovietPatrols
local InitialSovietWarning

local InitialAlliedReinforcements

local SendRevengeSub
local PrepareMammothPatrol
local OnMammothsDead

local PrepareMainSubmarines
local GroupHuntOnDamaged
local OrderBlockers

local ForwardComDiscovery
local EnemySubsReinforcements

DebugMsgEnabled = false

--For Debug
D = function(msg)
	if DebugMsgEnabled then
		Media.Debug(tostring(msg))
	end
end

---------------------------------------

local OnlyOneMCVCheck = { easy = false, normal = false, hard = true, challenge = true }
local OnlyOneMCV

local StartingCashReserves = { easy = 7000, normal = 6000, hard = 5000, challenge = 5000 }
local StartingCash

local AlertUSSRDelays = { easy = DateTime.Minutes(4), normal = DateTime.Minutes(3), hard = DateTime.Minutes(2), challenge = DateTime.Minutes(2) }
local AlertUSSRDelay

local TimeLimits = { easy = DateTime.Minutes(80), normal = DateTime.Minutes(60), hard = DateTime.Minutes(50), challenge = DateTime.Minutes(50) }
local TimeLimit

local ReinforceSubAmounts = { easy = {"ss"}, normal = {"ss"}, hard = {"ss", "ss"}, challenge = {"ss", "ss"} }
local ReinforceSubAmount

---------------------------------------

local EastArea = {
	{ nw = CPos.New(85, 29), se = CPos.New(104, 75) },
	{ nw = CPos.New(76, 77), se = CPos.New(104, 102) }
}

local RiverArea = { nw = CPos.New(51, 17), se = CPos.New(95, 102) }
local BridgeArea = { nw = CPos.New(61, 49), se = CPos.New(73, 57) }

local McvReinforcements1 = { actors = { "mcv" }, entryPath = { MCVEntry1.Location, MCVDst1.Location } }
local McvReinforcements2 = { actors = { "mcv" }, entryPath = { MCVEntry2.Location, MCVDst2.Location } }
local McvReinforcements3 = { actors = { "mcv" }, entryPath = { MCVEntry3.Location, MCVDst3.Location } }

local EnglandLeftEarlyNavy = { actors = { "pt", "pt", "dd", "dd" }, entryPath = { EnglandLeftEntry.Location } }
local EnglandRightEarlyNavy = { actors = { "pt", "pt", "dd", "dd" }, entryPath = { EnglandRightEntry.Location } }

---@type cpos[]
local SeaLeftPatrolPath = {
EnglandLeftEntry.Location, EnglandLeftWP1.Location, EnglandLeftWP2.Location,
EnglandLeftWP3.Location, EnglandLeftWP4.Location, EnglandLeftWP5.Location,
EnglandLeftWP6.Location, EnglandLeftDst.Location
}

---@type cpos[]
local SeaRightPatrolPath = {
EnglandRightEntry.Location, EnglandRightWP1.Location, EnglandRightWP2.Location,
EnglandRightWP3.Location, EnglandRightWP4.Location, EnglandRightWP5.Location, 
EnglandRightWP6.Location, EnglandRightDst.Location
}

EdgeOfRiverTriggerActivator = {
	CPos.New(63, 17), CPos.New(64, 17), CPos.New(65, 17), CPos.New(66, 17), CPos.New(67, 17), CPos.New(68, 17), CPos.New(69, 17), CPos.New(70, 17),
	CPos.New(71, 17), CPos.New(72, 17), CPos.New(73, 17), CPos.New(74, 17), CPos.New(75, 17), CPos.New(76, 17), CPos.New(77, 17), CPos.New(78, 17),
	CPos.New(63, 18), CPos.New(64, 18), CPos.New(65, 18), CPos.New(66, 18), CPos.New(67, 18), CPos.New(68, 18), CPos.New(69, 18), CPos.New(70, 18),
	CPos.New(71, 18), CPos.New(72, 18), CPos.New(73, 18), CPos.New(74, 18), CPos.New(75, 18), CPos.New(76, 18), CPos.New(77, 18), CPos.New(78, 18),
}

local USSRBase = { USSRFact, USSRPower1, USSRPower2, USSRPower3, USSRPower4, USSRBarr, USSRWeap, USSRSpen, USSRProc, USSRSilo1, USSRSilo2, USSRSilo3, USSRDome, USSRAfld1, USSRAfld2, USSRAfld3, USSRFix, USSRFtur1, USSRFtur2, USSRTsla1, USSRTsla2, USSRSam1, USSRSam2, USSRSam3, USSRSam4
}

local IslandDefenses =
	{IslandTsla1, IslandTsla2, IslandTsla3, IslandTsla4, IslandTsla5, IslandSam1, IslandSam2, IslandSam3, IslandSam4,
	IslandSub1, IslandSub2, IslandSub3, IslandSub4, IslandSub5, IslandSub6, IslandSub7
}

local SentNavy = false
local SentCruisers = false

local TimeHasEnded = false

local USSRAlerted = false
local BadGuyAlerted = false
local TurkeyAlerted = false

local FcomDiscovered = false

---@type integer|nil Delayed objective to destroy the Forward Command.
local DestroyForwardCommand

------------------------------------
------ 	UTILS START	 ---------------
------------------------------------
local function __UTILS__() end -- Used as marker for outliner. Remove when read

---@param a actor
---@return boolean
function IsNaval(a)
	return Utils.Any({ "ca", "dd", "pt", "lst", "ss", "syrd", "spen" }, function(navalType)
		return a.Type == navalType
	end)
end

---@param NW cpos
---@param SE cpos
---@param action fun(actor: actor): boolean
---@return boolean
function CheckSecuredArea( NW, SE, action)
	local nw = WPos.New( NW.X * 1024, NW.Y * 1024, 0)
    local se = WPos.New( SE.X * 1024, SE.Y * 1024, 0)

	local actors = Map.ActorsInBox( nw, se, function(a)
		return (a.Owner == Greece or a.Owner == England) and action(a)
    end)

	return #actors > 0
end

--[[
--@return boolean
AreIslandTeslasDown = function()
	local teslas = { IslandTsla1, IslandTsla2, IslandTsla3, IslandTsla4, IslandTsla5 }

	return Turkey.PowerState ~= "Normal" or Utils.All(teslas, function(a)
		return a.IsDead
	end)
end
]]
------------------------------------
------ 	UTILS END	 ---------------
------------------------------------

------------------------------------
------ 	ALERT START	 ---------------
------------------------------------
local function __ALERTS__() end
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
	D("Alert USSR")
	RunUSSRActivities()
end

function alert.AlertBadGuy()
	if BadGuyAlerted then
		return
	end
	BadGuyAlerted = true
	D("Alert BadGuy")
	RunBadGuyActivities()
end

function alert.AlertTurkey()
	if TurkeyAlerted then
		return
	end
	TurkeyAlerted = true
	D("Alert Turkey")
	EnemySubsReinforcements()
end

--- Create an imitation of the eastern land area's original zone footprint.
---@param action fun()
function alert.CreateZoneTriggers(action)
	local cells = { CPos.New(93, 36), CPos.New(102, 50), CPos.New(99, 63), CPos.New(99, 81), CPos.New(86, 91), CPos.New(99, 101) }
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
--- the river tyhat isn't on Turkey's beach, or do enough damage to USSR.
function alert.PrepareBadGuyAlerts()
	alert.CreateZoneTriggers(alert.AlertBadGuy)
	local eastBase = BadGuy.GetActorsByTypes({ "apwr", "fact", "fcom", "powr", "brik" })

	OnAnyDamaged(eastBase, function(_, attacker)
		if attacker.Owner.Faction == "soviet" then
			return
		end

		alert.AlertBadGuy()
	end)

	-- RA '96 behavior: wait until USSR is wiped out, including all submarines.
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

--------------------------------------------------------------------
----------------	ROAD PATROLS - START        --------------------
--------------------------------------------------------------------
local function __OTHER__() end

function PrepareMainSubmarines()
	local subs = Utils.Where(USSR.GetActorsByType("ss"), function(sub)
		return not sub.HasTag("Area Guard")
	end)

	Utils.Do(subs, function(sub)
		Trigger.OnDamaged(sub, function(self, attacker)
			if self.Owner.Faction == attacker.Owner.Faction then
				return
			end

			Trigger.Clear(sub, "OnDamaged")
			IdleHunt(sub)
		end)
	end)

	local islandSubs = { IslandSub1, IslandSub2, IslandSub3, IslandSub4, IslandSub5, IslandSub6, IslandSub7 }
	-- Trigger.OnAnyKilled(islandSubs, SendRevengeSub)
end

--------------------------------------------------------------------
----------------	ROAD PATROLS - END        --------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------	ROAD PATROLS - START        --------------------
--------------------------------------------------------------------
local function __ROAD_PATROLS__() end

---@param actors actor[]
function GroupHuntOnDamaged(actors)
	local alerted = false

	Utils.Do(actors, function(victim)
		Trigger.OnDamaged(victim, function(_, attacker)
			if alerted or attacker.Owner.Faction == "soviet" then
				return
			end
			alerted = true

			Utils.Do(actors, function(hunter)
				if hunter.IsDead or not hunter.HasProperty("Hunt") then
					return
				end

				-- Halt any patrols this group might have.
				hunter.Stop()
				hunter.RemoveTag("Area Guard")
				Trigger.Clear(hunter, "OnIdle")

				Trigger.AfterDelay(1, function()
					IdleHunt(hunter)
				end)
			end)
		end)
	end)
end

---@param actors actor[]
---@param rally? cpos
function OrderBlockers(actors, rally)
	Utils.Do(actors, function(a)
		if not rally then
			IdleHunt(a)
			return
		end

		a.AddTag("Area Guard")
		a.AttackMove(rally, 2)
	end)

	if rally then
		-- Possible TODO: add real Area Guard behavior ala The Tiberium Strain.
		-- There may be little benefit here since it's not a no-build, and ORA
		-- infantry have weapon range that roughly covers original guard range.
		-- Something for the lone base dog would be nice for spy guarding.
		GroupHuntOnDamaged(actors)
	end
end

function CheckBridgeStatus()
	local NW = WPos.New(BridgeArea.nw.X * 1024, BridgeArea.nw.Y * 1024, 0)
	local SE = WPos.New(BridgeArea.se.X * 1024, BridgeArea.se.Y * 1024, 0)
	
	local bridges = Map.ActorsInBox(NW, SE, function(actors)
		return actors.Type == "br3" or actors.Type == "br2" or actors.Type == "br1"
	end)
	--[[
	local destroyableBridges = Utils.Shuffle(bridges)

	for i = 1, #destroyableBridges do
		Trigger.AfterDelay(2*i, destroyableBridges[i].Kill)	
	end
	]]
end




--[[
---@param types string[]
---@return actor[]|nil
local function RecruitBlockers(types)
	local blockers = { }
	local typesDone = { }
	local success = true

	local pool = Utils.Where(USSR.GetGroundAttackers(), function(a)
		return a.IsIdle and not a.HasTag("Area Guard") end)

	Utils.Do(types, function(type)
		if not success or typesDone[type] then
			return
		end
		typesDone[type] = true

		-- "The request is 'apc, v2rl, e1, e1, e2'. How many e1 are needed?"
		local quota = #Utils.Where(types, function(t)
			return type == t end)

		local matches = Utils.Where(pool, function(p)
			return type == p.Type end)

		if #matches < quota then
			success = false
			return
		end

		blockers = Utils.Concat(blockers, Utils.Take(quota, matches))
	end)

	if success then
		return blockers
	end

	return nil
end

---@param types string[]
---@param producer actor
---@param rally? cpos
local function BuildBlockers(types, producer, rally)
	if producer.IsDead and #USSR.GetActorsByType(producer.Type) == 0 then
		return
	end

	USSR.Build(types, function(actors)
		OrderBlockers(actors, rally)
	end)
end
]]
--- Continue sending Submarine hunters once an island Submarine first dies.
function SendRevengeSub()
	local idleSubs = Utils.Where(USSR.GetActorsByType("ss"), function(a)
		return a.IsIdle and not a.HasTag("Area Guard") end)

	if #idleSubs == 0 then
		return
	end

	local sub = idleSubs[1]
	IdleHunt(sub)
	Trigger.OnKilled(sub, SendRevengeSub)
end

-- Check patrol behavior to fit the "Area Guard" idea
function InitialSovietPatrols()

	local mmt_patrol = { StartMammoth1, StartMammoth2 }
	local path_patrol = {
		MammothPatrolWP1.Location, MammothPatrolWP2.Location, MammothPatrolWP3.Location, MammothPatrolWP4.Location,
		MammothPatrolWP5.Location, MammothPatrolWP6.Location, MammothPatrolWP7.Location, MammothPatrolWP8.Location,
		MammothPatrolWP9.Location
	}

	Utils.Do(mmt_patrol, function(t)
		t.Patrol(path_patrol, true, DateTime.Seconds(12))
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

--- Recruit/build teams to guard the road to the USSR base.
--- Based on triggers blok and blk1 through blk3.
function OnMammothsDead()
	local teams =
	{
		{ types = { "3tnk", "v2rl" }, 				rally = MammothPatrolWP1.Location, 	producer = USSRWarFactory },
		{ types = { "e2", "e2", "e2", "e4", "e4" }, rally = MammothPatrolWP9.Location, 	producer = USSRBarracks },
		{ types = { "3tnk", "3tnk" }, 				rally = MammothPatrolWP6.Location, 	producer = USSRWarFactory },
		{ types = { "4tnk" }, 						rally = MammothPatrolWP7.Location, 	producer = USSRWarFactory },
		{ types = { "e4", "e4", "e4", "e4", "e4" }, 									producer = USSRBarracks}
	}

	local delay = 0
	Utils.Do(teams, function(team)
		Trigger.AfterDelay(delay, function()
			local units = RecruitBlockers(team.types)

			if not units then
				BuildBlockers(team.types, team.producer, team.rally)
				return
			end

			OrderBlockers(units, team.rally)
		end)

		delay = delay + 5
	end)
end

function InitialAlliedReinforcements()
	if OnlyOneMCV == false then
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Media.PlaySpeechNotification(Greece, "ReinforcementsArrived")
			Reinforcements.Reinforce(Greece, McvReinforcements1.actors, McvReinforcements1.entryPath)
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

	if CheckSecuredArea( RiverArea.nw, RiverArea.se, IsNaval) then
		local leftSpawnPoint = EnglandLeftDst.Location
		local rightSpawnPoint = EnglandRightDst.Location

		Trigger.AfterDelay(DateTime.Seconds(1), function()
			local subsLeft = Reinforcements.Reinforce(USSR, ReinforceSubAmount, { leftSpawnPoint, leftSpawnPoint + CVec.New(0, 2) })
			local subsRight = Reinforcements.Reinforce(USSR, ReinforceSubAmount, { rightSpawnPoint, rightSpawnPoint + CVec.New(0, 2) })
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
----------------	ROAD PATROLS - END        --------------------
------------------------------------------------------------------
local function __BASE_TRIGGERS__() end

SetDifficulty = function()
	OnlyOneMCV = OnlyOneMCVCheck[Difficulty]

	TimeLimit = TimeLimits[Difficulty]
	StartingCash = StartingCashReserves[Difficulty]

	AlertUSSRDelay = AlertUSSRDelays[Difficulty]
	ReinforceSubAmount = ReinforceSubAmounts[Difficulty]
end

InitTriggers = function()
	Greece.Cash = StartingCash

	InitialAlliedReinforcements()

	InitialSovietPatrols()
	InitialSovietWarning()

	alert.TurkeyDefensiveCall()

	ForwardComDiscovery()

	alert.PrepareBadGuyAlerts()
	Trigger.AfterDelay(AlertUSSRDelay, function()
		alert.AlertUSSR()
	end)

	Trigger.OnTimerExpired(TimerExpiredSendNavy)

	Trigger.AfterDelay(DateTime.Seconds(30), CheckBridgeStatus)

end

PrepareObjectives = function()
	InitObjectives(Greece)

	ClearNavalChannel = Greece.AddObjective("Clear the naval channel.")

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
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		DateTime.TimeLimit = TimeLimit
	end)
end
