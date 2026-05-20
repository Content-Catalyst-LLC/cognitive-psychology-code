# Measurement Notes

## Bayesian perception

P(h | x) = P(x | h) P(h) / P(x)

Perceptual hypotheses are shaped by sensory evidence and prior expectations.

## Softmax perceptual selection

w_i = exp(lambda_1 E_i + lambda_2 Q_i + lambda_3 A_i + lambda_4 C_i)

Pr(i) = w_i / sum_j w_j

where E is evidence, Q is prior expectation, A is attentional gain, and C is contextual compatibility.

## Prediction error

delta_t = x_t - xhat_t

Prediction error measures mismatch between incoming input and predicted input.

## Model updating

M_{t+1} = M_t + alpha * delta_t

where alpha is learning rate.

## Signal detection

hit_rate = hits / signal_trials
false_alarm_rate = false_alarms / noise_trials
d_prime = z(hit_rate) - z(false_alarm_rate)
criterion = -0.5 * (z(hit_rate) + z(false_alarm_rate))

Apply correction when rates are 0 or 1.

## Psychometric curve

Pr(response_yes) = logistic(beta0 + beta1 * stimulus_level + beta2 * condition)

Threshold can be approximated as the stimulus level where predicted probability equals 0.5.

## Visual search

RT = beta0 + beta1 * set_size + beta2 * distractor_similarity + beta3 * target_absent

Steeper set-size slopes often indicate more difficult search.

## Recommended reliability checks

- Split-half reliability for thresholds and d-prime
- Participant-level random effects
- Stimulus-level random effects
- Response-time trimming sensitivity
- Threshold stability across blocks
- Psychometric curve fit diagnostics
- Confidence-accuracy calibration

## Recommended validity checks

- Convergent validity across accuracy, d-prime, threshold, and response time
- Discriminant validity between sensory sensitivity and response bias
- Ecological validity in realistic visual, auditory, clinical, or interface tasks
- Manipulation checks for attention, prior expectation, or context
- Accessibility checks across sensory and cognitive ability profiles
