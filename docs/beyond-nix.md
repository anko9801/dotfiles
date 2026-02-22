# Beyond Nix: alternative philosophies in Infrastructure as Code research

Research survey for future tool evaluation. See [tool-selection.md](tool-selection.md) for current decisions.

**The IaC research landscape from 2023–2025 reveals a decisive shift away from Nix's "correctness by construction" model toward adaptive, AI-mediated, and formally verified paradigms.** Across top venues like SOSP, NSDI, NeurIPS, OOPSLA, and FSE, researchers are exploring fundamentally different philosophies: systems that learn configurations from examples, LLM agents that reconcile infrastructure drift autonomously, SMT solvers that verify properties of existing IaC languages, and intent-based synthesizers that translate high-level goals into device-level configurations. These approaches share a common thesis — that the future of IaC lies not in designing a perfect language, but in building intelligent tooling around imperfect ones. What follows is an organized survey of **30+ papers and systems** across eight philosophical categories, each representing a distinct departure from Nix's purely functional paradigm.

---

## 1. AI/ML-driven infrastructure configuration challenges the "human writes everything" model

The most active research front in IaC (2023–2025) uses machine learning — particularly large language models — to generate, validate, and repair infrastructure configurations. This inverts Nix's model: rather than humans writing precise functional expressions that deterministically produce system states, AI systems generate configurations from high-level descriptions and refine them through feedback loops.

**NSync: Automated Cloud Infrastructure-as-Code Reconciliation with AI Agents** — Zhenning Yang, Archit Bhatnagar, Yiming Qiu et al. — *ACM SIGOPS Operating Systems Review, Vol. 59(1), 2025.* NSync detects infrastructure drift by analyzing cloud audit trails (AWS CloudTrail, Azure Event Hub) and uses LLM agents to synthesize targeted Terraform patches. Rather than preventing drift through immutability as Nix does, NSync **embraces mixed imperative/declarative workflows** and reactively repairs divergence. It achieves **0.97 pass@3 accuracy** across 372 drift scenarios with a self-evolving knowledge base that improves from past reconciliations. The philosophical departure is stark: where Nix says "drift is impossible if you do it right," NSync says "drift is inevitable, so automate the repair."

**TerraFormer: Automated IaC with LLMs Fine-Tuned via Policy-Guided Verifier Feedback** — University of Michigan team — *arXiv:2601.08734, January 2026.* A neuro-symbolic framework combining reinforcement learning with formal verification for IaC generation. Fine-tunes Qwen2.5-Coder models using a verifier-based reward incorporating syntax validity, deployability, and OPA/Rego policy compliance. Introduces the largest IaC datasets to date: **TF-Gen (152,475 instances)** and **TF-Mutn (52,516 mutation instances)**. Where Nix achieves correctness through language design, TerraFormer achieves it through iterative ML training against formal oracles — a "correct by learning" paradigm.

**GenKubeSec: LLM-Based Kubernetes Misconfiguration Detection, Localization, Reasoning, and Remediation** — Ehud Malul, Yair Meidan et al. — *arXiv:2405.19954, May 2024, Ben-Gurion University.* An end-to-end pipeline using a fine-tuned Mistral model for multi-label misconfiguration classification plus prompt-engineered LLM for remediation. Achieves **0.990 precision and 0.999 recall**, surpassing rule-based tools (KubeLinter, Checkov, Terrascan). Runs entirely locally with no external API exposure. Where Nix prevents misconfigurations through its type system, GenKubeSec applies ML-based post-hoc detection — reactive and probabilistic rather than preventive and deterministic.

**IaC-Eval: A Code Generation Benchmark for Cloud IaC Programs** — Patrick Tser Jern Kon, Jiachen Liu, Yiming Qiu et al. — *NeurIPS 2024 (Datasets and Benchmarks Track).* The first comprehensive benchmark for evaluating LLM-generated IaC, containing **458 human-curated Terraform scenarios** with formal Rego intent specifications as verification oracles. The headline finding: GPT-4 achieves only **19.36% pass@1** on IaC generation versus 86.6% on Python benchmarks. This quantifies the enormous difficulty gap between general code generation and infrastructure specification, validating Nix's intuition that infrastructure configuration is fundamentally harder than regular programming — while simultaneously charting a path toward AI-mediated IaC.

**TerraFault: Automated Bug Discovery in Cloud IaC Updates with LLM Agents** — Yiming Xiang, Zhenning Yang et al. — *AIOps Workshop at ICSE 2025.* LLM-guided fuzzing for discovering update bugs in Terraform. Generates mutation families and uses LLM-guided search to find buggy update transitions — an area where even simple IaC updates can produce inconsistent plan/apply behavior. Addresses a gap that static declarative approaches like Nix partially avoid through atomic switching, but that remains critical for the broader IaC ecosystem.

---

## 2. Self-healing and autonomous infrastructure replaces "declare once" with "continuously adapt"

A second cluster of work envisions infrastructure that monitors, diagnoses, and repairs itself — a closed-loop model fundamentally opposed to Nix's open-loop "declare and deploy" philosophy.

**AIOpsLab: A Holistic Framework to Evaluate AI Agents for Enabling Autonomous Clouds** — Yinfang Chen, Manish Shetty et al. (Microsoft Research) — *MLSys 2025; vision paper at SoCC 2024.* Proposes "AgentOps" — AI agents autonomously managing the entire incident lifecycle from detection through mitigation. The framework deploys microservice environments, injects faults via chaos engineering, and evaluates LLM-based agents (GPT-3.5, GPT-4, ReAct) on **48 benchmark problems**. Nix achieves reliability through deterministic, reproducible configurations with rollback to known-good states. AIOpsLab assumes failures will occur in complex distributed systems and builds agents that heal them in real-time — a fundamentally different temporal model.

**LLMSecConfig: An LLM-Based Approach for Fixing Software Container Misconfigurations** — *arXiv:2502.02009, February 2025.* Combines static analysis tools with LLMs and Retrieval-Augmented Generation to automatically repair Kubernetes security misconfigurations. The three-phase pipeline (SAT detection → RAG context retrieval → LLM repair with iterative validation) achieves **94% repair success** on 1,000 real-world configs versus 40.2% for bare GPT-4o-mini. This is a learned, retrieval-augmented approach that adapts to evolving security standards, contrasting with Nix's static, human-defined constraint system.

**LADs: Leveraging LLMs for AI-Driven DevOps** — *arXiv:2502.20825, February 2025.* Proposes LLM agents that manage the entire DevOps pipeline — configuration, deployment, monitoring, and maintenance — integrating with tools like Prometheus for observability. Where Nix is "declare once, deploy deterministically," LADs is "continuously observe and adapt." The system reasons about cloud costs, workload changes, and version mismatches, automatically reconfiguring infrastructure in response to changing conditions.

---

## 3. Formal methods bring mathematical guarantees to existing IaC languages

Rather than designing a new correct-by-construction language as Nix does, this research thread applies formal verification — SMT solvers, model checking, theorem proving — to existing IaC ecosystems. The philosophy is pragmatic: meet practitioners where they are and verify their code post-hoc.

**Zodiac: Unearthing Semantic Checks for Cloud IaC Programs** — Yiming Qiu, Patrick Tser Jern Kon, Ryan Beckett, Ang Chen — *SOSP 2024.* Published at the premier systems venue, Zodiac addresses a fundamental problem neither Nix nor any declarative language solves: **undocumented cloud provider constraints**. Even syntactically and semantically correct Terraform can fail at deployment due to unstated API requirements. Zodiac mines semantic checks from GitHub repositories, validates them using the **Z3 SMT solver** for test case generation, and confirms them through actual cloud deployment. This is an empirical, data-mined approach to discovering rules that exist nowhere in documentation — a fundamentally different epistemology from Nix's axiomatic model.

**DOML: A Model-Driven DevOps Modelling Language with SMT-Based Model Checking** — Michele Chiari, Bin Xiang, Galia Nedeltcheva et al. — *CAiSE 2023 (LNCS 13901); journal version in Information Systems, Vol. 125, 2024.* Part of the EU PIACERE project, DOML takes a **model-driven engineering** approach with three abstraction layers (application, abstract infrastructure, concrete infrastructure). Its model checker (DOML-MC) encodes infrastructure models as SMT problems using Z3 to verify structural properties. DOML then compiles verified models to Terraform/Ansible. This separates verification from execution — you verify the model, then generate code — whereas Nix's language serves simultaneously as specification and execution vehicle.

**Formal Verification for Preventing Misconfigured Access Policies in Kubernetes Clusters** — A. Sissodiya et al. — *IEEE Access, 2025.* Translates Kubernetes RBAC policies into first-order logic formulas and uses Z3 to exhaustively search for counterexamples to security invariants before deployment. Catches supply-chain image bypasses, privilege escalation, and multi-tenant namespace breaches. Addresses a domain — runtime access control policy verification in container orchestration — that Nix's package management model does not cover.

**Häyhä: Analyzing IaC to Prevent Intra-update Sniping Vulnerabilities** — Julien Lepiller, Ruzica Piskac, Martin Schäf, Mark Santolucito — *TACAS 2021 (seminal, heavily cited 2023–2024).* Formalizes the upgrade semantics of CloudFormation by defining interleaving semantics for infrastructure state transitions during updates. Detects **transient security flaws that exist only in intermediate states** — vulnerabilities Nix largely avoids through its atomic symlink-switching model, making this paper an illuminating counterpoint that demonstrates what formal verification buys you when deployment lacks transactional semantics.

**Rehearsal: A Configuration Verification Tool for Puppet** — Rian Shambaugh, Aaron Weiss, Arjun Guha — *PLDI 2016 (seminal).* The foundational formal verification paper for IaC. Defines formal semantics for Puppet, models configurations as filesystem operations, and reduces determinism-checking to decidable SMT formulas. Found bugs in 6 of 13 real-world Puppet configurations. Remains the most rigorous attempt to bring PL-theory rigor to an imperative IaC system.

---

## 4. Intent-based synthesis lets users specify goals instead of configurations

Perhaps the most philosophically distinct alternative to Nix, intent-based approaches allow users to specify *what* infrastructure should achieve rather than *how* it should be configured. The system synthesizes concrete configurations from abstract goals — a level of abstraction above even Nix's declarative model.

**Aura: Practical Intent-Driven Routing Configuration Synthesis** — Sivaramakrishnan Ramanathan, Ying Zhang et al. (Meta) — *NSDI 2023.* The most significant industry deployment of intent-driven synthesis. Operators express desired routing behavior in RPL (a high-level language describing *behavior*, not configuration), and a compiler synthesizes device-level BGP configurations. Deployed at **Meta datacenters for 2+ years**, generating **840K+ policies**. The operator never writes device configurations. This is fundamentally different from Nix's model where users write explicit, complete specifications: Aura's users describe outcomes ("traffic between AS X and AS Y should route via waypoint W") and the synthesizer handles everything else.

**CEGS: Configuration Example Generalizing Synthesizer** — Jianmin Liu, Li Chen, Dan Li et al. (Tsinghua University) — *NSDI 2025.* Represents a **"programming by example"** paradigm for network configuration. CEGS retrieves configuration examples from vendor manuals, then uses Graph Neural Networks for topology-aware generalization and LLMs for language understanding to adapt examples to arbitrary topologies. Users provide intent and topology; CEGS generalizes from documentation examples. This learning-from-demonstrations philosophy contrasts sharply with Nix's explicit specification model.

**Verified Prompt Programming** — Rajdeep Mondal, Alan Tang, Ryan Beckett, Todd Millstein, George Varghese — *HotNets 2023 (UCLA/Microsoft Research).* Characterizes GPT-4 as an "idiot savant" for configuration and proposes combining LLMs with modular verifiers. The LLM generates draft configurations from high-level intent; verifiers provide localized feedback for automatic correction. Achieves **10× leverage** (automated-to-human prompt ratio) for Cisco→Juniper translation. The correctness model — iterative convergence from approximate generation — is fundamentally different from Nix's a priori specification.

**Clarify: Tackling Ambiguity in User Intent for LLM-based Network Configuration Synthesis** — Rajdeep Mondal, Nikolaj Bjørner et al. — *HotNets 2025 (UCLA/Microsoft Research).* Addresses a problem Nix avoids by construction: **intent is inherently ambiguous**. Measurements in a large cloud reveal ACLs with hundreds of overlapping header spaces where priority is unspecifiable without interaction. Proposes interactive disambiguation during incremental synthesis. Nix requires unambiguous specification; this work acknowledges that real-world requirements are fundamentally underspecified and builds interactive refinement into the synthesis process.

**Emergence: LLM-based Policy Generation for Intent-Based Management** — Katarina Dzeparoska et al. (University of Toronto) — *CNSM 2023/arXiv 2024.* Uses LLM few-shot learning for **progressive hierarchical decomposition** of high-level intents into policies via MAPE-K feedback control loops. Users express goals like "deploy a VNF service chain with high availability," and the system progressively decomposes these into concrete policies — a multi-level intent hierarchy versus Nix's single-level declarative specification.

---

## 5. Graph-based and relational approaches model infrastructure as queryable structure

This category treats infrastructure not as functional expressions (Nix) or flat configuration files, but as **typed graphs** whose structure can be traversed, queried, and reasoned over.

**TOSCA v2.0** — OASIS Standard, approved September 2025. The most significant graph-based infrastructure modeling standard. TOSCA explicitly models systems as **typed graphs** where vertices represent components and edges represent relationships. New features include TOSCA Path syntax for arbitrary graph traversal and substitution mappings for hierarchical composition. Infrastructure orchestration reduces to graph dependency traversal — a fundamentally graph-theoretic approach compared to Nix's store-based derivation model.

**A Knowledge-Based Approach for Guided Development of IaC** — Zoe Vasileiou, Indika Kumara et al. — *Software and Systems Modeling (Springer), June 2025.* Uses **OWL 2 ontologies and knowledge graphs** to create a knowledge-driven IaC development environment. Configuration knowledge is a first-class, queryable graph; SPARQL queries and semantic reasoning guide developers by suggesting configurations and detecting anti-patterns. Rather than the user specifying everything declaratively (Nix), the system leverages accumulated domain knowledge encoded as ontological models to assist IaC authoring.

**Using Knowledge Graphs to Automate Network Compliance of Containerized Services** — Simić, Palma — *CNSM 2024.* Constructs knowledge graphs from open-source 5G Core Network implementations and uses formal logic-based automated reasoning for pre-deployment network policy compliance verification. Graph traversal and logical inference replace functional evaluation for compliance checking.

**GLITCH/InfraFix: Technology-Agnostic IaC Analysis and Repair via Graph-Based IR** — Nuno Saavedra, João F. Ferreira — *ASE 2022 (GLITCH); ISSTA 2025 (InfraFix).* GLITCH introduces a **graph-based intermediate representation** that unifies IaC concepts across Ansible, Chef, Puppet, Terraform, and Docker. InfraFix extends this IR with structured expression support for automated program repair using Z3-based synthesis. The philosophy: rather than committing to one language (as Nix does), create a universal graph representation enabling cross-technology analysis. InfraFix achieved **95.5% repair success** across 254,755 scenarios spanning four IaC technologies.

**DIaC: Re-Imagining Decentralized Infrastructure as Code Using Blockchain** — Rabimba Karanjai et al. — *IEEE TNSM, 2024.* Extends TOSCA with blockchain-based smart contracts for **decentralized IaC orchestration**. Infrastructure lifecycle management is governed by consensus rather than a single trusted system. Where Nix assumes a single machine's local store is authoritative, DIaC enables trustless, multi-party infrastructure management — a fundamentally different governance model for federated environments.

---

## 6. Empirical studies reveal that declarativeness alone does not prevent bugs

Several major empirical studies published at top venues provide the theoretical grounding for why alternatives to Nix's approach are needed — even purely declarative, functional systems leave entire classes of defects unaddressed.

**When Your Infrastructure Is a Buggy Program** — Georgios-Petros Drosos, Thodoris Sotiropoulos et al. — *OOPSLA 2024.* Analyzed **360 bugs** across Puppet, Ansible, and Chef ecosystems. Found that **27% of IaC bugs are silent misconfigurations** (no execution error, but wrong system state) and that IaC bugs are structurally analogous to traditional programming language bugs — type errors, resource ordering, state management. The implication: declarative purity (including Nix's) does not eliminate the fundamental complexity of system configuration.

**State Reconciliation Defects in Infrastructure as Code** — Md Mahadi Hassan et al. — *FSE 2024.* Studied **5,110 state reconciliation defects** in Ansible. Identified 8 defect categories (3 novel) related to the fundamental gap between declared desired state and actual infrastructure state. Nix minimizes this gap for packages via content-addressed storage, but the paper demonstrates that state reconciliation remains a hard problem for system-level configuration — even in declarative paradigms.

**On the Prevalence, Co-occurrence, and Impact of IaC Smells** — Narjes Bessghaier et al. — *SANER 2024.* Large-scale study finding that **74% of IaC files contain quality issues** and that files with smells require **nearly 4× more modifications**. This motivates the formal methods, AI-based detection, and graph-based analysis approaches catalogued above.

---

## 7. PL-IaC and automated testing offer a middle path between Nix and traditional tools

**Automated Infrastructure as Code Program Testing (ProTI)** — Daniel Sokolowski, David Spielmann, Guido Salvaneschi — *IEEE TSE, Vol. 50(6), 2024.* Introduces Automated Configuration Testing for "Programming Language IaC" (PL-IaC) — tools like Pulumi and AWS CDK where TypeScript or Python programs generate declarative configurations. This paradigm accepts imperative expressiveness but adds quality assurance through **property-based testing** with automatically generated configurations. Nix achieves correctness through language purity; ProTI achieves it through systematic testing of programs written in unconstrained languages. The accompanying **PIPr dataset** (MSR 2024) catalogues **37,712 PL-IaC programs** from 21,445 GitHub repositories, documenting **>10× growth** in PL-IaC adoption from 2020 to 2023.

---

## 8. What remains unexplored: gaps in the literature

Several areas the user asked about have **minimal or no academic coverage**:

- **Novel dotfiles management paradigms**: No academic papers from 2023–2025 address dotfiles management as a research topic. The space remains entirely practitioner-driven, dominated by tools like chezmoi, yadm, and GNU Stow, with Nix home-manager representing the most principled approach. This is a genuine research gap.

- **Dependent types and refinement types for IaC**: Despite extensive searching, no published work applies LiquidHaskell-style refinement types or Idris/Agda-style dependent types to infrastructure specification. The closest work uses Rego as a typed policy layer (IaC-Eval) and DOML's typed metamodel verified via SMT. This represents a significant unexplored opportunity.

- **Probabilistic configuration management**: No papers propose explicitly Bayesian or probabilistic models for configuration state reasoning, though the AI/ML approaches are implicitly probabilistic through LLM generation.

- **Reactive/event-driven IaC**: Only Ceaml (2024) explores QoE-triggered runtime adaptation rules in a modeling language — a potentially rich but barely explored paradigm.

---

## Conclusion: from "correct by construction" to "correct by collaboration"

The 2023–2025 IaC research landscape reveals a field moving decisively beyond Nix's core philosophy in three directions simultaneously. First, **AI-mediated configuration** (NSync, TerraFormer, CEGS) replaces human-written functional expressions with machine-generated code verified through formal oracles — achieving correctness through learning rather than language design. Second, **formal methods for existing tools** (Zodiac, DOML-MC, InfraFix) pragmatically verify configurations in languages practitioners actually use, rather than asking them to adopt a new paradigm. Third, **intent-based synthesis** (Aura, Clarify, Emergence) raises the abstraction level above even declarative specification, letting users express goals while systems determine configurations.

The empirical evidence is sobering for all camps: OOPSLA 2024 shows declarative IaC still contains bugs analogous to imperative programs; FSE 2024 demonstrates that state reconciliation defeats even careful declarative specification; and NeurIPS 2024 reveals that LLMs achieve under 20% accuracy on IaC tasks. **No single paradigm has solved infrastructure configuration.** The most promising direction appears to be hybrid systems combining multiple philosophies — like TerraFormer's neuro-symbolic approach (ML generation + formal verification) or Zodiac's empirical mining plus SMT validation. The field's implicit consensus: the future of IaC is not a better language but a better ecosystem of collaborating tools, each bringing a different form of intelligence to the problem.
