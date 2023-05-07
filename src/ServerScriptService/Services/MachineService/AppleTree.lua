local AppleTree = {}
AppleTree.__index = AppleTree

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

AppleTree.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("Apple")
}

local function getOverlapParams()
    local op = OverlapParams.new()
    op.FilterType = Enum.RaycastFilterType.Whitelist

    local t = {}

    for _, plr in ipairs(game.Players:GetPlayers()) do
        table.insert(t, plr.Character)
    end

    op.FilterDescendantsInstances = t
    
    return op
end

function AppleTree:KillChr(chr)
    
end

function AppleTree:Start()
    self._trove:Connect(RunService.Heatbeat, function()
        local parts = workspace:GetPartsInPart(self.Hitbox, getOverlapParams())

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorWhichIsA("Model")

            if table.find(self.Chrs, chr) or game.Players:GetPlayerFromCharacter(chr) then continue end
            table.insert(self.Chrs, chr)

            self:KillChr(chr)
        end
    end)
end

function AppleTree.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(AppleTree.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        Hitbox = newInst.Hitbox,

        CurrentChrs = {},

        _trove = Trove.new()
    }), AppleTree)

    return self
end

return Cannon