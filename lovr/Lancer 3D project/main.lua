lovr.mouse = require 'lovr-mouse'

function lovr.load()
  world = lovr.physics.newWorld()

  -- Load a 3D model
  hex = lovr.graphics.newModel('Hex.obj')

  hexHalf = lovr.graphics.newModel('HexHalf.obj')
  -- Use a dark grey background
  lovr.graphics.setBackgroundColor(.2, .2, .2)

  controllerBoxes = {}
end

-- A helper function for drawing boxes
function drawBox(pass, box)
  local x, y, z = box:getPosition()
  pass:cube(x, y, z, .25, quat(box:getOrientation()), 'line')
end

function lovr.draw(hexPass)
  -- Draw the model
  hexPass:setColor(0.9, 0.9, 0.9, 1)
  hexPass:draw(hex, -.5, 1, -3, 1)

  hexPass:setColor(0, 0, 1.0)
  for i, box in ipairs(controllerBoxes) do
    drawBox(hexPass, box)
  end
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

  if lovr.mouse.isDown(2) then
    instance(hex, controllerBoxes, controllerBoxes, controllerBoxes, 1)
  else
    return
  end

  -- Update the physics simulation
  world:update(dt)


end
