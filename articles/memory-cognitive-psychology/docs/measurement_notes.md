# Measurement Notes

## Exponential retention

m(t) = m_0 * exp(-lambda * t)

## Power-law retention

m(t) = a * (t + b)^(-c)

## Retrieval probability

Pr(retrieval) = logistic(beta0 + beta1 * memory_strength + beta2 * cue_quality - beta3 * interference)

## Retrieval-practice update

m_{k+1} = m_k + delta_k

## Signal detection

hit_rate = hits / old_items
false_alarm_rate = false_alarms / new_items
d_prime = z(hit_rate) - z(false_alarm_rate)
criterion = -0.5 * (z(hit_rate) + z(false_alarm_rate))

Apply correction when rates are 0 or 1.

## Source-memory accuracy

source_accuracy = correct_source_attributions / old_items_recognized

## Misinformation effect

misinformation_effect = false_memory_rate_misinformation - false_memory_rate_control

## Retrieval-practice effect

retrieval_practice_effect = retention_retrieval_practice - retention_restudy

## Recommended checks

Use participant- and item-level random effects, response-time trimming sensitivity, alternative forgetting curves, separate item/source memory analyses, and confidence-accuracy calibration.
