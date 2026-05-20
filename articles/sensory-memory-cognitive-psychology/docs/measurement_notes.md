# Measurement Notes

## Trace decay

A simple sensory trace decay model:

s(t) = s0 * exp(-lambda * t)

where s0 is initial trace strength, lambda is the decay rate, and t is time after stimulus offset.

## Selection probability

A softmax selection model:

Pr(i) = exp(beta1*s_i + beta2*v_i + beta3*a_i) / sum_j exp(beta1*s_j + beta2*v_j + beta3*a_j)

where s_i is trace strength, v_i is salience, and a_i is attentional priority.

## Threshold transfer

T_i = 1 if s_i + a_i >= theta; otherwise 0

where T_i indicates transfer to later processing.

## Partial-report advantage

partial_report_advantage = partial_report_score - whole_report_score

## Modality-specific decay

Typical empirical modeling should allow different decay rates by modality:

s_m(t) = s0_m * exp(-lambda_m * t)

where m indicates visual, auditory, or tactile modality.

## Recommended reliability checks

- Split-half reliability for report accuracy
- Test-retest reliability for sensory persistence estimates
- Participant-level random effects for repeated trials
- Stimulus-level random effects for item difficulty
- Modality-specific residual checks
- Outlier checks for response time and inattentive trials

## Recommended validity checks

- Compare whole-report and partial-report performance
- Verify cue-delay decay patterns
- Include no-mask and mask conditions
- Check whether report accuracy exceeds guessing
- Validate whether cue validity affects selection
- Distinguish immediate sensory trace from delayed working-memory maintenance
