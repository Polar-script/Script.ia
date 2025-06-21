local PathfindingService = game:GetService("PathfindingService")

local Estados = require(script.Parent:WaitForChild("Estados"))
local falar = require(script.Parent:WaitForChild("Chat"))

local function moverPara(destino, personagem, humanoid)
	local raiz = personagem:FindFirstChild("HumanoidRootPart")
	if not raiz or not destino then return end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true
	})

	path:ComputeAsync(raiz.Position, destino)

	if path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()

		for _, waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end

			humanoid:MoveTo(waypoint.Position)
			local inicio = tick()

			repeat
				task.wait(0.1)
			until (raiz.Position - waypoint.Position).Magnitude < 3 or tick() - inicio > 5

			if (raiz.Position - waypoint.Position).Magnitude > 10 then
				humanoid.Jump = true
			end
		end
	else
		falar("Falha no caminho, recalculando...", personagem)
		humanoid.Jump = true
	end
end

return {
	moverPara = moverPara
}