# Measurement Notes

## Cognitive-system performance index

A simple research index can be constructed as:

CSP = prediction_accuracy + action_success + representation_quality + explanation_score - policy_entropy - normalized_retrieval_latency

A more cautious version can include human-centered terms:

CSP = w_a A + w_s S + w_r R + w_e E - w_p P - w_l L - w_c C

where:

- A = prediction accuracy
- S = action success
- R = representation quality
- E = explanation score
- P = policy entropy
- L = retrieval latency
- C = calibration error

## Recommended reliability checks

- Inter-rater reliability for explanation ratings
- Task-level reliability across repeated trials
- Stability of architecture effects across uncertainty levels
- Sensitivity analysis for index weights
- Robustness to missingness and non-normal response times

## Recommended validity checks

- Convergent validity with task performance
- Discriminant validity from explanation fluency alone
- Predictive validity for human override behavior
- Ecological validity in realistic human-AI collaboration tasks
- Calibration analysis across confidence bins

## Interpretation cautions

- A system can be accurate but cognitively opaque.
- A system can be interpretable but unreliable.
- A system can be useful while still requiring human oversight.
- A system can produce fluent explanations that are not faithful to the actual computation.
