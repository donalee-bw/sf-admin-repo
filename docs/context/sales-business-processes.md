# Business Processes

> **Architect**: Populated from the brightwheel [OFFICIAL] Sales Playbook.
> Last refreshed: 2026-03-31

---

## Sales motions

### Motion 1: Inbound AE (IB AE)

- **Entry point**: Inbound lead submits a form or books a meeting directly; lead is routed via LeanData to an IB AE queue
- **Salesforce objects used**: Lead (pre-conversion), Opportunity (post-conversion), Account, Contact
- **Key stages**: See Pipeline Stages table below. Starts at Live Conversation → Demo Scheduled → Demo Held → Awaiting Decision → SSPR Collection → OBE → Closed Won
- **Cadences/sequences** (Outreach):
  - *Sales-IB PTL* — for Partner/Teacher Leads before first contact
  - *Missed Demo* — when a scheduled demo is not attended
  - *Open Opp No Follow Up Scheduled* — open opp with no next step booked
  - *Open Opp Missed Follow Up* — follow-up date passed with no activity
  - *Keep Warm* — for prospects not ready to buy yet (pauses neglect/auto-close clock)
  - *Post Connection Follow Up* — after a connected call that did not result in a demo
- **Exit criteria**: Closed Won (OBE reached, contract executed) or Closed Lost (disqualified, unresponsive, or prospect chose competitor). Auto-close lost triggered after 14 days of neglect (see Known Process Issues).

---

### Motion 2: Outbound AE (OB AE)

- **Entry point**: AE self-sources or works leads from the Outbound Leads Queue; may receive warm transfers from SDRs
- **Salesforce objects used**: Lead, Opportunity, Account, Contact
- **Key stages**: Same Opportunity stage progression as IB AE
- **Cadences/sequences**: Same cadence set as IB AE; OB AEs additionally rely on manual dial blocks tracked via WIN score (Dials + Talk Time)
- **Exit criteria**: Same as IB AE. WIN score is a performance metric for OB effort — no automated gate in SFDC.

---

### Motion 3: Inbound SDR (IB SDR)

- **Entry point**: High-volume inbound lead (MQL) routed to an SDR queue via LeanData; SDR makes first contact and qualifies
- **Salesforce objects used**: Lead (SDRs work Leads, not Opportunities; AE converts after handoff)
- **Key stages** (on Lead, via Outreach Stage field):
  - *New* — just routed, no action yet
  - *Assigned* — in SDR's queue
  - *Working* — SDR has attempted contact
  - *Added to Sequence* — enrolled in an Outreach cadence
  - *Connected* — verbal/meeting connection made; ready for AE handoff
- **Cadences/sequences**: SDR cadences in Outreach (inbound-specific sequences; not named in playbook)
- **Exit criteria**: Converted Lead → Opportunity assigned to AE (Connected + meeting booked), or Disqualified (unqualified/DNC/wrong contact).

---

### Motion 4: Brand New Program (BNP)

- **Entry point**: Prospect self-identifies as a Brand New Program (not yet open); flagged via BNP picklist or lead source
- **Salesforce objects used**: Lead, Opportunity (BNP-specific record type or stage path), Account
- **Key stages**: Parallel funnel to O&O motion; BNP opps do not advance to OBE until the program has opened
- **Cadences/sequences**:
  - *BNP Keep Warm - Not Ready* — program not yet open, nurture until ready
  - *BNP Keep Warm - Unqualified* — disqualified now but may requalify when open
- **Exit criteria**: Program opens → transition to standard O&O Opportunity flow, or lost if program never opens / loses interest.

---

## Pipeline stages

### Opportunity stages (O&O / standard path)

| Stage | Object | Meaning | Next stage |
|-------|--------|---------|------------|
| Live Conversation | Opportunity | AE has spoken live with a decision maker; demo not yet scheduled | Demo Scheduled |
| Demo Scheduled | Opportunity | Demo meeting booked on calendar | Demo Held |
| Demo Held | Opportunity | Demo was completed; prospect evaluating | Awaiting Decision |
| Awaiting Decision | Opportunity | Prospect is deciding; follow-up in progress | SSPR Collection |
| SSPR Collection | Opportunity | Prospect committed; collecting Students, Staff, Parents (Roster) data to reach OBE status | OBE |
| OBE (Onboarding Eligible) | Opportunity | All SSPR data collected; ready to hand to Onboarding | Closed Won |
| Closed Won | Opportunity | Contract executed; account handed to Onboarding team | — |
| Closed Lost | Opportunity | Prospect disqualified, unresponsive, or chose competitor | — |

> **Note**: "On The Fly" (OTF) demos skip Demo Scheduled and go directly from Live Conversation to Demo Held in the same call session.

### Lead Outreach Stage values (Lead object)

| Outreach Stage | Meaning |
|----------------|---------|
| New | Lead just created/routed; no outreach yet |
| Assigned | In a rep's queue |
| Working | Rep has attempted contact |
| Added to Sequence | Enrolled in an Outreach cadence |
| Connected | Verbal or meeting connection made |

---

## Disposition codes

Dispositions are logged via RingDNA (call logger) and/or Outreach. Key codes used in brightwheel:

| Code | Meaning |
|------|---------|
| CC | Connected Call — spoke with decision maker (DM Connect) |
| VM | Voicemail left |
| NC | No Contact — rang, no answer, no VM |
| BAD | Bad number / not in service |
| BAMFAM | Book A Meeting From A Meeting — next meeting booked during current meeting |

> **Note**: Full disposition picklist lives in the `Call_Disposition` Global Value Set in SFDC. See also `CallDispositionPicklist_4337850` and `CallDispositionPicklist_8672840` global value sets.

---

## Key field conventions

### Opportunity Name format
```
[emoji] School Name - Contact Name - $MRR
```
Forecasting emojis are used to signal deal confidence in list views. Emoji conventions are defined internally by the sales team (not enforced by SFDC validation).

### Next Step field format
```
[Date] [Action] [Context]
```
Example: `3/31 Demo scheduled — confirmed via ChiliPiper`

### CHAMP Notes (Opportunity)
Structured notes field capturing:
- **C**hallenge — what problem the school has
- **H**ead of household / decision maker
- **A**uthority — who signs / has budget
- **M**oney — MRR, budget, affordability
- **P**lan — agreed next step

### Additional Concerns/Notes field
Used to capture objections, product gaps, and anything not in CHAMP.

### UUID field
brightwheel's internal unique identifier for a school/account. Links the SFDC record to JungleGym (JG), brightwheel's internal customer management system. **Do not modify or blank this field** — it is the join key between SFDC and JG.

---

## Lead routing and assignment (LeanData)

- Inbound leads are routed automatically via LeanData based on territory, center type, lead source, and time of day.
- Queues include: Inbound Leads Queue, Lead Working Hours Queue, Lead After Hours Queue, Lead Before Hours Queue, Lead Overnight Hours Queue, LDC Queue 1–10.
- **SLA — Initial Contact**: Rep must make first contact within **2 business days** of lead assignment.
- **SLA — Stale Lead**: If no activity after assignment, lead is flagged as stale at **4 business days**.
- LeanData also enforces ROE (Rules of Engagement) for existing account matching and lead-to-account routing.

---

## Onboarding paths

After Closed Won, accounts are assigned one of the following onboarding paths (tracked on the Opportunity and Account):

| Path | Description |
|------|-------------|
| Standard Path | Full onboarding with an Onboarding Specialist (OBS); includes an Onboarding Kickoff (OBK) call |
| BNP Path | Brand New Program — delayed onboarding until program opens; BNP-specific OBS team |
| Self Serve | Customer declines live training; onboards via self-guided resources |
| Declined Training | Customer explicitly declines training offer post-CW |

OBE status requires full SSP(R) data collection (Students, Staff, Parents + Roster). Without OBE, the Onboarding team cannot open a case.

---

## Billing funnel (post-CW)

After Closed Won, a Billing Activation funnel runs in parallel to SaaS Onboarding:

- **Billing Funnel Status** field on Opportunity tracks progress through billing setup.
- Billing Onboarding Specialists (BOC) own this path.
- **Day 14 rule**: If the Billing At-Risk case is not closed within 14 days of CW, the billing status auto-flips to *Opted Out*.

---

## Known process issues

| Issue | Detail |
|-------|--------|
| **Neglect / auto-close logic** | If an Opportunity has no contact activity for >7 days AND the AE is not in an active Keep Warm cadence, a Slack alert is sent to the AE and manager. If neglect continues for 7 more days (14 days total), the Opportunity is auto-Closed Lost. Keep Warm cadence enrollment pauses this clock. |
| **GAP Report** | A report of undispositioned events (calls/meetings logged in RingDNA or Outreach without a disposition code). AEs are expected to disposition all events; GAP report is reviewed by managers. |
| **Forecasting emoji drift** | Opportunity Name emoji conventions are informal and not SFDC-validated. They can become inconsistent across teams. No automation enforces them. |
| **BNP timing ambiguity** | BNP Opportunities can remain open for months while the program builds out. Neglect rules technically apply but Keep Warm cadences are used to suppress auto-close. Confirm with Architect whether BNP opps should be excluded from neglect automation. |
| **OTF demo stage skip** | On The Fly demos go Live Conversation → Demo Held in one session. Reps sometimes forget to move the stage immediately, causing Demo Scheduled to appear artificially inflated in pipeline reports. |
| **UUID / JG dependency** | UUID field links SFDC to JungleGym. If UUID is missing or incorrect on an Account, JG data will not sync. This is a known fragility — do not allow bulk updates to UUID without Data Ops review. |
| **ChiliPiper ↔ SFDC sync** | ChiliPiper books meetings and logs them back to SFDC activities. Sync failures occasionally create duplicate meeting records. If activity counts look inflated, check for ChiliPiper dupes. |

---

## Reference links

| Resource | URL | Notes |
|----------|-----|-------|
| BNP Exception Request (Asana) | https://form.asana.com/?k=HYfJVCp98b7a4dhWsldhbw&d=15878177436323 | Use for BNP process exceptions requiring Architect or ops approval |
