function lovr.load()
  world = lovr.physics.newWorld()

  -- Create the ground
  world:newBoxCollider(0, 0, 0, 5, .01, 5):setKinematic(true)

  -- Create boxes!
  boxes = {}
  for x = -1, 1, .25 do
    for y = .125, 2, .25 do
      local box = world:newBoxCollider(x, y, -1, .25)
      table.insert(boxes, box)
    end
  end

  -- Each controller is going to have a collider attached to it
  controllerBoxes = {}
end

function lovr.update(dt)
  -- Synchronize controllerBoxes with the active controllers
  for i, hand in ipairs(lovr.headset.getHands()) do
    if not controllerBoxes[i] then
      controllerBoxes[i] = world:newBoxCollider(0, 0, 0, .25)
      controllerBoxes[i]:setKinematic(true)
    end
    controllerBoxes[i]:setPosition(lovr.headset.getPosition(hand))
    controllerBoxes[i]:setOrientation(lovr.headset.getOrientation(hand))
  end

  -- Update the physics simulation
  world:update(dt)
end

-- A helper function for drawing boxes
function drawBox(pass, box)
  local x, y, z = box:getPosition()
  pass:cube(x, y, z, .25, quat(box:getOrientation()), 'line')
end

function lovr.draw(pass)
  pass:setColor(1.0, 0, 0)
  for i, box in ipairs(boxes) do
    drawBox(pass, box)
  end

  pass:setColor(0, 0, 1.0)
  for i, box in ipairs(controllerBoxes) do
    drawBox(pass, box)
  end
end