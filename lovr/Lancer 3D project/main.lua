lovr.mouse = require 'lovr-mouse'

local hex
local hexInstances = {}

--runs on load
function lovr.load()
  world = lovr.physics.newWorld()

  -- Load a 3D model
  hex = lovr.graphics.newModel('Hex.obj')
  hexHalf = lovr.graphics.newModel('HexHalf.obj')

  createHex(0, 1.5, -2)

  -- Changes background color
  lovr.graphics.setBackgroundColor(.4, .4, .4)
end

--Draw Graphics
function lovr.draw(pass)
  for _, instance in ipairs(hexInstances) do
    pass:draw(hex, instance.x, instance.y, instance.z)
  end
end

function lovr.update(dt)
  world:update(dt)

  local rightMouseDown = lovr.mouse.isDown(2)

  -- Detect a fresh right-click (button just pressed)
  if rightMouseDown and not wasRightMouseDown then
    local ox, oy, oz = lovr.headset.getPosition()
    local dx, dy, dz = lovr.headset.getDirection()

    local x = ox + dx * 2
    local y = oy + dy * 2
    local z = oz + dz * 2

    createHex(x, y, z)
    end

  -- Update debounce state
  wasRightMouseDown = rightMouseDown
end

--A Method to make the hexes
function createHex(x, y, z)
  table.insert(hexInstances, {x = x, y = y, z = z} )
  end

-- Method that checks whether there's a tile next to another tile
function checkNearby()
  -- raycast to each side to check if there's a tile around

  -- where there are no tiles, create spheres
end
