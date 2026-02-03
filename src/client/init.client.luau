local RunService = game:GetService("RunService")

--Create these when the server tells the client to
local ClientConveyor = require("./client/Modules/ClientConveyor")
local ClientBag = require("./client/Modules/ClientBag")
local ClientContainer = require("./client/Modules/ClientContainer")

RunService.RenderStepped:Connect(function(a0: number)
	--Update all bags and their position
end)
