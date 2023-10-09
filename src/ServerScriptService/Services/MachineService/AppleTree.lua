local AppleTree = {}
AppleTree.__index = AppleTree

local HapticService = game:GetService("HapticService")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")

local Trove = require(RepStorage.Packages.Trove)
local TableUtil = require(RepStorage.Packages.TableUtil)

local Ragdoll = require(ServerScriptService.Server.Classes.Ragdoll)

local ServerComm = require(RepStorage.Packages.Comm).ServerComm
local serverComm = ServerComm.new(RepStorage, "AppleTree")
local appleSignal = serverComm:CreateSignal("DropApple")

AppleTree.AvailableInstances = {
    game.Workspace.PlaceModels:FindFirstChild("AppleTree")
}

function AppleTree:SetupAppleSignal()
    self._trove:Connect(appleSignal, function(plr, cf, cmd)
        local apple = self.Apples[plr]
        if not apple then return end

        if cmd == "Move" then
            apple.CFrame = cf
        elseif cmd == "Destroy" then
            apple:Destroy()
            self.Apples[plr] = nil
        end
    end)
end

function AppleTree:KillPlr(plr)
    local newSvApple = RepStorage.Assets.Apple:Clone()
    newSvApple.CFrame = self.Instance.Apple.CFrame
    newSvApple.Anchored = true
    newSvApple.Parent = self.Instance
    newSvApple.Name = plr.Name .. "AppleSv"

    self.Apples[plr] = newSvApple
    appleSignal:Fire(plr)
end

function AppleTree:Start()
    self._trove:Connect(RunService.Heartbeat, function()
        local parts = workspace:GetPartBoundsInBox(self.Hitbox.CFrame, self.Hitbox.Size, self.MachineFuncs.GetHitboxParams())

        for _, part in ipairs(parts) do
            local chr = part:FindFirstAncestorWhichIsA("Model")
            local plr = game.Players:GetPlayerFromCharacter(chr)

            if not plr or self.Apples[plr] or chr.Humanoid.Health == 0 then continue end

            task.spawn(function()
                self:KillPlr(plr)
            end)
        end
    end)

    self:SetupAppleSignal()
end

function AppleTree.new(baseTbl)
    local newInst = baseTbl.MachineFuncs.GetAvailableInst(AppleTree.AvailableInstances)
    if not newInst then return end

    local self = setmetatable(TableUtil.Assign(baseTbl, {
        Instance = newInst,
        Hitbox = newInst.Hitbox,

        Apples = {},
        VeloDelay = 0.5,
        FollowSpeed = 100,

        _trove = Trove.new()
    }), AppleTree)

    return self
end

return AppleTree