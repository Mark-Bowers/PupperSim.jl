# Actuator Parameters - Position Servos

**Note:** We do not use general actuators in our model, therefore, gain must be manipulated through kp.

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
Position feedback gain. For gaintype="fixed", gainprm="kp 0 0" and biastype="affine", biasprm="0 -kp 0". User-defined gaintypes are not
supported for position servos

## forcerange
Range for clamping the force output. The compiler expects the first value to be no greater than the second value.

# Experiments with forcerange and gear to get Hop to Work without Falling

|         | Gear  | Friction | kp      | Forcerange |  Notes                                           | Observations                      |
|---      |---    |---       |---      |---         |---                                               |---                                |
| Control | 1.0   | 0.25     | 300     |-3.0 3.0    | These were the Parameters set when we inherited the model. | Pupper crouches to correct height when attempting jump, does not slide while walking, but falls backward after landing, then slides around on his back.                                                                                                                                      |
| Trial 1 | 1.0   | 0.25     |  300    | Unlimited  | Set forcelimited to "false" because we suspect Pupper is not putting enough force on his joints.                                         | Pupper has too much bounce when he hops. He does a back flip which he cannot land.                                                                                                                                      |
| Trial 2 | 1.0   | 0.25     | 1500    | -3.0 3.0   | Drastically increase gainprm because 1st value of this vector is said to scale with force. Gear only scales with the force _output_. Reset forcerange to control value. | Pupper walks slightly crooked and doesn't fall entirely backward after hop. |
| Trial 3 | 1.0   | 0.25     | 1500    | -15.0 15.0 | Maintain high gain, but also scale forcerange with the gain because we suspect force is being suppressed too much even though gain is high. | Pupper falls to side before hop attempt can be made. It seems like forcerange is too high. |
| Trial 4 | 1.0   | 0.25     | 1500    | -9.0 9.0 | Maintain high gain, but suppress force range more. | Pupper is a little uneasy getting up and still falls backward after hop. It seems kp is too high. |
| Trial 5 | 1.0   | 0.25     | 900    | -9.0 9.0 | Reduce gain to scale with forcerange. | Pupper is a little uneasy getting up and still falls backward after hop. It seems forces on front legs should be less than on back legs. |
| Trial 6 | 1.0   | 0.25     | 750 (front)/ 900 (back)    | -7.5 7.5 (front) -9.0 9.0 (back)| Adjust front legs to have less force than back. | Pupper does not fall when attempting hop. However, he doesn't catch much (if any) air either. Legs don't appear completely straight when hopping either.|
| Trial 7 | 1.0   | 0.25     | 750 (front x, y2)/ 900 (front y) / 900 (back x, y2) / 1500 (back y)    | -7.5 7.5 (front x, y2)/ -9.0 9.0 (front y) / -9.0 9.0 (back x, y2) / -15.0 15.0 (back y) | Adjust y joint on all four legs to have +300 gain. Scale Forcerange with gain. | Pupper falls forward implying too much force on back legs. |
| Trial 8 | 1.0   | 0.25     | 750 (front x, y2)/ 900 (front y) / 900 (back)    | -7.5 7.5 (front x, y2)/ -9.0 9.0 (front y) / -9.0 9.0 (back) | Maintain same Forcerange and gain on front legs. Reduce force on y joint on back legs. | Lands ok on initial fall, but falls backward on initial attempt to trot. |
| Trial 9 | 1.0   | 0.25     | 750 (front x, y)/ 900 (front y2) / 900 (back x, y) / 1500 (back y2)    | -7.5 7.5 (front x, y)/ -9.0 9.0 (front y2) / -9.0 9.0 (back x, y) / -15.0 15.0 (back y2) | Maintain force on front legs. Increase y2 joint on back legs | Pupper does not fall, but initial time getting up and recovery from hop are very unstable. Also, hop not very high. |
| Trial 10 | 2.0   | 0.25     | 750 (front x, y)/ 900 (front y2) / 900 (back x, y) / 1500 (back y2)    | -7.5 7.5 (front x, y)/ -9.0 9.0 (front y2) / -9.0 9.0 (back x, y) / -15.0 15.0 (back y2) |Increase gear, which affects force output. | Falls when attempting to trot and slides on back. |
| Trial 10 | 1.5   | 0.25     | 750 (front x, y)/ 900 (front y2) / 900 (back x, y) / 1500 (back y2)    | -7.5 7.5 (front x, y)/ -9.0 9.0 (front y2) / -9.0 9.0 (back x, y) / -15.0 15.0 (back y2) |Decrease gear because high gear also makes him slide more | Can hop a few times without falling, but highly unstable, eventually falls after multiple successive hops. |
