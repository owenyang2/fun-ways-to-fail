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
    game.Workspace.PlaceModels:FindFirstChild("AppleTree")
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
    local newApple = RepStorage.Assets.Apple:Clone()
    newApple.Parent = self.Instance

    local newTrove = Trove.new()

    newTrove:Connect(RunService.Heartbeat, function()
        newApple.AlignPosition.Position = chr.HumanoidRootPart.Position
        if not chr:FindFirstChild("HumanoidRootPart") then
            newTrove:Destroy()
        elseif (newApple.Position - chr.HumanoidRootPart.Position).Magnitude < 2 then
            chr.Humanoid.Health = 0
            newTrove:Destroy()
        end
    end)
end

function AppleTree:Start()
    self._trove:Connect(RunService.Heartbeat, function()
        local parts = workspace:GetPartBoundsInBox(self.Hitbox.CFrame, self.Hitbox.Size, getOverlapParams())

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorWhichIsA("Model")

            if table.find(self.CurrentChrs, chr) or not game.Players:GetPlayerFromCharacter(chr) then continue end
            table.insert(self.CurrentChrs, chr)

            task.spawn(function()
                self:KillChr(chr)
            end)
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

return AppleTree