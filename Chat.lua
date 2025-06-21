local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatService = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 5)
local SayMessageRequest = ChatService and ChatService:FindFirstChild("SayMessageRequest")

local function criarBalãoDeFala(personagem, texto)
	local head = personagem:FindFirstChild("Head")
	if not head then return end

	local antigo = personagem:FindFirstChild("BalaoDeFala")
	if antigo then antigo:Destroy() end

	local gui = Instance.new("BillboardGui")
	gui.Name = "BalaoDeFala"
	gui.Adornee = head
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = personagem

	local textoLabel = Instance.new("TextLabel")
	textoLabel.Size = UDim2.new(1, 0, 1, 0)
	textoLabel.BackgroundTransparency = 1
	textoLabel.TextColor3 = Color3.new(1, 1, 1)
	textoLabel.TextStrokeTransparency = 0
	textoLabel.Font = Enum.Font.SourceSansBold
	textoLabel.TextScaled = true
	textoLabel.Text = texto
	textoLabel.Parent = gui

	task.delay(4, function()
		if gui and gui.Parent then
			gui:Destroy()
		end
	end)
end

local function falar(texto, personagem)
	if SayMessageRequest then
		SayMessageRequest:FireServer(texto, "All")
	end
	criarBalãoDeFala(personagem, texto)
end

return falar
