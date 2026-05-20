# Measurement Notes

## Mental-model representation

A simplified mental model can be represented as:

M = (E, R, T, B)

where E is a set of entities, R is a set of relations, T is a set of transition rules, and B is a boundary condition.

## Prediction

A model can be used to forecast the next state:

s_hat[t+1] = f(M, s[t], a[t])

where s[t] is the current state, a[t] is an action or intervention, and s_hat[t+1] is the predicted next state.

## Prediction error

prediction_error = |observed_state - predicted_state|

Lower prediction error suggests better model fit, assuming the target outcome was measured appropriately.

## Model revision

revision_gain = pre_feedback_prediction_error - post_feedback_prediction_error

Positive values indicate improvement after feedback.

## Structural similarity

transfer_success often depends on structural similarity across domains:

transfer_score ~ model_quality * structural_similarity

## Recommended reliability checks

- Inter-rater reliability for coded diagrams and explanations
- Split-half reliability for model-quality items
- Test-retest stability for system-understanding tasks
- Item-level random effects for scenario difficulty
- Participant-level random effects for repeated reasoning tasks
- Sensitivity analysis across coding rubrics for causal links and feedback loops

## Recommended validity checks

- Predictive validity for future problem-solving success
- Convergent validity with explanation quality and intervention accuracy
- Discriminant validity between confidence and accuracy
- Ecological validity in systems, policy, interface, scientific, clinical, organizational, and AI-assisted contexts
