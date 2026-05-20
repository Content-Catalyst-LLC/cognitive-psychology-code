# Measurement Notes

## Bias as systematic deviation

B = J_hat - J_star

where J_hat is observed judgment and J_star is a normative, criterion, expert, or model-based benchmark.

## Absolute bias

|B| = abs(J_hat - J_star)

Useful when direction is less important than magnitude.

## Calibration error

calibration_error = abs(confidence_rating - actual_accuracy)

## Overconfidence

overconfidence = confidence_rating - actual_accuracy

Positive values indicate confidence exceeds accuracy.

## Anchoring effect

anchoring_effect = mean(estimate_high_anchor) - mean(estimate_low_anchor)

## Confirmation bias

confirmation_bias_index = proportion_confirming_evidence_selected - proportion_disconfirming_evidence_selected

## Base-rate neglect

base_rate_neglect = base_rate_weight_normative - base_rate_weight_observed

## Prospect-theory value function

v(x) = x^alpha for gains
v(x) = -lambda * abs(x)^beta for losses

where lambda > 1 indicates loss aversion.

## Probability weighting

w(p) = p^gamma / (p^gamma + (1 - p)^gamma)^(1/gamma)

Lower gamma can indicate stronger nonlinear probability weighting.

## Subjective value under risk

SV = sum_i w(p_i) * v(x_i)

## Debiasing effect

debiasing_effect = bias_pre - bias_post

Positive values indicate bias reduction.

## Recommended reliability checks

- Split-half reliability for judgment tasks
- Test-retest reliability for stable bias tendencies
- Participant-level random effects
- Item-level random effects
- Outlier checks for confidence, response time, and estimates
- Pre/post intervention reliability
- Cross-domain generalization checks

## Recommended validity checks

- Criterion validity against true outcomes
- Calibration curves for confidence judgments
- Process validity using evidence-search logs
- Discriminant validity among bias types
- Ecological validity using real-world decision tasks
- Sensitivity analysis with alternative normative benchmarks
