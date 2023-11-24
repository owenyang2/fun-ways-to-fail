-- setup remote communications tracking keybinds to get out
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Knit = require(RepStorage.Packages.Knit)
local Component = require(RepStorage.Packages.Component)
local MachineFuncs = require(RepStorage.Common.MachineFunctions)
local Trove = require(RepStorage.Packages.Trove)

local BoinkHammer = Component.new {
    Tag = "BoinkHammer"
}

function BoinkHammer:SetupConnections()
    self.Instance.Activated:Connect(function()
        if self.Player.Character then
            self.ToolService:SwingBoinkHammer()
        end
    end)
end

function BoinkHammer:Stop()
    self._trove:Destroy()
end

function BoinkHammer:Start()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self.Mouse = self.Player:GetMouse()
    self.ToolService = Knit.GetService("ToolService")

    self:SetupConnections()
end

return BoinkHammer