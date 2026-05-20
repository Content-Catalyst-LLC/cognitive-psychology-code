# Measurement Notes

## Prototype model

A simple prototype model assigns an item to the closest prototype:

C_hat(x) = argmin_k d(x, p_k)

where x is an item vector and p_k is the prototype for category k.

## Exemplar model

An exemplar model compares a new item to stored category examples:

S_k(x) = sum_i exp(-lambda * d(x, x_i))

where x_i are exemplars in category k.

## Generalization update

A simple learning update can be written as:

P_{t+1}(C_k | x) = P_t(C_k | x) + alpha * Delta

where alpha is a learning rate and Delta is the prediction or feedback-driven update.

## Boundary ambiguity

Boundary ambiguity can be represented by the difference between the two strongest category scores:

B(x) = 1 - |S_1(x) - S_2(x)| / (S_1(x) + S_2(x))

Higher values indicate a more ambiguous boundary case.

## Recommended reliability checks

- Inter-rater reliability for open-ended concept definitions
- Split-half reliability for category-strength ratings
- Internal consistency for abstraction-quality or conceptual-flexibility scales
- Item-level random effects for exemplar difficulty
- Participant-level random effects for repeated trials
- Sensitivity analysis for prototype-distance and feature-weight assumptions

## Recommended validity checks

- Convergent validity with category accuracy, response time, and generalization
- Predictive validity for transfer to novel examples
- Discriminant validity between memorization and conceptual abstraction
- Ecological validity in educational, clinical, organizational, interface, and AI settings
