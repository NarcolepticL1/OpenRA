--[[
   Copyright (c) The OpenRA Developers and Contributors
   This file is part of OpenRA, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

DebugMsgEnabled = true

--For Debug
D = function(msg)
	if DebugMsgEnabled then
		Media.Debug(tostring(msg))
	end
end

------------------------------
--- Definitions Start --------
------------------------------

local USSRCashReserves = { easy = 10000, normal = 10000, hard = 30000, arcade = 10000 }
local BadGuyCashReserves = { easy = 4000, normal = 50000, hard = 75000, arcade = 75000 }

local AlertUSSRDelays = { easy = DateTime.Minutes(8), normal = DateTime.Minutes(6), hard = DateTime.Minutes(5), challenge = DateTime.Minutes(5) }

local AtkProductionIntervals = { easy = DateTime.Seconds(60), normal = DateTime.Seconds(40), hard = DateTime.Seconds(20), challenge = DateTime.Seconds(20) }

------------------------------
--- Definitions End	----------
------------------------------

------------------------------
--- Data Start	--------------
------------------------------
local function __DATA__() end

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

    { type = "ftur", actor = BGFtur1, cost = 600, shape = { 1, 1 }, location = CPos.New(95, 41) },
    { type = "ftur", actor = BGFtur2, cost = 600, shape = { 1, 1 }, location = CPos.New(99, 41) },
    { type = "tsla", actor = BGTsla1, cost = 1200, shape = { 1, 1 }, location = CPos.New(95, 37) }
}

InfantryTypes = {"e1", "e2", "e4"}
InfantryUSSRAttackGroup = { }
InfantryBadGuyAttackGroup = { }

InfantryAttackGroupSize = 8


VehicleTypes = { "3tnk", "3tnk", "3tnk", "3tnk", "v2rl", "v2rl" }
VehicleUSSRAttackGroup = { }
VehicleBadGuyAttackGroup = { }

USSRAttackPaths =
{
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP6.Location, Waypoint34.Location},
    {MammothPatrolWP9.Location, MammothPatrolWP1.Location, MammothPatrolWP4.Location, Waypoint32.Location, Waypoint33.Location}
}

BadGuyAttackPaths = { {BGAttackRallyWP.Location}}

InfantryUnits = { "e1", "e2", "e4"}
local InfantryAttackGroup = { }
local InfantryAttackGroupSize = 12

local VehicleTypes = { "3tnk", "3tnk", "3tnk", "v2rl", "v2rl" }
local VehicleAttackGroup = {}
local VehicleAttackGroupSize = 5

local SubTypes = { "ss"}
local SubAttackGroup = { }
local SubAttackGroupSize = 5
local NavalAtkPath = { }

--------------------------------------------------------------------
-----------------	UTILS BLOCK - START	----------------------------
--------------------------------------------------------------------

local function ________________UTILS________________() end

---@param owner player
local IsHarvesterMissing = function(owner)
	return #owner.GetActorsByType("harv") == 0
end

---@param owner player
local CheckPlayerMoney = function(owner)
	return owner.Cash + owner.Resources
end

---@param player player
local GrantCash = function(player, amount)
    player.Cash = player.Cash + amount
end

--Insert blueprints[] to player base building blueprints[]
---@param blueprints blueprint[]
---@param insert blueprint[]
local InsertBlueprints = function(blueprints, insert)
    Utils.Do(insert, function(b)
        local index = #blueprints
		table.insert(blueprints, index, b)
        PrepareBlueprintEdges(b)
    end)
end

--------------------------------------------------------------------
-----------------	UTILS BLOCK - END	----------------------------
--------------------------------------------------------------------

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - START	----------------
--------------------------------------------------------------------
local function __BASE_MANAGEMENT__() end

---@param actors actor[]
---@param owner player
local ScatterBlockers = function(actors, owner)
	Utils.Do(actors, function(a)
		if a.IsIdle and a.Owner == owner and a.HasProperty("Scatter") then
			a.Scatter()
		end
	end)
end

---@param blueprint blueprint
---@param owner player
local IsBuildAreaBlocked = function(owner, blueprint)
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

---@param actor actor
---@param blueprint blueprint
---@param owner player
local OnBlueprintBuilt = function(actor, blueprint, owner)
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
			D("ProduceArmor")
			ProduceArmor(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceAircraft(actor, owner)
		elseif blueprint.type == "weap" then
			ProduceSubs(actor, owner)
		end
	end)
end

---@param blueprints blueprint[]
---@param blueprint blueprint
---@param cyard actor
---@param owner player
local BuildBlueprint = function(blueprints, blueprint, cyard, owner)
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

---@param blueprints blueprint[]
---@param cyard any
---@param owner player
local BuildBase = function(blueprints, cyard, owner)
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

---@param blueprint blueprint
local PrepareBlueprintEdges = function(blueprint)
	local shapeX, shapeY = blueprint.shape[1], blueprint.shape[2]
	local northwestEdge = Map.CenterOfCell(blueprint.location) + WVec.New(-512, -512, 0)
	local southeastEdge = northwestEdge + WVec.New(shapeX * 1024, shapeY * 1024, 0)
	blueprint.northwestEdge = northwestEdge
	blueprint.southeastEdge = southeastEdge
end

---@param actor actor
---@param blueprint? blueprint
---@param repairThreshold number
local MaintainBuilding = function(actor, blueprint, repairThreshold)
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

---@param blueprints blueprint[]
---@param owner player
local BeginBaseMaintenance = function(blueprints, owner)
	Utils.Do(blueprints, function(blueprint)
		MaintainBuilding(blueprint.actor, blueprint, 0.75)
	end)
	Utils.Do(owner.GetActors(), function(actor)
		if actor.HasProperty("StartBuildingRepairs") then
			MaintainBuilding(actor, nil, 0.75)
		end
	end)
end

---Issues an order to player to produce an harvester if there is enough cash
---@param producer actor
---@param owner player
---@param delay number
local ProduceHarvester = function(producer, owner, delay)
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

---@param producer actor
---@param owner player
local ProducerAvailableCheck = function(producer, owner)
	local type = producer.Type
	if #owner.GetActorsByType(type) > 0 then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------
-----------------	BASE MANAGEMENT BLOCK - END 	----------------
--------------------------------------------------------------------

--------------------------------------------------------------------
----------------	ATTACKING BLOCK - START	    --------------------
--------------------------------------------------------------------
local function ________________AI_ATTACKS________________() end

---@param units actor[]
---@param path cpos[]
local SendUnits = function(units, path)
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
local function __INF_ATTACKS__() end


-------------[[ CHOOSE BETWEEN THIS TWO FUNCTIONS ( ProduceInfantry )]]

---@param producer actor
---@param owner player
ProduceInfantry = function(producer, owner)
	if not ProducerAvailableCheck(producer, owner) then
		return
	elseif CheckPlayerMoney(owner) <= 299 --[[and IsHarvesterMissing()]] then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))
	local toBuild = { Utils.Random(InfantryUnits) }

	owner.Build(toBuild, function(units)
		table.insert(InfantryAttackGroup, units[1])

		if #InfantryAttackGroup >= InfantryAttackGroupSize then
			SendUnits(InfantryAttackGroup, LandAtkPaths)
			InfantryAttackGroup = { }
			Trigger.AfterDelay(AtkProductionInterval, function()
				ProduceInfantry(producer, owner)
			end)
		else
			Trigger.AfterDelay(delay, function()
				ProduceInfantry(producer, owner)
			end)
		end
	end)
end


---@param barrack any
---@param owner player
ProduceInfantry = function(barrack, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(2), DateTime.Seconds(4))

	if barrack.IsDead or barrack.Owner ~= owner then
		return
	elseif PlayerMoney(owner) <= 299 and IsHarvesterMissing(owner) then
		return
	end

    local toBuild = { Utils.Random(InfantryTypes) }
    local allPaths = {}
    if barrack.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
	owner.Build(toBuild, function(units)
        if barrack.Owner == USSR then
            table.insert(InfantryUSSRAttackGroup, units[1])
            if #InfantryUSSRAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryUSSRAttackGroup, path)
                InfantryUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceInfantry(barrack, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(barrack, owner)
			    end) 
            end
        else
            table.insert(InfantryBadGuyAttackGroup, units[1])
            if #InfantryBadGuyAttackGroup >= InfantryAttackGroupSize then
                SendUnits(InfantryBadGuyAttackGroup, path)
                InfantryBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceInfantry(barrack, owner)
			    end)
            else
                Trigger.AfterDelay(delay, function()
				    ProduceInfantry(barrack, owner)
			    end) 
            end
        end
	end)
end

-----------------------
--- Tank Attacks    ---
-----------------------

ProduceArmor = function(factory, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if factory.IsDead or factory.Owner ~= owner then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(owner, factory, delay)
        else
            return
        end
    end

	local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if factory.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
	owner.Build(toBuild, function(units)
        if factory.Owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        elseif factory.Owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        end
    end)
end

-----------------------
--- Air Attacks    ----
-----------------------
--[[
ProduceAircraft = function()
    if (USSRAfld1.IsDead or USSRAfld1.Owner ~= USSR) and (USSRAfld2.IsDead or USSRAfld2.Owner ~= USSR) then
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

PlanesAttack = function()
    local entry = Utils.Random({ IronTankEntry.Location, SovWaterEntry.Location, BadgerEntry.Location })
    local planeType = Utils.Random({SovietAircraftType})
    Media.Debug("Check till here 1")
    for p = 1, #planeType do
        Trigger.AfterDelay(DateTime.Seconds(0.25*p), function()
            local a = Actor.Create(planeType[p], true, { Owner = USSR, Location = entry })
            InitializeAttackAircraft(a, Greece)
        end)
    end
end

CheckPlaneAmmo = function(plane, dir)
    if not plane.IsDead and plane.AmmoCount() >= 1 then
        Trigger.AfterDelay(DateTime.Seconds(3), function()
            CheckPlaneAmmo(plane, dir)
        end)
    elseif not plane.IsDead then
            Trigger.ClearAll(plane)
            plane.Move(dir)
            plane.Destroy()
            return
    end
end
]]
-----------------------
--- Naval Attacks  ----
-----------------------

ProduceSubmarines = function(shipyard, owner)
    local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

    if shipyard.IsDead or shipyard.Owner ~= owner then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(owner, factory, delay)
        else
            return
        end
    end

    local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if shipyard.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
    owner.Build(toBuild, function(units)
        if shipyard.Owner == USSR then
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

ProduceArmor = function(factory, owner)
	local delay = Utils.RandomInteger(DateTime.Seconds(12), DateTime.Seconds(17))

	if factory.IsDead or factory.Owner ~= owner then
		return
	elseif IsHarvesterMissing(owner) then
		if owner == USSR then
            ProduceHarvester(owner, factory, delay)
        else
            return
        end
    end

	local toBuild = { Utils.Random(VehicleTypes) }
    local allPaths = {}
    if factory.Owner == USSR then
        allPaths = USSRAttackPaths
    else
        allPaths = BadGuyAttackPaths
    end

    local path = Utils.Random(allPaths)
	owner.Build(toBuild, function(units)
        if factory.Owner == USSR then
            table.insert(VehicleUSSRAttackGroup, units[1])
            if #VehicleUSSRAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleUSSRAttackGroup, path)
                VehicleUSSRAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(2), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        elseif factory.Owner == BadGuy then
            table.insert(VehicleBadGuyAttackGroup, units[1])
            if #VehicleBadGuyAttackGroup >= VehicleAttackGroupSize then
                SendUnits(VehicleBadGuyAttackGroup, path)
                VehicleBadGuyAttackGroup = { }
                Trigger.AfterDelay(DateTime.Minutes(1.5), function()
                    ProduceArmor(factory, owner)
                end)
            else
                Trigger.AfterDelay(delay, function()
                    ProduceArmor(factory, owner)
                end)
            end
        end
    end)
end

EnemySubsReinforcements = function()
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
----------------	AI ATTACKING BLOCK - END        ----------------
--------------------------------------------------------------------
local function __AI_SETUP__() end

SetupAIActivities = function()
    USSRCashReserve = USSRCashReserves[Difficulty]
    BadGuyCashReserve = BadGuyCashReserves[Difficulty]

    -- For repairs
    Turkey.Cash = 5000

    AlertUSSRDelay = AlertUSSRDelays[Difficulty]

    BeginBaseMaintenance(USSRBaseBlueprints, USSR)
    BeginBaseMaintenance(BadGuyBaseBlueprints, BadGuy)

    BeginBaseMaintenance(TurkeyBaseBlueprints, Turkey)

    BuildBase(USSRBaseBlueprints, USSRFact, USSR)

    Trigger.AfterDelay(DateTime.Seconds(10), function()
        InsertBlueprints(BadGuyBaseBlueprints, BadGuyBaseExtraBlueprints)
    end)

    ProduceInfantry(USSRBarr, USSR)
    ProduceArmor(USSRWeap, USSR)
end