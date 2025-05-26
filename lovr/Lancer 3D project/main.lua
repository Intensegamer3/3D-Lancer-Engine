lovr.mouse = require 'lovr-mouse'

local hex
local hexInstances = {}
local placementSpheres = {}
local hexMap = {}
local wasRightMouseDown = false

-- Flat-topped hex geometry
local HEX_SIZE = 1
local SQRT3 = math.sqrt(3)

function axialToWorld(q, r)
  local x = HEX_SIZE * SQRT3 * (q + r / 2)
  local z = HEX_SIZE * 3/2 * r
  return x, 0, z
end

function worldToAxial(x, z)
  local q = (SQRT3/3 * x - 1/3 * z) / HEX_SIZE
  local r = (2/3 * z) / HEX_SIZE
  return axialRound(q, r)
end

-- Rounds fractional axial coords to nearest hex
function axialRound(q, r)
  local x = q
  local z = r
  local y = -x - z

  local rx = math.floor(x + 0.5)
  local ry = math.floor(y + 0.5)
  local rz = math.floor(z + 0.5)

  local dx = math.abs(rx - x)
  local dy = math.abs(ry - y)
  local dz = math.abs(rz - z)

  if dx > dy and dx > dz then
    rx = -ry - rz
  elseif dy > dz then
    ry = -rx - rz
  else
    rz = -rx - ry
  end

  return rx, rz
end

-- Load assets and create world
function lovr.load()
  world = lovr.physics.newWorld()
  hex = lovr.graphics.newModel('Hex.obj')
  lovr.graphics.setBackgroundColor(.4, .4, .4)
  createHex(0, 0)
end

-- Draw hexes and placement spheres
function lovr.draw(pass)
  for _, instance in ipairs(hexInstances) do
    pass:draw(hex, instance.x, instance.y, instance.z)
  end

  pass:setColor(1.0, 0.5, 0.0)
  for _, s in ipairs(placementSpheres) do
    pass:sphere(s.x, s.y, s.z, 0.1)
  end
  pass:setColor(1, 1, 1)
end

-- Update physics and handle input
function lovr.update(dt)
  world:update(dt)

  local rightMouseDown = lovr.mouse.isDown(2)

  if rightMouseDown and not wasRightMouseDown then
    local ox, oy, oz = lovr.headset.getPosition()
    local dx, dy, dz = lovr.headset.getDirection()

    local x = ox + dx * 2
    local z = oz + dz * 2

    local q, r = worldToAxial(x, z)
    createHex(q, r)
  end

  --wasRightMouseDown = rightMouseDown
end

-- Handle mouse clicks on placement spheres
function lovr.mousepressed(x, y, button)
  if button == 1 then
    local ox, oy, oz = lovr.headset.getPosition()
    local dx, dy, dz = lovr.headset.getDirection()

    for i, s in ipairs(placementSpheres) do
      if rayIntersectsSphere(ox, oy, oz, dx, dy, dz, s.x, s.y, s.z, 0.15) then
        createHex(s.q, s.r)
        table.remove(placementSpheres, i)
        break
      end
    end
  end
end

-- Function to edit the color for the hexes
function colorHex()
  --DO IT
end

-- Create a new hex tile and generate neighbor spheres
function createHex(q, r)
  local key = q .. ',' .. r
  if hexMap[key] then return end

  local x, y, z = axialToWorld(q, r)
  local collider = world:newBoxCollider(x, y, z, 1.0, 0.5, 1.0)
  collider:setKinematic(true)

  table.insert(hexInstances, {
    x = x,
    y = y,
    z = z,
    q = q,
    r = r,
    collider = collider
  })

  hexMap[key] = true
  checkNearby(q, r)
end

-- Check all 6 neighboring tiles
function checkNearby(q, r)
  local directions = {
    { 1, 0 }, { 1, -1 }, { 0, -1 },
    { -1, 0 }, { -1, 1 }, { 0, 1 }
  }

  for _, dir in ipairs(directions) do
    local nq, nr = q + dir[1], r + dir[2]
    local key = nq .. ',' .. nr
    if not hexMap[key] and not sphereExists(nq, nr) then
      local x, y, z = axialToWorld(nq, nr)
      table.insert(placementSpheres, {
        x = x,
        y = y,
        z = z,
        q = nq,
        r = nr
      })
    end
  end
end

-- Check if a placement sphere already exists
function sphereExists(q, r)
  for _, s in ipairs(placementSpheres) do
    if s.q == q and s.r == r then
      return true
    end
  end
  return false
end

-- Ray-sphere intersection helper
function rayIntersectsSphere(ox, oy, oz, dx, dy, dz, cx, cy, cz, radius)
  local px, py, pz = cx - ox, cy - oy, cz - oz
  local dot = px * dx + py * dy + pz * dz
  if dot < 0 then return false end

  local closestX = ox + dx * dot
  local closestY = oy + dy * dot
  local closestZ = oz + dz * dot

  local distSq = (closestX - cx)^2 + (closestY - cy)^2 + (closestZ - cz)^2
  return distSq <= radius^2
end
