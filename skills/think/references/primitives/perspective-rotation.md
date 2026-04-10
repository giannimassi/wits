# Perspective Rotation

From Red Team Analysis (CIA/military) + DSRP Perspectives (Cabrera) + Structured Perspective-Taking
(Galinsky & Moskowitz). Problems look different depending on where you stand.

## When to use

You're solving from your own viewpoint and might be missing how the problem looks to
other stakeholders, users, adversaries, or future-you.

## Protocol

1. **Identify 3+ perspectives** relevant to this problem. Consider:
   - The end user / customer / person affected
   - The adversary / competitor / person who benefits from your failure
   - The maintainer / person who inherits this in 6 months
   - The skeptic / person who thinks this whole approach is wrong
   - A domain expert from an adjacent field

2. **For each perspective**, answer:
   - What does this problem look like from here?
   - What information do they have that I don't (or vice versa)?
   - What would they consider a success? A failure?
   - What's their biggest objection or concern?

3. **Synthesize**: What did the rotation reveal that you didn't see from your original
   position? Any new constraints, risks, or opportunities?

## Output format

```
PERSPECTIVES:
- [role]: sees [what they see], worries about [concern], would want [outcome]
- [role]: ...
BLIND SPOTS REVEALED: [what you missed from your original viewpoint]
INTEGRATION: [how this changes your approach]
```
