# Measurement Notes

## Incremental comprehension

Language comprehension can be represented as an incremental update:

I_t = f(I_{t-1}, x_t, K, C)

where I_t is the interpretation state, x_t is the incoming linguistic unit, K is stored linguistic and world knowledge, and C is discourse context.

## Parsing as structural inference

S_hat = argmax_i P(S_i | X, C)

where S_i is a candidate syntactic structure, X is the observed input sequence, and C is context.

## Semantic composition

M = g(W, S_hat, C)

where W contains lexical meanings, S_hat contains selected structural relations, and C contains context.

## Production

Y = h(G, K, C)

where G is communicative intention, K is lexical and grammatical knowledge, and C is discourse context.

## Reading-time model

A simplified reading-time model can estimate:

log(RT) = beta0 - beta1 word_frequency + beta2 syntactic_complexity - beta3 semantic_predictability + beta4 working_memory_load + beta5 lexical_ambiguity

## Recommended reliability checks

- Split-half reliability for item sets
- Item-level random effects for words, sentences, or passages
- Participant-level random effects for repeated trials
- Robustness across modalities, conditions, and trimming rules
- Sensitivity analysis for response-time exclusion thresholds

## Recommended validity checks

- Convergent validity with comprehension accuracy and response time
- Predictive validity for later recall or transfer
- Discriminant validity between lexical access, syntactic parsing, semantic integration, and pragmatic inference
- Ecological validity for reading, speech, conversation, writing, translation, interface use, and AI-mediated language systems
