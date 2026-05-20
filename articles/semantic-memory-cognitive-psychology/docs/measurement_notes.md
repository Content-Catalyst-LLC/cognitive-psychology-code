# Measurement Notes

## Semantic graph

Semantic memory can be represented as:

S = (V, E, W)

where:

- V = concepts or nodes
- E = relations or edges
- W = relation weights, association strength, or similarity

## Spreading activation

A simple spreading-activation update can be written as:

a_{t+1} = gamma W a_t

where a_t is the activation vector, W is the weighted adjacency matrix, and gamma is a propagation or decay parameter.

## Semantic similarity

A common distance-to-similarity transformation is:

sim(x, y) = exp(-lambda * d(x, y))

where d(x, y) is distance between concept representations.

## Verification model

A semantic verification model can estimate:

Pr(accuracy = 1) = logistic(beta0 - beta1 semantic_distance + beta2 fact_true + beta3 category_typicality + beta4 cue_strength - beta5 false_association)

## Recommended reliability checks

- Split-half reliability for category-strength ratings
- Internal consistency for semantic relatedness scales
- Item-level random effects for concept and proposition heterogeneity
- Participant-level random effects for repeated trials
- Robustness across taxonomic, thematic, functional, and associative relations

## Recommended validity checks

- Convergent validity with established semantic relatedness norms
- Predictive validity for verification latency and accuracy
- Discriminant validity between semantic truth, association, and episodic familiarity
- Ecological validity in language, education, search, clinical, and AI contexts
