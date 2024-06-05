local love = love
local lg = love.graphics

-- How many layers to draw.
local numLayers = 50

-- The distance between each layer on the Z axis.
local layerDistance = 0.05

-- The current Z position of the camera.
local cameraZ = 0

-- The speed at which the camera moves on the Z axis.
local cameraSpeed = 0.2

-- The radius of the holes in pixels.
local holeRadius = 30

-- A function that returns the X, Y coordinates of the tunnel's circle for a given Z coordinate.
local function tunnelOffset(z)
  return
      love.math.noise(z) * 130,
      love.math.noise(z + 1000) * 130
end

-- This variable is here just to give data to `holeStencil`, since it's not possible to pass data to stencil functions (in love 11.x)
local holeZ = 0
-- The function that draws a circle according to its tunnel position at `holeZ`.
local function holeStencil()
  local x, y = tunnelOffset(holeZ)
  lg.circle("fill", x, y, holeRadius)
end

-- At how many layers to fade completely to black.
local fadeDistance = 100

function love.update(dt)
  cameraZ = cameraZ + cameraSpeed * dt
end

function love.draw()
  -- How many layers the camera has passed through.
  local firstLayer = math.floor(cameraZ / layerDistance)

  -- How far away the camera's Z position is from the last layer.
  local inBetweenZ = cameraZ % layerDistance

  for layer = numLayers, 1, -1 do
    local z = layer * layerDistance - inBetweenZ
    local actualLayer = layer + firstLayer

    if z >= 0 then
      lg.push()
      lg.translate(lg.getWidth() / 2, lg.getHeight() / 2)
      lg.scale(1 / z, 1 / z)

      -- Move the camera to the center of the tunnel at the current Z position.
      local tx, ty = tunnelOffset(inBetweenZ + firstLayer * layerDistance + 0.1)
      lg.translate(-tx, -ty)

      holeZ = actualLayer * layerDistance
      lg.stencil(holeStencil, "replace", 1)

      lg.pop()

      lg.setStencilTest("equal", 0)
      local color = actualLayer % 2
      color = color * (1 - (layer - inBetweenZ / layerDistance) / fadeDistance) ^ 4 * 1.2
      lg.setColor(color, color, color)
      lg.rectangle("fill", 0, 0, lg.getDimensions())
      lg.setStencilTest()
    end
  end
end
