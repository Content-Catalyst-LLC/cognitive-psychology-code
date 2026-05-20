# Research Protocol: Attention in Cognitive Psychology

## Purpose

This protocol supports empirical and simulated research on attention as a family of selection, prioritization, vigilance, orienting, control, and resource-allocation processes. It is intended for cueing tasks, visual search, continuous performance tasks, vigilance paradigms, divided-attention tasks, Stroop/flanker/Simon conflict tasks, attentional blink designs, HCI notification studies, safety monitoring, and human-AI attention-support experiments.

## Core constructs

### Cue validity

Cue validity records whether a cue is valid, neutral, or invalid relative to the eventual target. This supports orienting-benefit and reorienting-cost analysis.

### Signal present

Signal present records whether a target or critical signal was present on the trial.

### Response yes

Response yes records whether the participant judged that the signal was present.

### Correct

Correct records whether the response matched the target state.

### Reaction time

Reaction time records the latency between stimulus onset and response. It should be trimmed transparently.

### Block/time-on-task

Block records time-on-task and supports vigilance-decrement modeling.

### Salience

Salience measures bottom-up stimulus priority.

### Goal relevance

Goal relevance measures top-down task relevance.

### Distractor load

Distractor load measures competing irrelevant information.

### Perceptual load

Perceptual load measures difficulty or density in the perceptual task.

### Executive load

Executive load measures working-memory, inhibition, rule-maintenance, or control burden.

### Task switch

Task switch records whether the trial required a rule, task, or response-set change.

### Conflict

Conflict records competition between response tendencies.

### Vigilance state

Vigilance state estimates readiness, alertness, or sustained-attention capacity.

### Lapse probability

Lapse probability estimates risk of attentional failure.

### Confidence

Confidence records subjective certainty in the attentional judgment.

## Recommended study designs

1. Posner cueing task with valid, neutral, and invalid cues.
2. Visual search with set-size and distractor-similarity manipulation.
3. Continuous performance task with rare targets and time-on-task blocks.
4. Stroop/flanker/Simon task for executive attention and conflict.
5. Dual-task or divided-attention design.
6. Attentional blink task for temporal selection.
7. Notification-load experiment in an interface setting.
8. Safety-monitoring or medical-monitoring vigilance simulation.
9. Human-AI attention-support study measuring salience, trust, verification, and interruption.
10. Eye-tracking study of fixation, dwell time, revisits, and attentional priority.

## Measurement cautions

- Separate sensitivity from response bias using signal detection metrics.
- Analyze both accuracy and reaction time.
- Use participant-level and stimulus-level random effects where possible.
- Record time-on-task for vigilance studies.
- Record target prevalence; rare targets can shift criterion.
- Trim response times transparently and report sensitivity checks.
- Separate perceptual load from executive-control load.
- Distinguish attentional capture from intentional task relevance.
- In HCI and AI studies, distinguish attention support from interruption, overreliance, and alarm fatigue.

## Ethical and institutional considerations

Attention is a limited human capacity. Environments that overload, manipulate, fragment, or exploit attention can produce predictable failures. Responsible design should reduce unnecessary distraction, protect attentional resources in high-stakes settings, avoid manipulative salience, support accessibility, and make critical signals detectable without creating alarm fatigue.
