# Measurement Notes

## Prospect-theory value function

A common value-function form is:

v(x) = x^alpha for x >= 0
v(x) = -lambda * (-x)^beta for x < 0

where:

- alpha controls curvature for gains
- beta controls curvature for losses
- lambda controls loss aversion

## Hyperbolic discounting

A simple delay-discounting function is:

V = A / (1 + kD)

where:

- A = delayed amount
- D = delay
- k = discount rate

## Behavioral-choice probability

A logistic choice model can estimate the probability of choosing an option:

Pr(choice = 1) = logistic(beta0 + beta1 framing + beta2 default + beta3 cognitive_load + beta4 loss_domain)

## Recommended reliability checks

- Internal consistency for risk or time-preference tasks
- Stability of choices across repeated trials
- Sensitivity analysis for prospect-theory parameters
- Random participant effects for repeated observations
- Robustness checks across model specifications

## Recommended validity checks

- Convergent validity with established behavioral tasks
- Predictive validity for real or incentivized choices
- Ecological validity in field settings
- Distributional validity across demographic and institutional contexts
- Welfare analysis beyond choice uptake
