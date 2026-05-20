# Measurement Notes

## Expected value

EV = sum(p_i * x_i)

Expected value is useful as a benchmark, but descriptive risk perception often departs from it.

## Subjective risk

R_s = sum(w(p_i) * v(x_i))

where w(p_i) is a psychological probability-weighting function and v(x_i) is subjective value.

## Loss aversion

v(x) = x^alpha for gains
v(x) = -lambda * (-x)^beta for losses

lambda > 1 indicates loss aversion.

## Affective risk

perceived_risk = beta0 + beta1 * subjective_probability + beta2 * consequence + beta3 * affect + beta4 * dread - beta5 * controllability

## Ambiguity

ambiguity_gap = perceived_risk_ambiguous - perceived_risk_known_probability

## Risk communication effect

communication_gain = perceived_clarity_post - perceived_clarity_pre

## Protective action

Pr(protective_action = 1) = logistic(beta0 + beta1 * perceived_risk + beta2 * trust + beta3 * controllability + beta4 * clarity - beta5 * cost)

## Recommended reliability checks

- Internal consistency for dread, trust, and affect scales
- Split-half reliability for risk-perception items
- Test-retest reliability when perceptions are expected to be stable
- Inter-rater reliability for coded open-ended risk explanations
- Participant-level random effects for repeated judgments
- Scenario-level random effects for hazard or message differences

## Recommended validity checks

- Predictive validity for safe choice or protective action
- Convergent validity with worry, perceived severity, and concern
- Discriminant validity between subjective probability and affect
- Calibration checks comparing subjective and objective probabilities
- Ecological validity across public health, climate, finance, technology, safety, and policy contexts
