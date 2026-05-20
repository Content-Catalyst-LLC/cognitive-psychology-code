# Measurement Notes

## Structure-mapping score

A simplified mapping-quality score can be written as:

A(S,T) = sum_i w_i * match(R_i^S, R_i^T)

where R_i^S is a source relation, R_i^T is a target relation, and w_i is the importance weight of the relation.

## Surface-structure dissociation

Analogical reasoning studies should distinguish:

- surface similarity: shared labels, objects, or perceptual attributes
- structural similarity: shared relational, causal, functional, or logical organization

A misleading analogy often has high surface similarity but low structural fit.

## Transfer-success model

A basic transfer model can estimate:

Pr(transfer = 1) = logistic(beta0 + beta1 structural_similarity + beta2 source_familiarity - beta3 relational_complexity - beta4 working_memory_load + beta5 analogical_cue)

## Recommended reliability checks

- Inter-rater reliability for mapping and inference-quality codes
- Item-level random effects for problem heterogeneity
- Participant-level random effects for repeated trials
- Sensitivity analysis for relation weights in mapping scores
- Robustness across surface-similar and structurally similar item subsets

## Recommended validity checks

- Convergent validity with established transfer tasks
- Predictive validity for later problem solving or concept learning
- Discriminant validity between analogy, simple similarity, and memorized retrieval
- Ecological validity in education, science, law, policy, or design contexts
