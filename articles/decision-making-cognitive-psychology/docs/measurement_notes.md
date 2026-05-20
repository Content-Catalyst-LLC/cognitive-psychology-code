# Measurement Notes

## Expected value

EV_i = sum_j p_j x_j

where p_j is outcome probability and x_j is outcome magnitude.

## Expected utility

EU_i = sum_j p_j u(x_j)

where u(x_j) is subjective utility of the outcome.

## Prospect-theory value function

v(x) = x^alpha for gains
v(x) = -lambda * abs(x)^beta for losses

where lambda > 1 indicates loss aversion.

## Probability weighting

w(p) = p^gamma / (p^gamma + (1 - p)^gamma)^(1/gamma)

Lower gamma can indicate stronger nonlinear probability weighting.

## Subjective value

SV = sum_j w(p_j) * v(x_j - r)

where r is a reference point.

## Risky choice

Pr(risky) = logistic(beta0 + beta1 * SV + beta2 * frame + beta3 * cognitive_load + ...)

## Evidence accumulation

dx_t = v dt + s dW_t

where v is drift rate, s is noise scale, and dW_t is a Wiener increment.

## Threshold response

A decision occurs when accumulated evidence crosses +a or -a.

## Speed-accuracy trade-off

Higher thresholds can increase accuracy but lengthen response time.

## Decision quality

decision_quality = f(correctness, expected value alignment, calibration, confidence, uncertainty, feedback)

## Verification burden

verification_burden = time + effort + evidence checks + uncertainty resolution required to audit an external recommendation.

## Recommended reliability checks

- Split-half reliability for risky-choice tasks
- Test-retest reliability for stable preference parameters
- Participant-level random effects
- Item-level random effects
- Response-time trimming and sensitivity checks
- Confidence calibration analysis
- Cross-condition manipulation checks

## Recommended validity checks

- Criterion validity against optimal or expert choice
- Calibration curves
- Convergent validity across choice, response time, and confidence
- Ecological validity using naturalistic scenarios
- Sensitivity analysis with EV, EU, and prospect-theory specifications
- Human-AI verification checks where AI assistance is used
