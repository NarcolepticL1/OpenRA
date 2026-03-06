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
local Base = {}

local IsHarvesterMissing
local CheckPlayerMoney
local GrantCash
local InsertBlueprints
local ProducerTypeAvailableCheck
local ProduceHarvester
local SelectLandAtkPaths

-- Could be moved to its own list "local base = {}"
local BuildBase
local BuildBlueprint
local OnBlueprintBuilt
local IsBuildAreaBlocked
local ScatterBlockers
local PrepareBlueprintEdges
local BeginBaseMaintenance
local MaintainBuilding
---
local SetCombatRole
local CheckBeachGuardVacancy
local SendUnits
---
local ProduceInfantry
---
local ProduceArmor
local CreateCombatGroup
local SetGuardPoint
local TransportGroup
local FindLstInArea
local LSTNeededFlag
---
local PrepareAircraftReinforcements
local AreSovietPlanesActive
local OnAircraftStranded
local HasAirfield
local ScheduleAirWave
---
local ProduceSubs
local EnemySubsReinforcements

DebugMsgEnabled = true

--For Debug
D = function(msg)
	if DebugMsgEnabled then
		Media.Debug(tostring(msg))
	end
end

--------------------------------------------------------------------
-----------------	    DATA BLOCK - START	------------------------
--------------------------------------------------------------------
local function ______DATA______() end -- Used as marker for outliner. Remove when ready


------------------------------
--- Difficulty Start --------
------------------------------

local USSRCashReserves = { easy = 10000, normal = 10000, hard = 30000, arcade = 3000 }
local BadGuyCashReserves = { easy = 40000, normal = 50000, hard = 75000, arcade = 75000 }

local AlertUSSRDelays = { easy = DateTime.Minutes(8), normal = DateTime.Minutes(6), hard = DateTime.Minutes(5), challenge = DateTime.Minutes(5) }

local AtkProductionIntervals = { easy = DateTime.Seconds(60), normal = DateTime.Seconds(40), hard = DateTime.Seconds(20), challenge = DateTime.Seconds(20) }

------------------------------
--- Difficulty End	----------
------------------------------

---@type blueprint[]
local USSRBaseBlueprints =
{
	{ type = "powr", actor = USSRPower1, cost = 300, shape = { 2, 3 }, location = CPos.New(56, 42) },
	{ type = "apwr", actor = USSRPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(37, 42) },
	{ type = "apwr", actor = USSRPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(39, 39) },
	{ type = "powr", actor = USSRPower4, cost = 300, shape = { 2, 3 }, location = CPos.New(44, 39) },
	{ type = "apwr", actor = USSRPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(52, 39) },
	{ type = "apwr", actor = USSRPower6, cost = 500, shape = { 3, 3 }, location = CPos.New(55, 39) },
	{ type = "apwr", actor = USSRPower7, cost = 500, shape = { 3, 3 }, location = CPos.New(58, 41) },

	{ type = "proc", actor = USSRProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(41, 42) },

	{ type = "barr", actor = USSRBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(46, 45), owner = USSR, producer = true },
	{ type = "weap", actor = USSRWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(51, 45)  },
	{ type = "kenn", actor = USSRKenn, cost = 200, shape = { 1, 1 }, location = CPos.New(57, 45) },
	{ type = "spen", actor = USSRSpen, cost = 800, shape = { 3, 3 }, location = CPos.New(62, 50) },

	{ type = "dome", actor = USSRDome, cost = 1400, shape = { 2, 3 }, location = CPos.New(37, 39) },
	{ type = "stek", actor = USSRStek, cost = 1500, shape = { 3, 3 }, location = CPos.New(48, 42) },

	{ type = "afld", actor = USSRAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(38, 50) },
	{ type = "afld", actor = USSRAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(46, 40) },
	{ type = "afld", actor = USSRAfld3, cost = 500, shape = { 3, 2 }, location = CPos.New(49, 40) },
	{ type = "afld", actor = USSRAfld4, cost = 500, shape = { 3, 2 }, location = CPos.New(55, 50) },

	{ type = "ftur", actor = USSRFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(44, 53) },
	{ type = "ftur", actor = USSRFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(50, 53) },
    { type = "tsla", actor = USSRTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(43, 51) },
    { type = "tsla", actor = USSRTsla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(51, 51) }
}

---@type blueprint[]
local USSRBaseSamsBlueprints =
{
		-- I think these should be added to counter allies aircraft on normal/hard
	{ type = "sam", actor = USSRSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(38, 52) },
	{ type = "sam", actor = USSRSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(42, 39) },
	{ type = "sam", actor = USSRSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(55, 52) },
	{ type = "sam", actor = USSRSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(56, 38) }
}

---@type blueprint[]
local BadGuyBaseBlueprints =
{
	{ type = "powr", actor = BGPower1, cost = 300, shape = { 3, 3 }, location = CPos.New(98, 47) },
	{ type = "apwr", actor = BGPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(90, 51) },
}

---@type actor
local BGPower3, BGPower4, BGPower5, BGProc, BGBarr, BGWeap, BGDome, BGAfld1, BGAfld2, BGFtur1, BGFtur2, BGTesla1, BGTesla2, BGSam1, BGSam2, BGSam3, BGSam4 =
nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
---@type blueprint[]
local BadGuyBaseExtraBlueprints = 
{
	{ type = "apwr", actor = BGPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) },
	{ type = "apwr", actor = BGPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 52) },
	{ type = "apwr", actor = BGPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 55) },

	{ type = "proc", actor = BGProc, cost = 1400, shape = { 3, 4 }, location = CPos.New(100, 55) },

	{ type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(96, 60) },
	{ type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(100, 60) },

	{ type = "barr", actor = BGBarr, cost = 500, shape = { 2, 3 }, location = CPos.New(95, 50), owner = BadGuy, producer = true },
	{ type = "weap", actor = BGWeap, cost = 2000, shape = { 3, 3 }, location = CPos.New(92, 55), owner = BadGuy, producer = true },

	{ type = "afld", actor = BGAfld1, cost = 500, shape = { 3, 2 }, location = CPos.New(88, 54) },
	{ type = "afld", actor = BGAfld2, cost = 500, shape = { 3, 2 }, location = CPos.New(88, 56) },

    { type = "tsla", actor = BGTesla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(98, 58) },
    { type = "tsla", actor = BGTesla2, cost = 1200, shape = { 1, 1 }, location = CPos.New(97, 50) },

	{ type = "sam", actor = BGSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 51) },
	{ type = "sam", actor = BGSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(88, 59) },
	{ type = "sam", actor = BGSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(104, 59) },
	{ type = "sam", actor = BGSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(104, 47) }
}

local VehicleAttackInterval = { easy = DateTime.Seconds(180), normal = DateTime.Minutes(150), hard = DateTime.Minutes(120), challenge = DateTime.Minutes(120)}

-- Added full blueprint objects for Turkey just to don't mess up intellisense
---@type blueprint[]
local TurkeyBaseBlueprints =
{
	-- Change name of actors to TurkX
	-- Power outpost
	{ type = "apwr", actor = TurkPower1, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48)  }, 
	{ type = "apwr", actor = TurkPower2, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower3, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower4, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower5, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower6, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower7, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) }, 
	{ type = "apwr", actor = TurkPower8, cost = 500, shape = { 3, 3 }, location = CPos.New(103, 48) },
	{ type = "sam", actor = TurkSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam4, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = TurkSam5, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) },
	-- Island
	{ type = "tsla", actor = IslandTsla1, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla2, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla3, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla4, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "tsla", actor = IslandTsla5, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
	{ type = "tsla", actor = IslandTsla6, cost = 1400, shape = { 1, 1 }, location = CPos.New(103, 48) },
    { type = "sam", actor = IslandSam1, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam2, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }, 
	{ type = "sam", actor = IslandSam3, cost = 700, shape = { 2, 1 }, location = CPos.New(103, 48) }
}

-------------------------
-- Land Attacks Data   --
-------------------------

local USSRAttackPaths = { { USSRAtkWP1.Location }, { USSRAtkWP1.Location, USSRAtkWP2.Location } }
local BadGuyAttackPaths = { { BadGuyAtkWP1.Location } }

local InfantryTypes = { "e1", "e2", "e4"}
local InfantryAttackGroup = { }
local InfantryAttackGroupSizes = { easy = 6, normal = 9, hard = 12, challenge = 12 }

local VehicleTypes = { "3tnk", "3tnk", "3tnk", "v2rl", "v2rl", "4tnk" }
local VehicleAttackGroup = {}
local VehicleAttackGroupSizes = { easy = 2, normal = 3, hard = 4, challenge = 4}

local VehicleUSSRAttackGroup = { }
local VehicleBadGuyAttackGroup = { }

local InfantryUSSRAttackGroup = { }
local InfantryBadGuyAttackGroup = { }

CombatRole = "regular"
PossibleCombatRoles = { "regular", "guard", "marine" } --"marine" is for scenario b 
local shoreGuards = { 
	{ "3tnk", "3tnk", "v2rl" }, { "4tnk", "v2rl" }, { "4tnk", "3tnk" }, { "4tnk", "4tnk" } 
}

---@type { group: string[], location: cpos }[]
BeachGuardPositions	= {
	{ group = { }, location = CPos.New(62, 58) - CVec.New(-2, 0) },	-- 
    { group = { }, location = CPos.New(59, 63) - CVec.New(-2, 0)},	--
    { group = { }, location = CPos.New(60, 68) - CVec.New(-2, 0) },	--
	{ group = { }, location = CPos.New(60, 70) - CVec.New(-2, 0) }	--
}

-----------------------
-- Air Attacks Data  --
-----------------------

local CurrentAirWave = 1
local BasePlanes = {}

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

-------------------------
-- Naval Attacks Data  --
-------------------------

local SubTypes = { "ss"}

local SubUSSRAttackGroupSize = 2
local SubUSSRAttackGroup = { }

local SubBadGuyAttackGroupSize = 2
local SubBadGuyAttackGroup = { }

local NavalAtkPath = { }

LSTDetectionPivot = USSRSpen
LSTDetectionRange = WDist.FromCells(5)

--------------------------------------------------------------------
-----------------	    DATA BLOCK - END	------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	UTILS BLOCK - START	----------------------------
--------------------------------------------------------------------
local function ________________UTILS________________() end -- Used as marker for outliner. Remove when ready


---@param owner player
function IsHarvesterMissing(owner)
	return #owner.GetActorsByType("harv") == 0
end

---@param owner player
function CheckPlayerMoney(owner)
	return owner.Cash + owner.Resources
end

---@param player player
function GrantCash(player, amount)
    player.Cash = player.Cash + amount
end

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

---@param producer actor
---@param owner player
function ProducerTypeAvailableCheck(producer, owner)
	local type = producer.Type
	if #owner.GetActorsByType(type) > 0 then
		return true
	else
		return false
	end
end

---Issues an order to player to produce an harvester if there is enough cash
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
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function ________________BASE_MANAGEMENT________________() end -- Used as marker for outliner. Remove when ready


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
	Trigger.AfterDelay(Actor.BuildTime(blueprint.type), function()
		if cyard.IsDead or cyard.Owner ~= owner then
			return
		elseif CheckPlayerMoney(owner) <= 299 --[[and IsHarvesterMissing()]] then
			return
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

	Trigger.AfterDelay(1, function()
		if blueprint.type ~= "barr" and blueprint.type ~= "weap" and blueprint.type ~= "afld" and blueprint.type ~= "spen" then
			return
		end

		if blueprint.type == "barr" then
			ProduceInfantry(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceArmor(actor, owner)
		--elseif blueprint.type == "afld" then
		--	ProduceAircraft(actor, owner)
		--elseif blueprint.type == "spen" then
		--	ProduceSubs(actor, owner)
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
-----------------	BASE MANAGEMENT BLOCK - END	--------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------		ATTACKING BLOCK - START	--------------------
--------------------------------------------------------------------
local function ________________AI_ATTACKS________________() end -- Used as marker for outliner. Remove when ready


local function SetCombatRole()
	if CheckBeachGuardVacancy() and CombatRole == "regular" then
		CombatRole = "guard"
	else
		CombatRole = "regular"
	end
end

---@return integer|nil
function CheckBeachGuardVacancy()
	local points = BeachGuardPositions
	for index, guardPoint in ipairs(points) do
		if #guardPoint.group == 0 then
			return index
		end
	end
end

---@param units actor[]
---@param path cpos[]
local function SendUnits(units, path)
	Utils.Do(units, function(unit)
		if unit.IsDead then
			return
		end

		unit.Patrol(path, false)
		IdleHunt(unit)
	end)
end

-----------------------
--- Inf Attacks     ---
-----------------------
local function ________________Inf_Attacks________________() end -- Used as marker for outliner. Remove when ready


---@param producer actor
---@param owner player
function ProduceInfantry(producer, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(2), DateTime.Seconds(4))

    if not ProducerTypeAvailableCheck(producer, owner) then
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
--- Armor Attacks   ---
-----------------------
local function ________________Tank_Attacks________________() end -- Used as marker for outliner. Remove when ready


---@param producer actor
---@param owner player
function ProduceArmor(producer, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if not ProducerTypeAvailableCheck(producer, owner) then
		return
	elseif IsHarvesterMissing(owner) then
        ProduceHarvester(producer, owner, delay)
        return
    end

	local toBuild = { Utils.Random(VehicleTypes) }
    local path = Utils.Random(SelectLandAtkPaths(owner))

	owner.Build(toBuild, function(units)
        local unit = units[1]
        CreateCombatGroup(producer, owner, unit)
    end)
end

---@param producer actor
---@param owner player
---@param unit actor
function CreateCombatGroup(producer, owner, unit)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	local allPaths = {}
	--local path = Utils.Random( USSRAttackPaths )
	if owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end
	local path = Utils.Random(allPaths)
	if owner == USSR then
		table.insert(VehicleUSSRAttackGroup, unit)
		if #VehicleUSSRAttackGroup < VehicleAttackGroupSize then
			Trigger.AfterDelay(delay, function()
				ProduceArmor(producer, owner)
			end)
		else
			SetCombatRole()
			if CombatRole == "regular" then -- REGULAR
				SendUnits(VehicleUSSRAttackGroup, path)
			elseif CombatRole == "guard" and CheckBeachGuardVacancy() then -- GUARD
				local index = CheckBeachGuardVacancy()
				SetGuardPoint(index)
			elseif CombatRole == "marine" then -- MARINE
				--add these for b scenario
			end
			VehicleUSSRAttackGroup = { }
			Trigger.AfterDelay(DateTime.Minutes(2), function()
				ProduceArmor(producer, owner)
			end)
		end
	elseif owner == BadGuy then
		table.insert(VehicleBadGuyAttackGroup, unit)
		if #VehicleBadGuyAttackGroup < VehicleAttackGroupSize then
			Trigger.AfterDelay(delay, function()
				ProduceArmor(producer, owner)
			end)
		else -- Combat role conditionals
			SendUnits(VehicleBadGuyAttackGroup, path)
			Trigger.AfterDelay(DateTime.Minutes(2), function()
				ProduceArmor(producer, owner)
			end)
		end
	end
end

---@param index integer
function SetGuardPoint(index)
	BeachGuardPositions[index].group = VehicleUSSRAttackGroup
	local units = BeachGuardPositions[index].group
	local pos = BeachGuardPositions[index].location

	Utils.Do(units, function(u)
		u.Stance = "Defend"

		if not u.IsDead then
			u.Move(BeachGuardPositions[index].location)
		end

		Trigger.OnDamaged(u, function()
			if u.Health <= u.MaxHealth * 0.75 then
				u.Stance = "AttackAnything"
				Trigger.Clear(u, "OnDamaged")
				IdleHunt(u)
			end
		end)
	end)
	Trigger.OnAllKilled(units, function()
		BeachGuardPositions[index].group = { }
	end)
end

--FetchUnitsToTransport(units, load_loc)

---@param units actor[]
function FetchUnitsToTransport(units, load_loc)
	local lst = FindLstInArea(LSTDetectionPivot)

	if not lst then
		LSTNeededFlag(units)
		return
	end

	lst.Move(load_loc.Location)

	Utils.Do(units, function(u)
		if not u.IsDead then
			u.Move(TransportPoint.Location)
			u.EnterTransport(lst)

			Trigger.OnAddedToWorld(u, function()
				IdleHunt(u)
				if lst.PassengerCount == 0 then
					lst.Move(LSTDetectionPivot.Location)
				end
			end)
		end
	end)

	Trigger.OnAllRemovedFromWorld(units, function()
		if lst.PassengerCount == 0 then
			return
		end
		SendLSTAlt(lst, LSTPathRoute)
	end)
end

---@param units actor[]
function LSTNeededFlag(units)
	--USSRSpen = 
end

-----------------------
--- Air Attacks     ---
-----------------------
local function ________________Air_Attacks________________() end -- Used as marker for outliner. Remove when ready

---@return actor[]
---@param owner player
function CountAflds(owner)
	local aflds = owner.GetActorsByType("afld")
	return aflds
end

---@param producer actor
---@param owner player
local function ProduceAircraft(producer, owner)
    if not ProducerTypeAvailableCheck(producer, owner) then
        return
    end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(AircraftTypes) }

    USSR.Build(toBuild, function(units)
        local plane = units[1]
		table.insert(BasePlanes, plane)
        PlanesAttackGroup[#PlanesAttackGroup + 1] = plane

        Trigger.OnKilled(plane, function()
			table.remove(BasePlanes)
			Trigger.AfterDelay(delay, function()
				ProduceAircraft(producer, owner)
			end)
		end)
        InitializeAttackAircraft(plane, Greece)
    end)
end

local function GetAirstrikeTarget()
	local list = Greece.GetGroundAttackers()

	if #list == 0 then
		return
	end
	
	local target = list[DateTime.GameTime % #list + 1].CenterPosition
	return target
end

---@param unit actor
---@param route cpos[]
local function SendRenAirstrike(unit, route)
	if (USSRAfld1.IsDead or USSRAfld1.Owner ~= USSR) and (USSRAfld2.IsDead or USSRAfld2.Owner ~= USSR) and (USSRAfld3.IsDead or USSRAfld3.Owner ~= USSR) and (USSRAfld4.IsDead or USSRAfld4.Owner ~= USSR) then
		return
	end
	local attackers = Reinforcements.Reinforce(USSR, unit, route)
	for i = 1, #attackers do
		InitializeAttackAircraft(attackers[i], Greece)
	end
end

--Out of map attacks
--Disabled for now
--[[
SendParabombs = function()
	if BaseAfld.IsDead or BaseAfld.Owner ~= USSR then
		return
	end

	local airfield = BaseAfld
	local targets = Utils.Where(Greece.GetActors(), function(actor)
		return
			actor.HasProperty("Sell") and
			actor.Type ~= "brik" and
			actor.Type ~= "sbag" or
			actor.Type == "pdox" or
			actor.Type == "atek"
	end)
	if #targets > 0 then
		airfield.TargetAirstrike(Utils.Random(targets).CenterPosition, Angle.NorthEast)
	end

	Trigger.AfterDelay(ParabombDelay, SendParabombs)
end

SendParadrop = function()
	if BaseAfld.IsDead or BaseAfld.Owner ~= USSR then
		return
	end

	local aircraft = ParadropProxy.TargetParatroopers(KosyginExtractPoint.CenterPosition)

	Utils.Do(aircraft, function(a)
		Trigger.OnPassengerExited(a, function(t, p)
			IdleHunt(p)
		end)
	end)
	Trigger.AfterDelay(ParadropDelay, SendParadrop)
end
]]

function PrepareAircraftReinforcements()
	local delay = DateTime.Seconds(10)--FirstAirDelays[Difficulty] or FirstAirDelays["normal"]

	Trigger.AfterDelay(delay, function()
		ScheduleAirWave(1)
	end)
end

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
	if not team then
		team = SovietAirTeams[#SovietAirTeams]
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
				elseif HasAirfield(unit.Owner) and #BasePlanes < #CountAflds(unit.Owner) then
					return
				end
				OnAircraftStranded(unit, team.path[1])

			end)
		end)

		Trigger.OnAllRemovedFromWorld(units, function()
			if AreSovietPlanesActive() then
				return
			end

			-- Activate this at a later point
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

-----------------------
--- Naval Attacks   ---
-----------------------
local function ________________Naval_Attacks________________() end -- Used as marker for outliner. Remove when ready

---@param producer actor
---@param owner player
function ProduceSubs(producer, owner)
	if not ProducerTypeAvailableCheck(producer, owner) then
        return
	elseif CheckPlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
        return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	local toBuild = { Utils.Random(SubTypes) }
	local path = { }
	owner.Build(toBuild, function(units)
		if owner == USSR then
			table.insert(SubUSSRAttackGroup, units[1])
			if #SubUSSRAttackGroup >= SubUSSRAttackGroupSize then
				SendUnits(SubUSSRAttackGroup, NavalAtkPath)
				SubUSSRAttackGroup = { }
				Trigger.AfterDelay(AtkProductionInterval, function()
					ProduceSubs(producer, owner)
				end)
			else
				Trigger.AfterDelay(delay, function()
					ProduceSubs(producer, owner)
				end)
			end
		else
			table.insert(SubBadGuyAttackGroup, units[1])
			if #SubBadGuyAttackGroup >= SubBadGuyAttackGroupSize then
				SendUnits(SubBadGuyAttackGroup, NavalAtkPath)
				SubBadGuyAttackGroup = { }
				Trigger.AfterDelay(AtkProductionInterval, function()
					ProduceSubs(producer, owner)
				end)
			else
				Trigger.AfterDelay(delay, function()
					ProduceSubs(producer, owner)
				end)
			end

		end
	end)
end

---@param producer actor
---@param owner player
function ProduceLST(producer, owner)
	local toBuilt = { "lst" }

	if not ProducerTypeAvailableCheck(producer, owner) then
		owner.Build(toBuilt, function(units)

		end)
	end
end

---@return actor|nil
---@param waypoint actor
function FindLstInArea(waypoint)
	local CenterPos = waypoint.CenterPosition

	local lst = Map.ActorsInCircle(CenterPos, LSTDetectionRange, function(actor)		
		return actor.Type == "lst" and actor.Owner == USSR and actor.PassengerCount <= 0
	end)[1]

	if lst then
		return lst
	end
end

PrepareAttackOptions = function()

end

---@param producer actor
---@param owner player
PrepareNavalAtk = function(producer, owner)
	PrepareAttackOptions()

	if NavalAtkType == "lst" and #owner.GetActorsByType("lst") < 2 then
		ProduceLST(producer, owner)
	else
		ProduceSubs(producer, owner)
	end
end

LSTPathRoute = { USSRSpen.Location, LstDst.Location }

-- Similar to "SendUnits" but for lst unload passengers at last waypoint and going back following the same path. ATTEMPT 1
---@param lst actor
---@param path cpod[]
function SendLST(lst, path)
	local path = 
	Utils.Do
end

-- Similar to "SendUnits" but for lst unload passengers at last waypoint and going back following the same path. ATTEMPT 2
---@param lst actor
---@param path cpos[]
function SendLSTAlt(lst, path)
	local go_path = path
	local return_path = ReverseTable(path)

	Trigger.OnIdle(lst, function()
		if not lst.IsDead then
			if FindLstInArea(USSRSpen) then
				Utils.Do(path, function(p)
					lst.Move(p)
				end)
				--Trigger.Clear(lst, "OnIdle")
			else
				lst.UnloadPassengers(path[#path])
				Utils.Do(return_path, function(p)
					lst.Move(p)
				end)
				Trigger.Clear(lst, "OnIdle")
			end
		end
	end)
end

---@param array cpos[]
---@return cpos[]
function ReverseTable(array)
	local table_to_reverse = array
	local reversed_table = { }

	for i = #table_to_reverse, 1, -1 do
		--D(table_to_reverse[i])
    	table.insert(reversed_table, table_to_reverse[i])
		--D(reversed_table[i])
	end
	return reversed_table
end

--SendLSTAlt(Actor286, LSTPathRoute)

---@param units actor[]
---@param path cpos[]
local function SendUnits(units, path)
	Utils.Do(units, function(unit)
		if unit.IsDead then
			return
		end

		unit.Patrol(path, false)
		IdleHunt(unit)
	end)
end


-- Costant out of map attack if eastern Forward Command is not dead
function EnemySubsReinforcements()
    if BGFcom.IsDead then
		return
	end

	local northLeftEdge = WPos.New( (CPos.New(61,29)).X * 1024,  (CPos.New(61,29)).Y * 1024, 0)
    local southRightEdge = WPos.New( (CPos.New(105,103)).X * 1024, (CPos.New(105,103)).Y * 1024, 0)

    local actors = Map.ActorsInBox( northLeftEdge, southRightEdge, function(actor)
		return (actor.Owner == Greece or actor.Owner == England) and ( actor.Type == "pt" or actor.Type == "dd" or actor.Type == "ca" or actor.Type == "ss" or actor.Type == "spen" or actor.Type == "syrd" or actor.Type == "lst" )
	end)

    if #actors > 0 then
        local subsLeft = Reinforcements.Reinforce(USSR, {"ss", "ss"}, { EnglandLeftExit.Location, EnglandLeftExit.Location + CVec.New(0, 2) })
        Trigger.AfterDelay(DateTime.Seconds(2), function()
			Utils.Do(subsLeft, function(u)
				if not u.IsDead then
					u.AttackMove(EnglandLeftDst.Location)
					IdleHunt(u)
				end
			end)
        end)
		local subsRight = Reinforcements.Reinforce(USSR, {"ss", "ss"}, { EnglandRightExit.Location, EnglandRightExit.Location + CVec.New(0, 2) })
        Trigger.AfterDelay(DateTime.Seconds(2), function()
			Utils.Do(subsRight, function(u)
				if not u.IsDead then
					u.AttackMove(EnglandRightDst.Location)
					IdleHunt(u)
				end
			end)
		end)
    end
    Trigger.AfterDelay(DateTime.Minutes(4), function()
        EnemySubsReinforcements()
    end)
end

--------------------------------------------------------------------
----------------		ATTACKING BLOCK - END	--------------------
--------------------------------------------------------------------
local function ________________AI_SETUP________________() end -- Used as marker for outliner. Remove when ready


function SetupAIActivities()
	USSRCashReserve = USSRCashReserves[Difficulty]
    BadGuyCashReserve = BadGuyCashReserves[Difficulty]

	USSR.Cash = USSRCashReserve
    BadGuy.Cash = BadGuyCashReserve

	--ReverseTable(LSTPathRoute)

	AtkProductionInterval = AtkProductionIntervals[Difficulty]

	VehicleAttackGroupSize = VehicleAttackGroupSizes[Difficulty]
	
	--Maybe allow turkey's power plant and sams to repair
    --Turkey.Cash = 5000

	--AlertUSSRDelay = AlertUSSRDelays[Difficulty]
	Trigger.AfterDelay(DateTime.Minutes(1), function()
		SendLSTAlt(Actor286, LSTPathRoute)
	end)

	BeginBaseMaintenance(USSRBaseBlueprints, USSR)
	BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

	--BeginBaseMaintenance(TurkeyBaseBlueprints, Turkey)

	BuildBase(USSRBaseBlueprints, USSRFact, USSR)

	--Trigger.AfterDelay(DateTime.Minutes(4), function()
	--	EnemySubsReinforcements()
	--end)

	Trigger.AfterDelay(DateTime.Minutes(2), function()
		PrepareAircraftReinforcements()
	end)
end

-- Activated once USSR is alerted
function RunUSSRActivities()

	Trigger.AfterDelay(DateTime.Seconds(1), function()
		--InsertBlueprints(USSRBaseBlueprints, USSRBaseSamsBlueprints)
	end)

	ProduceInfantry(USSRBarr, USSR)
	--Trigger.AfterDelay(DateTime.Minutes(2), function()
		ProduceArmor(USSRWeap, USSR)
	--end)

	--ProduceSubs(USSRSpen, USSR)
end

-- Activated once BadGuy is alerted
function RunBadGuyActivities()
	InsertBlueprints(BadGuyBaseBlueprints, BadGuyBaseExtraBlueprints)
	BuildBase(BadGuyBaseBlueprints, BadGuyFact, BadGuy)
end
