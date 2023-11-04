local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local UIFunctions = require(RepStorage.Common.UIFunctions)

local UIController = Knit.CreateController {
    Name = "UIController"
}

function UIController:SetupUIs()
	local mainScreenGUI = self.Player.PlayerGui:WaitForChild("Main")

	for _, module in ipairs(self.UIModules) do
        if not module:IsA("ModuleScript") then
            warn("UI Module " .. module.Name .. " could not be initialized as it is not a modulescript.")
            continue
        end

        local newUI = require(module).new({
            UIFuncs = UIFunctions,
			MainUI = mainScreenGUI,
			Player = game.Players.LocalPlayer
        }) 
        print(module.Name .. " UI Module Instantiated")
        newUI:Start()
    end
end

function UIController:KnitStart()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

	self.UIModules = {
		script.HUD
	}

    self:SetupUIs()
end

return UIController