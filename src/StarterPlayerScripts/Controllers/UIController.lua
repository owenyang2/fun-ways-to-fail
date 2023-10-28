local RepStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(RepStorage.Packages.Knit)
local Trove = require(RepStorage.Packages.Trove)

local UIController = Knit.CreateController {
    Name = "UIController"
}

-- copied from devforum
local function abbreviateNumber(number)
    local abbreviations = {"K","M","B","T","Qd","Qn","Sx","Sp","O","N"}

	local abbreviationIndex = math.floor(math.log(number,1000))
	local abbreviation = abbreviations[abbreviationIndex]

	if abbreviation then
		local shortNum = number/(1000^abbreviationIndex)
		local intNum = math.floor(shortNum)
		local str = intNum .. abbreviation
		if intNum < shortNum then
			str = str .. "+"
		end
		return str
	else
		return tostring(number)
	end
end

function UIController:SetupDeaths()
    local deathsUI = self.Player.PlayerGui:WaitForChild("Main").HUD.Left.DeathCount.Deaths.Value
    local deathsServer = self.Player:WaitForChild("leaderstats").Deaths

    deathsUI.Text = abbreviateNumber(deathsServer.Value) -- init when first join

    deathsServer.Changed:Connect(function(newValue)
        deathsUI.Text = abbreviateNumber(newValue)
    end)
end

function UIController:KnitStart()
    self.Player = game.Players.LocalPlayer
    self._trove = Trove.new()

    self:SetupDeaths()
end

return UIController