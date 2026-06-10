# Discovery Call Transcript

**Date:** May 28, 2026
**Account:** Brightwell Health (regional healthcare network, ~6,000 employees)
**Call type:** Discovery / current-state walkthrough
**Participants:**
- Sara Hrnciar, Presales Engineer (vendor)
- Priya Nadkarni, Director of Talent Acquisition (Brightwell Health)
- Dev Okafor, Talent Acquisition Operations Analyst (Brightwell Health)

---

*[Recording starts a few minutes in, after introductions.]*

**Sara:** I appreciate you both making the time. Before I pitch anything, I'd rather just hear how the work actually happens on your side. Priya, you run TA for the whole network?

**Priya:** I do. Eleven recruiters, two coordinators, and Dev on the operations side keeping the systems honest. We hire across clinical and corporate, so the volume swings a lot week to week.

**Sara:** Where does it hurt the most right now?

**Priya:** The front end. A single nursing req can pull two hundred applicants over a weekend. Somebody has to read every one of those against what the hiring manager actually asked for. And half the time the manager's notes and the posted job description don't even line up.

**Sara:** So the screening step itself. Walk me through what one recruiter does with one of those two hundred applicants.

**Priya:** They open the resume in Greenhouse, they have the requisition open in another tab, and they basically eyeball it. Does this person have the license. Do they have the years. Do they have the right unit experience. Then they write a couple of sentences so the hiring manager doesn't have to read the resume cold.

**Dev:** And that write-up is all over the place. One recruiter writes a full paragraph, another one writes "looks good, call them." The hiring managers complain constantly that they can't compare candidates, because every recruiter summarizes differently.

**Sara:** How long is that per candidate, roughly?

**Priya:** Fifteen, twenty minutes if they're being careful. On a high-volume req nobody is being careful by candidate ninety. That's where good people slip through and bad fits get phone screens they shouldn't.

**Sara:** Got it. So if I play it back: the repeatable piece is take a requisition and a candidate, check the candidate against the must-haves and the nice-to-haves, and produce one consistent summary a manager can actually skim. Same shape every single time.

**Priya:** Yes. And honestly the "same shape every time" part is half the value. Right now the inconsistency is as big a problem as the time it takes.

**Sara:** Let's get specific. When a strong recruiter does this well, what's actually in the summary?

**Priya:** A match call right at the top. We'd want something simple, like strong, possible, or no. Then the must-haves listed out with a yes or no on each one, license, years, unit experience, that kind of thing. Then a line or two on the relevant experience so the manager gets the gist. A flag if something is missing or unclear, like the license number isn't in the file. And a recommended next step, phone screen or pass.

**Dev:** If it produced that same five-part summary for every candidate, our managers would be thrilled. They've literally asked us for a standard template and we've never been able to enforce one.

**Sara:** And the inputs to all of that already live in Greenhouse, correct? The requisition fields and the candidate record are both structured data in there?

**Dev:** They are. The req has the qualifications fields, the candidate record has the resume and the application answers. It's all sitting in Greenhouse, we just don't have anything that reads both and does the comparison for us.

**Priya:** That's the gap. The information exists. A human just has to sit there and manually cross-reference it two hundred times.

**Sara:** Okay. What I'm hearing is a really clean, scoped task. One requisition in, one candidate in, one structured summary out, in your exact five-part format, pulled from data you already have. That is a very buildable thing.

**Priya:** When you say buildable, what does that look like for us? We don't have engineers sitting around.

**Sara:** That's the part I think will surprise you. You wouldn't be writing code or standing up a system. The way I'd approach it, I'd take a real recruiter walkthrough, almost exactly the conversation we just had, and use it to define a single reusable tool. It knows where to pull the requisition and the candidate from, it knows your match logic, and it produces that summary in the format Priya just described. Then a recruiter triggers it instead of doing the twenty minutes by hand.

**Dev:** And it would write that back into Greenhouse, or just hand it to the recruiter?

**Sara:** Either, and that's a good design question for later. The first version probably just hands the recruiter the summary so they stay in control and can sanity-check it. Once you trust it, you can have it post the summary straight onto the candidate record.

**Priya:** I'd want the recruiter in the loop at first. The managers need to trust this before it touches the record.

**Sara:** Completely agree, and that's how I'd scope a first version. Honestly, the cleanest thing I can do is take what you just told me and mock up exactly this. A screening summary tool for one req and one candidate, in your five-part format. Then you can react to something real instead of a slide.

**Priya:** That would be a lot more useful than another deck, yes.

**Sara:** Let me put that together. If it lands, the same approach extends to the next thing on your list. But let's get this one right first, because it's the one eating your recruiters alive today.

**Priya:** That works. Send us a time and we'll get the right hiring manager on the next call so they can poke holes in the format.

**Sara:** Perfect. I'll follow up with that and the mockup.

*[Recording ends.]*
