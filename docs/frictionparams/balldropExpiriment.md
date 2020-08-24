# Empirically Determining Contact Parameters to Model Friction

The goal of this experiment is to manually adjust the solver Parameters in the
geom default to get a sense of how they control dynamic friction between two bodies.

## What we Know About How MuJoCo Handles Friction

1) Friction is modeled as a damping force of a contact between two geometries, where
the contacts are modeled as an amalgam of harmonic oscillators between the two objects.
This intuitively seems realistic, as our Classical understanding of molecular physics
involves the "spring-like" interactions between valence electrons of the atoms
comprising the two materials which are rubbing or sliding.

2) MuJoCo defines a geom as a way to specify appearance and collision geometry and
 a body as a way to construct kinematic tree containers for other elements (incl
   geoms and sites)

3) Default tags allow user to introduce a change in one place and have it propagate
throughout the model. Balldrop.xml contains solimp, solref Parameters in the default tag
rather than in the geoms of the bodies themselves.

## Balldrop

The balldrop model is a simple model containing two spheres dropped onto a topographic
landscaped of varied heights. The potential and kinetic energies of the balls are
modeled as they fall into two valleys on the terrain. Our goal is to learn how to
precisely control the friction forces between the balls and the terrain. We know
from reading the MuJoCo docs that the solref contains two numbers, the first of which
is the time constant and the second of which is the damping ratio. We suspect that
varying the damping ratio will directly affect the amount of friction modeled between
the ball and terrain as the ball rolls, but we do not know how to calculate this
figure analytically. Secondly, there is a solimp Parameter, which includes two constraint
values and a time step. Lastly, friction can be explicitly stated for up to five degrees of
freedom (why five?)

Each run of our experiment changes a single value of each parameter against a control.

[Enter table of results]

[Embed videos]
