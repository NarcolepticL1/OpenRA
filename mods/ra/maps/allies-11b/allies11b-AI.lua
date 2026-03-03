--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]


local Util = {}
local Prod = {}
local Behav = {}
local BaseB = {}

local IsHarvesterMissing
local CheckPlayerMoney
local GrantCash
local ProducerAvailableCheck
local ProduceHarvester
local SelectLandAtkPaths
local SendUnits
local ProduceInfantry
local ProduceArmor
local OnAircraftStranded
local AreSovietPlanesActive
local HasAirfield
local ScheduleAirWave
local PrepareAircraftReinforcements
local ProduceSubmarines
local EnemySubsReinforcements
local ScatterBlockers
local IsBuildAreaBlocked
local PrepareBlueprintEdges
local MaintainBuilding
local OnBlueprintBuilt
local BuildBlueprint
local BuildBase
local BeginBaseMaintenance
local InsertBlueprints

DebugMsgEnabled = true

--For Debug
D = function(msg)
	if DebugMsgEnabled then
		Media.Debug(tostring(msg))
	end
end

local L = { }

------------------------------
--- Definitions Start --------
------------------------------

local USSRCashReserves = { easy = 100000, normal = 100000, hard = 100000, challenge = 100000 }
local BadGuyCashReserves = { easy = 100000, normal = 100000, hard = 100000, challenge = 100000 }

local AlertUSSRDelays = { easy = DateTime.Minutes(8), normal = DateTime.Minutes(6), hard = DateTime.Minutes(5), challenge = DateTime.Minutes(5) }

local AtkProductionIntervals = { easy = DateTime.Seconds(60), normal = DateTime.Seconds(40), hard = DateTime.Seconds(20), challenge = DateTime.Seconds(20) }

------------------------------
--- Definitions End	----------
------------------------------

--------------------------------------------------------------------
-----------------	    DATA BLOCK - START	------------------------
--------------------------------------------------------------------
local function ______DATA______() end

---@type blueprint[]
local USSRBaseBlueprints =
{
	{ type = "apwr", actor = USSRPower1, cost = 500, shape = { 3, 3 }, location = CPos.New(38, 38) },
	{ type = "apwr", actor = USSRPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(49, 39) },
	{ type = "apwr", actor = USSRPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(34, 43) },
	{ type = "apwr", actor = USSRPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(30, 44) },

    { type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(38, 32) },
    { type = "silo", actor = USSRSilo1, cost = 1400, shape = { 1, 1 }, location = CPos.New(47, 36) },
    { type = "silo", actor = USSRSilo2, cost = 1400, shape = { 1, 1 }, location = CPos.New(48, 35) },
	{ type = "silo", actor = USSRSilo2, cost = 1400, shape = { 1, 1 }, location = CPos.New(49, 36) },

    { type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(39, 42), owner = USSR, producer = true },
    { type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(45, 42), owner = USSR, producer = true },
    { type = "spen", actor = USSRSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(52, 30), owner = USSR, producer = true },

	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(50, 36) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(53, 41) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(51, 43) },
	{ type = "afld", actor = USSRAfld4, cost = 500, shape = { 3, 2 }, location = CPos.New(31, 48) },

    { type = "fix", actor = USSRFix, cost = 1000, shape = { 3, 3 }, location = CPos.New(41, 30) },
    { type = "dome", actor = USSRDome, cost = 1500, shape = { 2, 3 }, location = CPos.New(52, 38) },
    --[[{ type = "stek", actor = BadGuyStek, cost = 1500, shape = { 3, 3 }, location = CPos.New(107, 41) },]]

    { type = "ftur", actor = USSRFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(40, 49) },
    { type = "ftur", actor = USSRFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(45, 49) },
    { type = "tsla", actor = USSRTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(39, 48) },
    { type = "tsla", actor = USSRTsla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(46, 48) },

    { type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(40, 36) },
    { type = "sam", actor = USSRSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(48, 38) },
    { type = "sam", actor = USSRSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(37, 46) },
	{ type = "sam", actor = USSRSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(47, 47) }
}

---@type blueprint[]
local BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGPower1, cost = 500, shape = { 2, 3 }, location = CPos.New(102, 34) },
	{ type = "apwr", actor = BGPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(91, 30) }
}


local BGPower3, BGPower4, BGProc, BGBarr, BGWeap, BGSpen, BGAfld1, BGAfld2, BGAfld3, BGFtur1, BGFtur2, BGTsla1 =
nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
---@type blueprint[]
local BadGuyBaseExtraBlueprints =
{
    { type = "apwr", actor = BGPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(99, 33) },
	{ type = "apwr", actor = BGPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(91, 33) },

    { type = "proc", actor = BGProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(100, 36) },

    { type = "barr", actor = BGBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(97, 36) },
    { type = "weap", actor = BGWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(91, 37) },
    { type = "spen", actor = BGSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(80, 32) },

	{ type = "afld", actor = BGAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 30) },
	{ type = "afld", actor = BGAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 32) },
	{ type = "afld", actor = BGAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(87, 34) },

    { type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(95, 42) },
    { type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(99, 42) },
    { type = "tsla", actor = BGTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(97, 40) }
}

---@type blueprint[]
local TurkeyBaseBlueprints =
{
    -- Power outpost
	{ type = "apwr", actor = TurkPower1, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48)  }, 
	{ type = "apwr", actor = TurkPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower6, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) },
    -- Island
    { type = "tsla", actor = IslandTsla1, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla2, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla3, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla4, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla5, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "sam", actor = IslandSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam3, cost = 700, shape = { 2, 2 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }
}

-------------------------
-- Land Attacks Data   --
-------------------------

local VehicleAttackInterval = { easy = DateTime.Seconds(180), normal = DateTime.Minutes(150), hard = DateTime.Minutes(120), challenge = DateTime.Minutes(120)}

local USSRAttackPaths =
{
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP6.Location, Waypoint34.Location},
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP4.Location, Waypoint32.Location, Waypoint33.Location}
}
local BadGuyAttackPaths = { {BGAttackRallyWP.Location}}

local InfantryTypes = { "e1", "e2", "e4"}
local InfantryAttackGroup = { }
local InfantryAttackGroupSizes = { easy = 6, normal = 9, hard = 12, challenge = 12 }

---@type string[]
local VehicleTypes = { "3tnk", "3tnk", "3tnk", "v2rl", "v2rl", "4tnk" }
local VehicleAttackGroup = {}
local VehicleAttackGroupSizes = { easy = 2, normal = 3, hard = 4, challenge = 4} 

local VehicleUSSRAttackGroup = { }
local VehicleBadGuyAttackGroup = { }

InfantryUSSRAttackGroup = { }
InfantryBadGuyAttackGroup = { }

-------------------------
-- Naval Attacks Data  --
-------------------------

local SubTypes = { "ss"}
local SubAttackGroup = { }
local SubAttackGroupSize = 2
local NavalAtkPath = { }

-----------------------
-- Air Attacks Data  --
-----------------------

local CurrentAirWave = 1
local BasePlanes = {}
local TotalAflds = {}

local AircraftTypes = { "yak", "mig" }
local PlanesAttackGroup = { }

---@type { types: string[], interval: number, path: cpos[], owner?: player }[]
local SovietAirTeams = {
	{ types = { "yak" }, interval = DateTime.Seconds(120), path = { SovietAircraftOrigin1.Location }, owner = USSR},
	{ types = { "yak", "yak" }, interval = DateTime.Seconds(110), path = { SovietAircraftOrigin1.Location }},
	{ types = { "mig", "mig" }, interval = DateTime.Seconds(110), path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1.Location + CVec.New(-1, 0) }	},
	{ types = { "mig", "mig", "yak" }, interval = DateTime.Seconds(219),  path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1.Location + CVec.New(-1, 0) } },
	{ types = { "mig", "mig", "mig", "yak", "yak", "yak", "yak" }, interval = DateTime.Seconds(210), path = { SovietAircraftOrigin1.Location, SovietAircraftOrigin1	.Location + CVec.New(-1, 0) } }
}

--------------------------------------------------------------------
-----------------	    DATA BLOCK - END	------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	UTILS BLOCK - START	----------------------------
--------------------------------------------------------------------
local function ________________UTILS________________() end



---@param owner player
---@return boolean
function IsHarvesterMissing(owner)
	return #owner.GetActorsByType("harv") == 0 -- true / false
end

---@param owner player
---@return integer
function CheckPlayerMoney(owner)
	return owner.Cash + owner.Resources
end

---@param player player
---@param amount integer
function GrantCash(player, amount)
    player.Cash = player.Cash + amount
end

---@param producer actor
---@param owner player
function ProducerAvailableCheck(producer, owner)
	local type = producer.Type
	if #owner.GetActorsByType(type) > 0 then
		return true
	else
		return false
	end
end

---Issues an order to player to produce a harvester if there is enough cash
---@param producer actor
---@param owner player
---@param delay number
function ProduceHarvester(producer, owner, delay)
    if CheckPlayerMoney(owner) < Actor.Cost("harv") then
		return
	end
	local toBuild = { "harv" }
	owner.Build(toBuild, function()
		Trigger.AfterDelay(delay, function()
			ProduceArmor(producer, owner)
		end)
	end)
end

function SelectLandAtkPaths(owner)
    if owner == USSR then
        return USSRAttackPaths
    else
        return BadGuyAttackPaths
    end
end

--------------------------------------------------------------------
-----------------	UTILS BLOCK - END	----------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------	ATTACKING BLOCK - START	    --------------------
--------------------------------------------------------------------

local function ________________AI_ATTACKS________________() end

---@param units actor[]
---@param path cpos[]
function SendUnits(units, path)
	Utils.Do(units, function(unit)
		if unit.IsDead then
			return
		end

		unit.Patrol(path, false)
		IdleHunt(unit)
	end)
end

-------------[[ CHOOSE BETWEEN THIS TWO FUNCTIONS ( ProduceInfantry )]]
-----------------------
--- Inf Attacks     ---
-----------------------
local function ________________Infantry_Attacks________________() end

---@param producer actor
---@param owner player
function ProduceInfantry(producer, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(2), DateTime.Seconds(4))

    if not ProducerAvailableCheck(producer, owner) then
        return
	elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
        return
	end

    local toBuild = { Utils.Random(InfantryTypes) }
    local path = Utils.Random(SelectLandAtkPaths(owner))

	owner.Build(toBuild, function(units)
        if owner == USSR then
            table.insert(InfantryUSSRAttackGroup, units[1])
            if #InfantryUSSRAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryUSSRAttackGroup, path)
                InfantryUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceInfantry(producer, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(producer, owner)
			    end)
            end
        else
            table.insert(InfantryBadGuyAttackGroup, units[1])
            if #InfantryBadGuyAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryBadGuyAttackGroup, path)
                InfantryBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceInfantry(producer, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(producer, owner)
			    end)
            end
        end
	end)
end

-----------------------
--- Tank Attacks    ---
-----------------------
local function ________________Tank_Attacks________________() end

---@param producer actor
---@param owner player
function ProduceArmor(producer, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if not ProducerAvailableCheck(producer, owner) then
		return
	elseif IsHarvesterMissing(owner) then
        if owner == USSR or owner == BadGuy then
            ProduceHarvester(producer, owner, delay)
            return
        end
    end

	local toBuild = { Utils.Random(VehicleTypes) }
    local path = Utils.Random(SelectLandAtkPaths(owner))

	owner.Build(toBuild, function(units)
        if owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceArmor(producer, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(producer, owner)
                end)
            end
        elseif owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceArmor(producer, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(producer, owner)
                end)
            end
        end
    end)
end

-----------------------
--- Air Attacks    ----
-----------------------
local function ________________Air_Attacks________________() end

---@param owner player
function CountAflds(owner)
    TotalAflds = owner.GetActorsByType("afld")
end

--[[
ProduceAircraft = function()
    if not ProducerAvailableCheck(producer, owner) then
        return
    end

    USSR.Build(SovietAircraftType, function(units)
        local plane = units[1]
        PlanesAttackGroup[#PlanesAttackGroup + 1] = plane

        Trigger.OnKilled(plane, ProduceAircraft)

        local alive = Utils.Where(PlanesAttackGroup, function(p) return not p.IsDead end)
        if #alive < 2 then
            Trigger.AfterDelay(ProductionIntervalAir, ProduceAircraft)
        end

        InitializeAttackAircraft(plane, Greece)
    end)
end
]]

---@param aircraft actor
---@param exit cpos
function OnAircraftStranded(aircraft, exit)
	local oldOwner = aircraft.Owner

	if oldOwner == USSR and HasAirfield(BadGuy) then
		aircraft.Owner = BadGuy
	elseif oldOwner == BadGuy and HasAirfield(USSR) then
		aircraft.Owner = USSR
	end

	if oldOwner == aircraft.Owner then
		aircraft.Stop()
		aircraft.Move(exit)
		aircraft.Destroy()
	end
end

function AreSovietPlanesActive()
	local planes = { "mig", "yak" }
	return #USSR.GetActorsByTypes(planes) > 0
end

---@param player player
function HasAirfield(player)
	return player.HasPrerequisites({ "afld" })
end

---@param wave integer
function ScheduleAirWave(wave)
	local team = SovietAirTeams[wave]
    D("AirWave")
	if not team then
		team = SovietAirTeams[#SovietAirTeams] --Cpmstamt attacls vs finishing airWaves
		--return
	end
	Trigger.AfterDelay(team.interval, function()
		-- The last team was defeated before its scheduled repeat.
		if CurrentAirWave > wave then
			return
		end

		local units = Reinforcements.Reinforce(team.owner or USSR, team.types, team.path)
		ScheduleAirWave(wave)
		Utils.Do(units, function(unit)
			InitializeAttackAircraft(unit, Greece)

			Trigger.OnIdle(unit, function()
				if unit.AmmoCount() > 0 then
					table.insert(BasePlanes, unit)
					return
				elseif HasAirfield(unit.Owner) and #BasePlanes < #TotalAflds then
					return
				end
				OnAircraftStranded(unit, team.path[1])

			end)
		end)

		Trigger.OnAllRemovedFromWorld(units, function()
			if AreSovietPlanesActive() then
				return
			end

			--[[
			if team.onWaveDefeated then
				team.onWaveDefeated()
			end
			]]
			CurrentAirWave = CurrentAirWave + 1
			ScheduleAirWave(CurrentAirWave)
		end)
	end)
end

function PrepareAircraftReinforcements()
	local delay = DateTime.Seconds(10)--FirstAirDelays[Difficulty] or FirstAirDelays["normal"]

	Trigger.AfterDelay(delay, function()
		ScheduleAirWave(1)
	end)
end

-----------------------
--- Naval Attacks  ----
-----------------------
local function _______________Naval_Attacks_______________() end

function ProduceSubmarines(producer, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if not ProducerAvailableCheck(producer, owner) then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(producer, owner, delay)
        else
            return
        end
    end

    local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if producer.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
    owner.Build(toBuild, function(units)
        if producer.Owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceSubmarines(shipyard, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceSubmarines(shipyard, owner)
                end)
            end
        elseif shipyard.Owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceSubmarines(shipyard, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceSubmarines(shipyard, owner)
                end)
            end
        end
    end)
end

function EnemySubsReinforcements()
    local northLeftEdge = WPos.New( (CPos.New(62,18)).X * 1024,  (CPos.New(70,18)).Y * 1024, 0)
    local southRightEdge = WPos.New( (CPos.New(94,54)).X * 1024, (CPos.New(94,54)).Y * 1024, 0)

    local actors = Map.ActorsInBox( northLeftEdge, southRightEdge, function(actor)
		return actor.Owner == Greece and ( actor.Type == "pt" or actor.Type == "dd" or actor.Type == "ca" or actor.Type == "ss" or actor.Type == "spen" or actor.Type == "syrd" or actor.Type == "lst" )
	end)

    if #actors > 0 then
        local subs = Reinforcements.Reinforce(USSR, {"ss", "ss", "ss"}, { SovWaterEntry.Location, SovWaterEntry.Location + CVec.New(0, 2) })
        Utils.Do(subs, function(u)
            if not u.IsDead then
                u.AttackMove(SovWaterWaypoint.Location)
                IdleHunt(u)
            end
        end)
    end

    Trigger.AfterDelay(DateTime.Minutes(2), function()
        EnemySubsReinforcements()
    end)
end

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function ______________BASE_MANAGEMENT______________() end

---@param blueprints blueprint[]
---@param cyard any
---@param owner player
function BuildBase(blueprints, cyard, owner)
	for _, blueprint in ipairs(blueprints) do
		if not blueprint.actor then
            BuildBlueprint(blueprints, blueprint, cyard, owner)
			return
		end
	end
	Trigger.AfterDelay(DateTime.Seconds(10), function()
        BuildBase(blueprints, cyard, owner)
	end)
end

---@param blueprints blueprint[]
---@param blueprint blueprint
---@param cyard actor
---@param owner player
function BuildBlueprint(blueprints, blueprint, cyard, owner)
    Trigger.AfterDelay(1--[[Actor.BuildTime(blueprint.type)]], function()
		if cyard.IsDead or cyard.Owner ~= owner then
			return
        --[[
		elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing() then
            return    ]]
		end

		if IsBuildAreaBlocked(owner, blueprint) then
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				BuildBlueprint(blueprints, blueprint, cyard, owner)
			end)
			return
		end

		local actor = Actor.Create(blueprint.type, true, { Owner = owner, Location = blueprint.location })
		OnBlueprintBuilt(actor, blueprint, owner)
		Trigger.AfterDelay(DateTime.Seconds(10), function()
			D(blueprints[#blueprints].type)
            BuildBase(blueprints, cyard, owner)
		end)
	end)
end

---@param actor actor
---@param blueprint blueprint
---@param owner player
function OnBlueprintBuilt(actor, blueprint, owner)
	owner.Cash = owner.Cash - blueprint.cost
	blueprint.actor = actor
	MaintainBuilding(actor, blueprint, 0.75)

    if blueprint.type ~= "barr" and blueprint.type ~= "weap" and blueprint.type ~= "afld" and blueprint.type ~= "spen" then
        return
    end

    Trigger.AfterDelay(1, function()
		if blueprint.type == "barr" then
            ProduceInfantry(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceArmor(actor, owner)
		elseif blueprint.type == "weap" then
            --ProduceAircraft(actor, owner)
		elseif blueprint.type == "weap" then
            --ProduceSubs(actor, owner)
		end
    end)
end

---@param blueprint blueprint
---@param owner player
function IsBuildAreaBlocked(owner, blueprint)
	local nw = blueprint.northwestEdge --[[@as wpos]]
	local se = blueprint.southeastEdge --[[@as wpos]]
	local blockers = Map.ActorsInBox(nw, se, function(actor)
		-- Neutral check is for ignoring trees near the refinery.
		return actor.Owner ~= Neutral and actor.CenterPosition.Z == 0 and actor.HasProperty("Health")
	end)

	if #blockers == 0 then
		return false
	end

	ScatterBlockers(blockers, owner)
	return true
end

---@param actors actor[]
---@param owner player
function ScatterBlockers(actors, owner)
	Utils.Do(actors, function(a)
		if a.IsIdle and a.Owner == owner and a.HasProperty("Scatter") then
			a.Scatter()
		end
	end)
end

---@param blueprint blueprint
function PrepareBlueprintEdges(blueprint)
	local shapeX, shapeY = blueprint.shape[1], blueprint.shape[2]
	local northwestEdge = Map.CenterOfCell(blueprint.location) + WVec.New(-512, -512, 0)
	local southeastEdge = northwestEdge + WVec.New(shapeX * 1024, shapeY * 1024, 0)
	blueprint.northwestEdge = northwestEdge
	blueprint.southeastEdge = southeastEdge
end

---@param blueprints blueprint[]
---@param owner player
function BeginBaseMaintenance(blueprints, owner)
	Utils.Do(blueprints, function(blueprint)
        MaintainBuilding(blueprint.actor, blueprint, 0.75)
	end)
	Utils.Do(owner.GetActors(), function(actor)
		if actor.HasProperty("StartBuildingRepairs") then
			MaintainBuilding(actor, nil, 0.75)
		end
	end)
end

---@param actor actor
---@param blueprint? blueprint
---@param repairThreshold number
function MaintainBuilding(actor, blueprint, repairThreshold)
	if blueprint then
		Trigger.OnKilled(actor, function() blueprint.actor = nil end)
		Trigger.OnSold(actor, function() blueprint.actor = nil end)
		if not blueprint.northwestEdge then
			PrepareBlueprintEdges(blueprint)
		end
	end

	if repairThreshold then
		local original = actor.Owner

		Trigger.OnDamaged(actor, function()
			if actor.Owner ~= original or actor.Health > actor.MaxHealth * repairThreshold then
				return
			end

			actor.StartBuildingRepairs()
		end)
	end
end

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - END 	----------------
--------------------------------------------------------------------


---
--- Add utils here
---

--Insert blueprints[] to player base building blueprints[]
---@param blueprints blueprint[]
---@param insert blueprint[]
function InsertBlueprints(blueprints, insert)
    Utils.Do(insert, function(b)
        local index = #blueprints
		table.insert(blueprints, index, b)
        PrepareBlueprintEdges(b)
    end)
end


--------------------------------------------------------------------
----------------	AI ATTACKING BLOCK - END        ----------------
--------------------------------------------------------------------
local function ______________AI_SETUP______________() end

-- Activated once USSR is alerted
function RunUSSRActivities()
	
    ProduceInfantry(USSRBarr, USSR)
	--ProduceSubs(USSRSpen, USSR)

	Trigger.AfterDelay(DateTime.Minutes(2), function()
		ProduceArmor(USSRWeap, USSR)
	end)
end

function SetupAIActivities()

    CountAflds(USSR)
    D(TotalAflds)

    USSRCashReserve = USSRCashReserves[Difficulty]
    BadGuyCashReserve = BadGuyCashReserves[Difficulty]

    USSR.Cash = USSRCashReserve
    BadGuy.Cash = BadGuyCashReserve

    AtkProductionInterval = AtkProductionIntervals[Difficulty]

    InfantryAttackGroupSize = InfantryAttackGroupSizes[Difficulty]
    VehicleAttackGroupSize = VehicleAttackGroupSizes[Difficulty]
    -- For repairs

    --Maybe this one is not necessary
    AlertUSSRDelay = AlertUSSRDelays[Difficulty]

    BeginBaseMaintenance(USSRBaseBlueprints, USSR)
    BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

    BuildBase(USSRBaseBlueprints, USSRFact, USSR)

    RunUSSRActivities()

    Trigger.AfterDelay(DateTime.Minutes(4), function()
		--EnemySubsReinforcements()
	end)

    Trigger.AfterDelay(DateTime.Seconds(2), function()
		PrepareAircraftReinforcements()
	end)
end

-- Activated once BadGuy is alerted
function RunBadGuyActivities()
    InsertBlueprints(BadGuyBaseBlueprints, BadGuyBaseExtraBlueprints)
    BuildBase(BadGuyBaseBlueprints, BadGuyFact, BadGuy)
end
