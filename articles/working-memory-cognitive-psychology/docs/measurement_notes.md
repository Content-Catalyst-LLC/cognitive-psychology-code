# Measurement Notes

## Capacity constraint

sum_i a_i <= C

where a_i is resource allocation to item or process i and C is total available capacity.

## Overload

overload = max(0, load - capacity_estimate)

## Accuracy decline with load

Pr(correct) = logistic(beta0 + beta1 * capacity - beta2 * load - beta3 * interference + beta4 * attentional_control)

## Gated updating

W_t = g_t * X_t + (1 - g_t) * W_{t-1}

where W_t is current working-memory state, X_t is incoming information, and g_t is the update gate.

## Dual-task cost

dual_task_cost = single_task_accuracy - dual_task_accuracy

## Response-time load effect

log(RT) = beta0 + beta1 * load + beta2 * updating_demand + beta3 * interference + beta4 * cognitive_load

## Span score

span_score = maximum load at which recall accuracy meets a criterion threshold.

## Capacity estimate from change detection

K = set_size * (hit_rate - false_alarm_rate)

## Cognitive load decomposition

total_load = intrinsic_load + extraneous_load + germane_load

## Recommended reliability checks

- Split-half reliability for span and updating tasks
- Test-retest reliability when capacity is treated as an individual-difference measure
- Participant-level random effects
- Item-level random effects
- Response-time trimming sensitivity
- Serial-position sensitivity
- Modality-specific checks

## Recommended validity checks

- Convergent validity across span, updating, and complex-span tasks
- Discriminant validity from general processing speed
- Criterion validity with reasoning, comprehension, learning, or decision tasks
- Ecological validity in realistic learning/interface environments
- Sensitivity analysis with alternative capacity models
