local Ragdoll = {}
Ragdoll.__index = Ragdoll

local RepStorage = game:GetService("ReplicatedStorage")

local Trove = require(RepStorage.Packages.Trove)

Ragdoll.GlobalRagdolls = {}

local hinges = { --LowerAngle and UpperAngle
	[{"LeftWrist", "RightWrist", "LeftAnkle", "RightAnkle"}] = {5, 5},
	[{"LeftElbow", "RightElbow"}] = {0, 135},
	[{"LeftKnee", "RightKnee"}] = {-140, 0},
}

local sockets = { -- UpperAngle, TwistLowerAngle, TwistUpperAngle and MaxFrictionTorque
	[{"Neck"}] = {60, -75, 60, 10},
	[{"RightShoulder", "LeftShoulder"}] = {45, -90, 150},
	[{"Waist"}] = {30, -55, 25},
	[{"LeftHip", "RightHip"}] = {50, 100, -45},
}

local function findReplacementJoint(targetMotor)
	for motors, properties in pairs(hinges) do
		if table.find(motors, targetMotor) then
			local hinge = Instance.new("HingeConstraint")
			hinge.LimitsEnabled = true
			
			hinge.LowerAngle = properties[1]
			hinge.UpperAngle = properties[2]
			
			return hinge
		end
	end
	
	for motors, properties in pairs(sockets) do
		if table.find(motors, targetMotor) then
			local socket = Instance.new("BallSocketConstraint")
			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true
			
			socket.UpperAngle = properties[1]
			socket.TwistLowerAngle = properties[2]
			socket.TwistUpperAngle = properties[3]
			
			if properties[4] then
				socket.MaxFrictionTorque = properties[4]
			end
			
			return socket
		end
	end
end

local function createAtt(name, cf, parent)
	local att = Instance.new("Attachment")
	att.Name = name
	att.CFrame = cf
	att.Parent = parent
	
	return att
end

function Ragdoll:CreateJoints()
	if not self.Player.Character then warn("Could not create ragdoll joints for " .. self.Player.Name) return end

	local jointFolder = Instance.new("Folder")
	jointFolder.Name = "RagdollJoints"
	jointFolder.Parent = self.Player.Character

	for _, motor in ipairs(self.Player.Character:GetDescendants()) do
		if not motor:IsA("Motor6D") then continue end

		local ragdollJoint = findReplacementJoint(motor.Name)
		if not ragdollJoint then continue end
		
		-- add motor to motor table
		table.insert(self.Motor6DJoints, motor)
		self._trove:Connect(motor.Destroying, function()
			table.remove(self.Motor6DJoints, table.find(self.Motor6DJoints, motor))
		end)
		
		ragdollJoint.Attachment0 = createAtt("RagdollAtt", motor.C0, motor.Part0)
		ragdollJoint.Attachment1 = createAtt("RagdollAtt", motor.C1, motor.Part1)			
		ragdollJoint.Parent = jointFolder
		ragdollJoint.Enabled = false
		
		table.insert(self.RagdollJoints, ragdollJoint)
		self._trove:Connect(ragdollJoint.Destroying, function()
			table.remove(self.RagdollJoints, table.find(self.RagdollJoints, ragdollJoint))
		end)
	end
end

function Ragdoll:Toggle(enable)
	-- using enable and disable should be easier, but made this as enable/disable are just inverses

	local chr = self.Player.Character

	if not chr or self.Ragdolled then return end
	
	self.Ragdolled = enable
	
	self.Player.Character.HumanoidRootPart.CanCollide = not enable
	self.Player.Character.HumanoidRootPart.Massless = enable
	
	for _, motor in ipairs(self.Motor6DJoints) do
		motor.Enabled = not enable
	end

	for _, ragdollJoint in ipairs(self.RagdollJoints) do
		ragdollJoint.Enabled = enable
	end
end

function Ragdoll:Enable()
	self:Toggle(true)	
end

function Ragdoll:Disable()
	self:Toggle(false)	
end

function Ragdoll:Destroy()
	self:Disable()
	self._trove:Destroy() -- clean up on death connections
	Ragdoll.GlobalRagdolls[self.Player] = nil
end

function Ragdoll:Setup()
	self:CreateJoints()

	self._trove:Connect(self.Player.CharacterAdded, function(chr) -- should be disconnected when cleaned up
		chr.Humanoid.BreakJointsOnDeath = false
		self._trove:Connect(chr.Humanoid.Died, function() -- setup ragdoll on death
			self:Enable()
		end)
	end)
end

function Ragdoll.new(plr)
	local newRagdoll = setmetatable({
		Player = plr,
		_trove = Trove.new(),
		Ragdolled = false,
		
		RagdollJoints = {}, -- ragdoll joints
		Motor6DJoints = {} -- normal motor6d joints
	}, Ragdoll)

	newRagdoll:Setup()

	return newRagdoll
end

return Ragdoll