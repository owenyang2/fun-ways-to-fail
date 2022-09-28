-- setup remote communications tracking keybinds to get out
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)
local Trove = require(RepStorage.Packages.Trove)

local Quicksand = Component.new {
    Tag = "Quicksand"
}

function Quicksand:Sink(chr)
    if self.Sinking then return end

    self.RagdollController:Toggle()
    self.RagdollController:CanRagdoll(false)

    self._trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
        if not self.Player.Character then return end
        -- jump up a bit
    end)

    chr.Humanoid.Died:Connect(function()
        self.Sinking = false
        self._trove:Clean()
    end)
end

function Quicksand:HeartbeatUpdate(dt)
    -- if player touches quicksand, start sinking them
    if self.Sinking then return end

    local parts = game.Workspace:GetPartsInPart(self.Instance, MachineFuncs.GetHitboxParams())

    for _, part in ipairs(parts) do
        local chr = part.Parent
        local plr = game.Players:GetPlayerFromCharacter(chr)
        if not plr or self.Player ~= plr then return end
        
        task.spawn(function() -- prevent thread pausing
            self:Sink(chr)
        end)
    end
end

function Quicksand:Stop()
    self._trove:Destroy()
end

function Quicksand:Start()
    self.Player = game.Players.LocalPlayer
    self.RagdollController = Knit.GetController("RagdollController")
    self.Sinking = false
    self._trove = Trove.new()

    self:Setup()
end

return Quicksand