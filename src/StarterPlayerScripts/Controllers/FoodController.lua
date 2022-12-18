local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local ClientComm = require(RepStorage.Packages.Comm).ClientComm
local clientComm = ClientComm.new(RepStorage, false, "Food")
local comm = clientComm:BuildObject()

local FoodController = Knit.CreateController {
    Name = "FoodController"
}

local FoodModel = game.Workspace.PlaceModels.Food

function FoodController:Grab()
    self.CurrentBurgerInst:Destroy()
    self.CurrentBurgerInst = nil

    comm.EnlargePlayer:Fire()

    self:Dispense()
end

function FoodController:Dispense()
    if self.CurrentBurgerInst then return end

    self.CurrentBurgerInst = RepStorage.Assets.Burger:Clone()
    self.CurrentBurgerInst.Parent = FoodModel
    self.CurrentBurgerInst.Position = FoodModel.StartPos.Position

    local posInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    local rotInfo =  TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    local posTween = TweenService:Create(self.CurrentBurgerInst, posInfo, {Position = FoodModel.EndPos.Position})
    local rotTween = TweenService:Create(self.CurrentBurgerInst, rotInfo, {Orientation = self.CurrentBurgerInst.Orientation + Vector3.new(0, 180, 0)})

    rotTween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            rotTween:Play()
        end
    end)

    posTween:Play()
    rotTween:Play()

    self.CurrentBurgerInst.ClickDetector.MouseClick:Connect(function()
        self:Grab()
    end)
end

function FoodController:KnitStart()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()
    self.CurrentBurgerInst = nil

    self:Dispense()
end

return FoodController