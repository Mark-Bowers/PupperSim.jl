# Actuator Parameters

##  gear
This attribute scales the length (and consequently moment arms, velocity and force) of the actuator, for all transmission types.
It is different from the gain in the force generation mechanism, because the gain only scales the force output and does not affect
the length, moment arms and velocity. For actuators with scalar transmission, only the first element of this vector is used.
The remaining elements are needed for joint, jointinparent and site transmissions where this attribute is used to specify 3D force
and torque axes.

## joint
This attribute determines the type of actuator transmission. If this attribute is specified, the actuator acts on the given joint.
For hinge and slide joints, the actuator length equals the joint position/angle times the first element of gear.

## kp
Position feedback gain.

## forcerange
Range for clamping the force output. The compiler expects the first value to be no greater than the second value.

# Experiments with forcerange and gear to get Hop to Work without Falling

|         | Gear  | Friction | Gainprm | Forcerange |  Notes                                           | Observations                      |
|---      |---    |---       |---      |---         |---                                               |---                                |
| Control | 1.0   | 0.25     | 1.0     |-3.0 3.0    | These were the Parameters set when we inherited the model. Gainprm not explicitly defined, but default is 1.                                                                             | Pupper crouches to correct height when attempting jump, does not slide while walking, but falls backward after landing, then slides around on his back                                                                                                                                       |
| Trial 1 | 1.0   | 0.25     | 5.0     | -3.0 3.0   | Drastically increase gainprm because 1st value of this vector is said to scale with force. Gear only scales with the force _output_.                                                       |                                   |
| Trial 2 |      |           |         |            |                                                  |                                   |
| Trial 3 |      |           |         |            |                                                  |                                   |
