-- setup remote communications tracking keybinds to get out
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)
local Trove = require(RepStorage.Packages.Trove)

local PushTool = Component.new {
    Tag = "PushToolClick"
}

function PushTool:SetupConnections()
    self.Instance.Activated:Connect(function()
        local targetPart = self.Mouse.Target

        if not targetPart then return end

        local targetPlr = game.Players:GetPlayerFromCharacter(targetPart:FindFirstAncestorOfClass("Model"))

        if targetPlr and targetPlr ~= self.Player then -- second part is redundant (since dont think plr is in mouse target collision group) but why not
            print("send")
            self.ToolService:PushTargetClick(targetPlr)
        end
    end)
end

function PushTool:Stop()
    self._trove:Destroy()
end

function PushTool:Start()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self.Mouse = self.Player:GetMouse()
    self.ToolService = Knit.GetService("ToolService")

    self:SetupConnections()
end

return PushTool