local love = love
local lg = love.graphics

-- How many layers to draw.
local numLayers = 50

-- The distance between each layer on the Z axis.
local layerDistance = 0.05

-- The current Z position of the camera.
local cameraZ = 0

local cameraSpeed = 0.2

local zOffset = 0

local holeRadius = 30

local function tunnelOffset(z)
  return
      love.math.noise(z) * 130,
      love.math.noise(z + 1000) * 130
end

local holeZ = 0
local function holeStencil()
  local x, y = tunnelOffset(holeZ)
  lg.circle("fill", x, y, holeRadius)
end

function love.update(dt)
  cameraZ = cameraZ + cameraSpeed * dt
  if cameraZ >= layerDistance then
    cameraZ = cameraZ % layerDistance
    zOffset = zOffset + 1
  end
end

function love.draw()
  for layer = numLayers, 1, -1 do
    local z = layer * layerDistance - cameraZ
    local actualLayer = layer + zOffset

    if z >= 0 then
      lg.push()
      lg.translate(lg.getWidth() / 2, lg.getHeight() / 2)
      lg.scale(1 / z, 1 / z)
      local tx, ty = tunnelOffset(cameraZ + zOffset * layerDistance + 0.1)
      lg.translate(-tx, -ty)

      holeZ = actualLayer * layerDistance
      lg.stencil(holeStencil, "replace", 1)

      lg.pop()

      lg.setStencilTest("equal", 0)
      local color = actualLayer % 2
      color = color * (1 - (layer - cameraZ / layerDistance) / numLayers) ^ 4 * 1.2
      lg.setColor(color, color, color)
      lg.rectangle("fill", 0, 0, lg.getDimensions())
      lg.setStencilTest()
    end
  end
end
