# Measurement Notes

## Problem-space model

A problem can be represented as:

P = (S, s_0, G, O, C)

where:

- S = state space
- s_0 = initial state
- G = goal condition
- O = available operators
- C = constraints

## State transition

A solver moves through a problem space by selecting operators:

s_{t+1} = T(s_t, o_t)

where o_t is an operator and T is a transition function.

## Means-end analysis

Means-end search can be represented as:

o_t = argmin_o d(T(s_t, o), g)

where d measures distance from the candidate next state to the goal.

## Strategy selection

A strategy-selection model can estimate:

Pr(strategy = k) ∝ exp(beta_1 usefulness_k - beta_2 effort_k + beta_3 familiarity_k)

## Recommended reliability checks

- Inter-rater reliability for representation-quality and strategy codes
- Item-level random effects for problem heterogeneity
- Participant-level random effects for repeated trials
- Sensitivity analysis for strategy-classification rules
- Robustness checks across well-structured and ill-structured problems

## Recommended validity checks

- Convergent validity with response time, accuracy, and verbal protocols
- Predictive validity for later transfer or expert-rated solution quality
- Discriminant validity between confidence and objective solution quality
- Ecological validity in real-world domains such as education, design, engineering, medicine, and policy
