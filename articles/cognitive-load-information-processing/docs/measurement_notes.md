# Measurement Notes

## Total load

L_total = L_i + L_e + L_g

where L_i is intrinsic load, L_e is extraneous load, and L_g is germane processing.

## Capacity constraint

L_total <= C

where C is available cognitive capacity.

## Overload margin

overload_margin = C - L_total

Negative values indicate likely overload.

## Probability of success

Pr(success) = logistic(beta0 + beta1 * (C - L_total))

## Element interactivity

Intrinsic load is more closely related to the number of interacting elements than the number of isolated elements.

L_i ∝ k

where k is the number of elements requiring simultaneous coordination.

## Extraneous load

Extraneous load may be modeled as a function of design inefficiency:

L_e = f(split_attention, redundancy, clutter, poor sequencing, ambiguity)

## Mental efficiency

A common z-score style formulation is:

E = (z_performance - z_effort) / sqrt(2)

Higher values indicate better performance with lower mental effort.

## Instructional efficiency

Instructional efficiency can be compared across conditions using performance and effort jointly rather than accuracy alone.

## NASA-TLX-style workload

A multidimensional workload profile may include:

- mental demand
- temporal demand
- effort
- frustration
- perceived performance
- physical demand where relevant

## Recommended reliability checks

- Internal consistency for multi-item load scales
- Split-half reliability for performance tasks
- Test-retest reliability when task conditions are stable
- Participant-level random effects for repeated trials
- Item or task random effects for difficulty
- Scale validity checks separating effort, frustration, and performance
- Response-time outlier checks

## Recommended validity checks

- Convergent validity between subjective effort and task complexity
- Discriminant validity between load and motivation
- Predictive validity for accuracy, error, transfer, and response time
- Expertise moderation checks
- Design manipulation checks
- Sensitivity analysis using performance-only, effort-only, and efficiency metrics
