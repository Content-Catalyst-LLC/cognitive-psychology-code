# Measurement Notes

## Calibration error

calibration_error = |confidence - accuracy|

When confidence and accuracy are on different scales, rescale both to [0, 1] before computing calibration error.

## Signed calibration

signed_calibration = confidence - accuracy

Positive values indicate overconfidence. Negative values indicate underconfidence.

## Monitoring-control loop

A simple monitoring-control loop can be represented as:

M_t = g(C_t)
C_{t+1} = f(C_t, M_t, S_t)

where C_t is a cognitive state, M_t is a monitoring judgment, and S_t is a strategy or regulatory action.

## Strategy shift model

Pr(strategy_shift = 1) = logistic(beta0 + beta1 uncertainty + beta2 task_difficulty - beta3 confidence + beta4 feedback_use)

## Study-time allocation

study_time_i = alpha + beta1 difficulty_i - beta2 confidence_i + beta3 learning_goal_i

## Recommended reliability checks

- Split-half reliability for confidence calibration
- Internal consistency for regulation scales
- Test-retest stability for metacognitive-awareness instruments
- Participant-level random effects for repeated trials
- Item-level random effects for task difficulty
- Sensitivity analysis across confidence scaling choices

## Recommended validity checks

- Convergent validity with strategy shifts, restudy choice, and study-time allocation
- Predictive validity for delayed recall or transfer
- Discriminant validity between confidence, accuracy, and response speed
- Ecological validity across educational, clinical, professional, and human-AI contexts
