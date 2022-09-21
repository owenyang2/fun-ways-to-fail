-- setup remote communications tracking keybinds to get out
local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(RepStorage.Packages.Knit)

local ClientComm = require(RepStorage.Packages.Comm).ClientComm
local clientComm = ClientComm.new(RepStorage, false, "Quicksand")

local pressedSpace = clientComm:GetSignal("QuicksandEscape")

local QuicksandController = Knit.CreateController {
    Name = "QuicksandController"
}

function QuicksandController:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not self.Player.Character then return end
        
        if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
            pressedSpace()
        end
    end)
end

function QuicksandController:KnitStart()
    self.Player = game.Players.LocalPlayer

    self:SetupInput()
end

return QuicksandController