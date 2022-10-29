local Quicksand = {}
Quicksand.__index = Quicksand

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

local QuicksandTag = "Quicksand"

Quicksand.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Quicksand")
}

function Quicksand:StopSink(chr)
    local pos = table.find(self.SinkingChrs, chr)

    if not pos then return end

    table.remove(self.SinkingChrs, pos)
end

function Quicksand:KillChr(chr)
    if not table.find(self.SinkingChrs, chr) then return end

    self:StopSink(chr)

    for _, part in ipairs(chr:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        part.Anchored = true
    end
    chr.Head.Neck:Destroy()
end

function Quicksand:Sink(chr)
    if table.find(self.SinkingChrs, chr) or chr.Humanoid.Health == 0 then return end
    table.insert(self.SinkingChrs, chr)
end

function Quicksand:Enable()
    CollectionService:AddTag(self.Instance.Quicksand, QuicksandTag)

    local chrTbl = {}

    local function checkQuicksand(dt)
        local parts = game.Workspace:GetPartsInPart(self.Instance.Quicksand, self.MachineFuncs.GetHitboxParams())

        local doneChrs = {} -- characters who already updated stay length

        for _, part in ipairs(parts) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) or chr.Humanoid.Health == 0 then return end
            
            table.insert(doneChrs, chr)

            if not chrTbl[chr] then chrTbl[chr] = {StayLength = 0} continue end

            chrTbl[chr].StayLength += dt

            if chrTbl[chr].StayLength > self.Config.SinkDelay then
                task.spawn(function() -- prevent thread pausing
                    self:Sink(chr)
                end)
            end
        end

        for chr, _ in pairs(chrTbl) do -- if left quicksand
            if not table.find(doneChrs, chr) then
                chrTbl[chr] = nil
                task.spawn(function() -- prevent thread pausing
                    self:StopSink(chr)
                end)
            end
        end
    end

    local function checkDeath()
        local parts = game.Workspace:GetPartsInPart(self.Instance.Death, self.MachineFuncs.GetHitboxParams())

        local doneChrs = {} -- characters who already updated stay length

        for _, part in ipairs(parts) do
            local chr = part.Parent
            local plr = game.Players:GetPlayerFromCharacter(chr)
            if not plr or table.find(doneChrs, chr) then return end
            
            table.insert(doneChrs, chr)

            task.spawn(function() -- prevent thread pausing
                self:KillChr(chr)
            end)
        end
    end

    self._trove:Connect(RunService.Heartbeat, function(dt)
        checkQuicksand(dt)
        checkDeath()
    end)
end

function Quicksand:Start()
    self:Enable()
end

function Quicksand.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(Quicksand.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        _trove = Trove.new(),
        SinkingChrs = {},
        Config = {
            SinkDelay = 1,
        }
    }), Quicksand)

    return self
end

return Quicksand