# Measurement Notes

## Resource allocation

sum_i a_i <= C

where a_i is attention assigned to item or task i and C is finite capacity.

## Saturating performance

P_i = alpha_i * a_i / (beta_i + a_i)

Performance improves with allocation but saturates.

## Priority weighting

w_i = exp(lambda_1 S_i + lambda_2 G_i + lambda_3 V_i + lambda_4 U_i)

where S is salience, G is goal relevance, V is learned value, and U is expected uncertainty reduction.

## Selection probability

Pr(i) = w_i / sum_j w_j

## Vigilance decay

A(t) = A_0 * exp(-k t) + epsilon_t

## Cueing effects

orienting_benefit = RT_neutral - RT_valid
reorienting_cost = RT_invalid - RT_neutral
total_validity_effect = RT_invalid - RT_valid

## Signal detection

hit_rate = hits / signal_trials
false_alarm_rate = false_alarms / noise_trials
d_prime = z(hit_rate) - z(false_alarm_rate)
criterion = -0.5 * (z(hit_rate) + z(false_alarm_rate))

Apply correction when rates are 0 or 1.

## Drift-diffusion style evidence accumulation

dx_t = v dt + s dW_t

Attention can affect drift rate, threshold, starting bias, or nondecision time.

## Lapse hazard

h(t) = h_0 * exp(gamma t)

where gamma > 0 indicates increasing risk of lapse over time.

## Recommended reliability checks

- Split-half reliability for cueing effects, d-prime, and response time
- Participant-level random effects
- Stimulus-level random effects
- Response-time trimming sensitivity
- Target-prevalence sensitivity
- Time-on-task sensitivity
- Confidence-accuracy calibration
- Eye-tracking validation where available

## Recommended validity checks

- Convergent validity across accuracy, d-prime, RT, and eye-tracking
- Discriminant validity between sensitivity and criterion
- Manipulation checks for cue validity, salience, load, and conflict
- Ecological validity in realistic monitoring, interface, or safety tasks
- Accessibility checks across sensory and cognitive ability profiles
