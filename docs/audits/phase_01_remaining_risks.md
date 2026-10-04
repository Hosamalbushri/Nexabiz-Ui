# Phase 01 Remaining Risks & Platform Limitations

**Package:** `packages/nexabiz_ui` (NexaBiz UI Foundation)  
**Date:** October 4, 2026  
**Auditor:** Principal Flutter Architect, Performance Engineer and Release Quality Auditor

---

## 1. Simulated IME vs. Physical Device IME

- **Widget Test Scope:** Stress test Scenario 2 exercises controller replacement while `TextEditingValue.composing` is set with an active range. This validates the Flutter framework level text-input value pipeline and bridge mirroring.
- **Physical Device Distinction:** Physical device IME lifecycle involves native OEM keyboards (e.g. Samsung Keyboard, Gboard, Apple Multilingual/Kanji IMEs, SwiftKey) and platform channel messages (`TextInput.setEditingState`, `TextInputClient.updateEditingValueWithDeltas`). On physical devices, rapidly replacing controllers while an OEM predictive candidate banner is open depends on the OEM keyboard engine correctly reacting to framework input state updates.
- **Mitigation:** The private `FieldTextControllerBridge` always synchronizes the exact composing range and selection offsets on every notification. However, physical testing across multiple third-party keyboards remains recommended before enterprise deployment.

---

## 2. In-Memory Autocomplete Scaling Limits

- **Current Synchronous Implementation:** `UiAutocompleteField` performs synchronous in-memory string matching (`_getFilteredSuggestions`) on the main UI isolate during text changes.
- **Observed Characteristics:**
  - 10 suggestions: ~1.1 ms build time.
  - 100 suggestions: ~1.8 ms build time.
  - 1,000 suggestions: ~2.8 ms build time.
  - 10,000 suggestions: ~5.1–7.1 ms build time.
- **Risk & Boundary:** For datasets up to 10,000 local string options, filtering executes within one 16.6ms frame budget. For datasets larger than 10,000 items, or datasets requiring network/database queries, synchronous filtering will drop frames.
- **Future Architecture:** A dedicated asynchronous / paginated search contract (`Future<List<T>> Function(String query)`) should be introduced in a future phase with explicit design review.

---

## 3. Assistive Technology & Screen-Reader Certification

- **Widget Tree Semantics:** All fields utilize `UiFieldShell` which correctly populates accessibility labels, live region error announcements (`LiveRegionMode.polite`), and required indicator hints.
- **Unverified Platform Surface:** Physical TalkBack (Android), VoiceOver (iOS/macOS), and NVDA/JAWS (Windows) audio output sequences and touch exploration gestures cannot be verified solely in automated widget tests.
- **Mitigation:** Semantic tree structure is validated via `boundary_test.dart` and field tests, but manual accessibility auditing on physical target hardware remains a prerequisite for full WCAG AAA certification.

---

## 4. Upstream `shadcn_flutter 0.0.53` Internals

- **Controller Listener Retention on Proxy:** The pinned `shadcn.TextField` registers a listener on its supplied controller in `initState` and `didUpdateWidget`, but does not invoke `removeListener` on `dispose`. 
- **Package Bridge Isolation:** The NexaBiz `FieldTextControllerBridge` completely shields caller-owned controllers by interposing a package-owned proxy. When the field is disposed, the bridge detaches from the caller controller and disposes the proxy. The upstream unremoved listener remains attached only to the dead proxy until garbage collection.
- **Automatic Popup Focus Transfer:** On desktop and web windowing environments, opening a `SelectPopup` does not always automatically steal primary keyboard focus without an explicit focus request. Keyboard tests in the test suite explicitly request focus on the modal surface to verify traversal.

---

## 5. Long-Session Endurance & Heap Retention

- **Tested:** Zero active listeners remain on caller controllers after 20 rapid swaps and 6 mounting/unmounting cycles.
- **Unverified:** Long-running memory profiling under automated monkey-testing across thousands of continuous navigation routes over 24+ hours has not yet been executed.
