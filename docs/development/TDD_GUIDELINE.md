# Test-Driven Development (TDD) - Developer Guide

## Introduction

Test-Driven Development (TDD) is a software development methodology where tests are written before the actual implementation code. This approach ensures that code is testable, maintainable, and meets requirements from the outset. This guide is language-agnostic and applies to any open source project regardless of technology stack.

## The TDD Cycle: Red-Green-Refactor

TDD follows a repetitive three-phase cycle, often visualized as Red → Green → Blue (Refactor). Each phase has a distinct purpose and must be completed before moving to the next.

**Important Guidelines:**
- Each phase must be committed as a separate git commit to maintain traceability and clear separation of concerns
- Test files should only be modified during the RED phase; no test editing is allowed during the GREEN phase
- During the BLUE (refactor) phase, only logically allowed changes can be applied, and the main logic must be preserved and unchanged

---

### Phase 1: RED - Write a Failing Test

**Purpose:** Define what you want to build before building it.

**What to do:**
1. Write a single test that describes one small piece of functionality
2. Run the test and watch it fail (this confirms the test is actually running)
3. The failure should be for the right reason (the functionality doesn't exist yet, not a syntax error)

**Guidelines:**
- Write the smallest test possible that adds new behavior
- Test only one concept per test
- Use descriptive test names that explain what behavior you're testing
- Don't write multiple tests at once
- The test should specify the expected behavior clearly
- Make tests readable and maintainable with clear arrange-act-assert structure
- Keep tests focused and independent of other tests
- Ensure tests can run in any order

**Test Quality Standards:**
- Tests should be as clean and well-structured as production code
- Use meaningful names for test methods, variables, and helper functions
- Organize test setup logically and clearly
- Make assertions clear and specific
- Avoid complex logic within tests
- Each test should verify one behavior or outcome

**Why this matters:** Starting with a failing test ensures you understand the requirement and that your test can actually detect problems. It proves your test has value.

**Commit Requirement:** This phase must be committed as a separate git commit with a descriptive message indicating this is for tests only.

---

### Phase 2: GREEN - Make the Test Pass

**Purpose:** Write the simplest code that makes the test pass, nothing more.

**What to do:**
1. Write only enough code to make the failing test pass
2. Don't worry about code quality, optimization, or elegance yet
3. It's acceptable to use hard-coded values or "shortcuts" if they make the test pass
4. Run the test to confirm it passes
5. Run all previous tests to ensure nothing broke

**Guidelines:**
- Resist the temptation to write "extra" functionality
- Don't refactor yet—that comes in the next phase
- Speed matters here—get to green quickly
- If you find yourself writing too much code, your test might be too large
- Focus solely on making the test pass, not on perfect code

**Why this matters:** This phase proves that your test works and establishes a baseline. Keeping implementations simple prevents over-engineering and premature optimization.

**Restrictions:** No test code should be modified during this phase. Test editing is only allowed in the RED phase.
**Coding Separation:** Each TDD cycle should implement one logical, separable piece of functionality. Break down complex features into multiple RED-GREEN-BLUE cycles, with each cycle committed separately.
**Commit Requirement:** This phase must be committed as a separate git commit containing only the production code changes that make the test pass.

---

### Phase 3: BLUE (REFACTOR) - Improve the Code

**Purpose:** Improve the internal structure of your code without changing its external behavior.

This is the most critical and often most misunderstood phase of TDD. Refactoring is not optional—it's where code quality is built and technical debt is prevented.

#### What is Refactoring?

Refactoring means restructuring existing code to improve its design, readability, and maintainability while preserving its functionality. You are cleaning up the code you just wrote to pass the test, making it production-ready.

#### What to do:

1. **Review the implementation code you just wrote** - Focus on production code only, not tests
2. **Identify code smells** - Duplication, poor naming, long methods, complex conditionals, tight coupling
3. **Apply refactoring techniques** - Improve structure incrementally
4. **Run tests after each change** - Ensure behavior remains unchanged
5. **Refactor until satisfied** - Continue until the code meets quality standards
6. **Commit when done** - Save your work once tests pass and code is clean

**IMPORTANT:** During the Blue phase, you refactor only the production/implementation code. Tests are not touched during refactoring—they remain unchanged to ensure they can detect if you accidentally alter behavior.

**Restrictions:** Only logically allowed changes can be applied during refactoring. The main business logic implemented in the GREEN phase must remain preserved and unchanged. Refactoring is limited to structural improvements, code organization, naming, and other non-behavioral modifications that don't alter the core functionality.

**Commit Requirement:** This phase must be committed as a separate git commit containing only the refactoring changes to production code.

---

## Critical Refactoring Criteria

Your refactored code MUST meet these criteria before moving to the next test:

### 1. All Tests Still Pass

**Requirement:** Run your full test suite after every refactoring change.

**What this means:**
- If any test fails after refactoring, you've changed behavior (not allowed in refactoring)
- Revert immediately and try a smaller refactoring step
- Tests are your safety net—they prove refactoring didn't break anything
- Never skip running tests during refactoring

**Why it matters:** This is the fundamental contract of refactoring. If tests fail, you're not refactoring—you're changing functionality.

---

### 2. No Duplication (DRY - Don't Repeat Yourself)

**Requirement:** Eliminate duplicate code by extracting methods, classes, modules, or constants.

**What this means:**
- If you see the same code in multiple places, consolidate it
- If you see similar code with slight variations, abstract the common parts
- This includes duplicate validation logic, duplicate calculations, duplicate business rules
- Don't copy-paste code—extract and reuse instead

**What to look for:**
- Identical or nearly identical code blocks
- Same string literals or magic numbers in multiple locations
- Similar algorithms with minor differences
- Repeated conditional checks
- Duplicate test fixtures or setup code

**Why it matters:** Duplication means changes must be made in multiple places, increasing the risk of bugs and inconsistencies. Every piece of knowledge should have a single authoritative representation.

---

### 3. Clear and Expressive Names

**Requirement:** Variables, methods, classes, and modules should reveal their intent without needing comments.

**What this means:**
- Names should answer: Why does this exist? What does it do? How is it used?
- Avoid abbreviations unless they're universally understood in your domain
- Names should make code self-documenting
- Longer, descriptive names are better than short, cryptic ones
- Use domain language that stakeholders would understand

**What to look for:**
- Single-letter variables (except standard loop counters)
- Generic names like "data", "info", "manager", "handler" without context
- Names that require mental mapping to understand
- Misleading names that don't match actual behavior
- Inconsistent naming conventions across similar concepts

**Why it matters:** Code is read far more often than it's written. Clear names make code maintainable and reduce the cognitive load on other developers (including your future self).

---

### 4. Single Responsibility Principle

**Requirement:** Each method, class, and module should have one reason to change—it should do one thing well.

**What this means:**
- If you need "and" to describe what something does, it likely does too much
- A class should have one cohesive purpose
- A method should perform one logical operation
- Changes to one responsibility shouldn't require changes to code handling other responsibilities

**What to look for:**
- Long methods (typically more than 10-20 lines depending on language)
- Classes with many unrelated methods
- Methods that perform validation, transformation, storage, and notification
- God objects that know or do too much
- Methods with multiple levels of abstraction mixed together

**How to fix:**
- Extract methods to separate concerns
- Split large classes into smaller, focused ones
- Create dedicated classes for distinct responsibilities
- Use composition to combine simple components

**Why it matters:** Single responsibility makes code easier to understand, test, and modify. It reduces coupling and increases cohesion, leading to more maintainable systems.

---

### 5. Minimal Complexity

**Requirement:** Reduce cognitive complexity by simplifying control flow and logic.

**What this means:**
- Minimize nested conditionals and loops
- Replace complex boolean expressions with well-named methods or variables
- Use early returns (guard clauses) to reduce nesting
- Break complex algorithms into smaller, understandable steps
- Prefer simple, linear flow over deeply nested structures

**What to look for:**
- Deeply nested if statements (more than 2-3 levels)
- Long chains of conditional logic
- Complex boolean expressions with multiple AND/OR operators
- Nested loops that are difficult to understand
- Methods with high cyclomatic complexity (many decision points)

**Complexity indicators:**
- You have to trace through multiple paths mentally to understand the code
- You need to draw diagrams to understand control flow
- Adding a new case requires modifying deeply nested code

**Why it matters:** Complex code is error-prone and difficult to maintain. Simple code is easier to understand, test, and modify correctly.

---

### 6. Appropriate Abstraction Levels

**Requirement:** Code at the same level of abstraction should be consistent, and higher-level code should not mix with low-level details.

**What this means:**
- High-level methods should read like documentation, describing "what" without "how"
- Low-level details should be hidden in helper methods or separate modules
- Don't mix business logic with infrastructure concerns
- Each method should operate at a single level of abstraction

**What to look for:**
- Methods that mix high-level orchestration with low-level implementation details
- Business logic mixed with database queries, file I/O, or network calls
- UI code mixed with business rules
- Methods that jump between conceptual levels

**Good abstraction characteristics:**
- High-level methods tell a story in domain language
- Implementation details are hidden behind meaningful interfaces
- Dependencies point inward (toward abstractions, not concrete details)
- You can understand what code does without understanding how

**Why it matters:** Proper abstraction makes code easier to understand and change. It allows you to reason about different aspects of the system independently.

---

### 7. Remove Dead Code

**Requirement:** Delete all unused code, commented-out sections, and obsolete functionality.

**What this means:**
- Remove commented-out code completely—don't "save it for later"
- Delete unused methods, classes, variables, and imports
- Remove code that's no longer called or referenced
- Eliminate obsolete branches of conditional logic
- Trust your version control system to keep history

**What to look for:**
- Commented-out code blocks
- Unused imports or dependencies
- Methods that are never called
- Variables that are assigned but never read
- Unreachable code after return statements
- Feature flags for features that are fully rolled out

**Why it matters:** Dead code creates confusion, increases maintenance burden, and can mislead developers into thinking it's still relevant. It clutters the codebase and makes it harder to find active code.

---

### 8. Consistent Code Style

**Requirement:** Follow your project's established style guide and coding conventions consistently.

**What this means:**
- Apply consistent indentation, spacing, and formatting
- Follow naming conventions (camelCase, snake_case, PascalCase as appropriate)
- Use consistent patterns for similar operations
- Organize imports, methods, and classes consistently
- Apply consistent error handling patterns
- Use project-standard libraries and approaches

**What to look for:**
- Inconsistent indentation or brace placement
- Mixed naming conventions
- Different approaches to the same problem in different parts of the codebase
- Violations of project linting rules
- Formatting that differs from the project's automated formatter

**Why it matters:** Consistency reduces cognitive load. When code follows predictable patterns, developers can focus on logic rather than deciphering style differences.

---

### 9. Proper Separation of Concerns

**Requirement:** Keep different aspects of functionality separate and independent.

**What this means:**
- Business logic should be separate from presentation logic
- Data access should be separate from business rules
- Infrastructure concerns (logging, configuration) should be separate from core logic
- Each layer should depend only on abstractions of lower layers

**What to look for:**
- Database queries mixed with business logic
- UI code that contains business rules
- Business logic that depends on specific UI frameworks
- Tight coupling between unrelated modules
- Circular dependencies

**Why it matters:** Separation of concerns makes code modular, testable, and flexible. Changes to one aspect (like switching databases) shouldn't require changes to unrelated aspects (like business logic).

---

### 10. Test Code Quality

**Requirement:** Test code deserves the same quality standards as production code.

**What this means:**
- Tests should be readable and maintainable
- Eliminate duplication in test setup and assertions
- Use descriptive test names and clear arrange-act-assert structure
- Keep tests focused and independent
- Refactor tests just like production code

**What to look for:**
- Duplicate test setup code that could be extracted
- Tests that are hard to understand
- Tests that depend on execution order
- Overly complex test assertions
- Tests that test multiple things

**Why it matters:** Tests are documentation and safety net. Poor test quality leads to brittle tests that break unnecessarily or unclear tests that don't communicate intent.

---

## Common Refactoring Techniques

### Structural Refactorings
- **Extract Method/Function** - Pull code into a new method with a descriptive name
- **Inline Method** - Remove unnecessary indirection for overly simple methods
- **Extract Class** - Split large classes into smaller, focused ones
- **Move Method** - Relocate methods to more appropriate classes or modules
- **Extract Interface** - Create abstractions to reduce coupling

### Data Refactorings
- **Extract Variable** - Replace complex expressions with named variables
- **Inline Variable** - Remove variables that don't add clarity
- **Rename** - Give better names to variables, methods, classes, modules
- **Replace Magic Numbers** - Use named constants instead of literal values

### Conditional Refactorings
- **Decompose Conditional** - Extract complex conditionals into named methods
- **Consolidate Conditional** - Combine similar conditionals
- **Replace Conditional with Polymorphism** - Use inheritance/interfaces instead of type checking
- **Introduce Guard Clauses** - Use early returns to reduce nesting

### Hierarchy Refactorings
- **Pull Up Method** - Move common code to parent class or shared module
- **Push Down Method** - Move specialized code to subclasses
- **Extract Superclass** - Create parent class for common behavior
- **Replace Inheritance with Composition** - Favor composition over inheritance where appropriate

---

## When to Refactor

### During the Blue Phase (Always)
- After every test passes (this is mandatory)
- Before writing the next test
- When you notice code smells in code you just wrote

### During Development (Opportunistic)
- When you touch existing code
- When you notice duplication
- When you struggle to understand code you wrote days ago
- When adding a feature reveals poor structure

### Dedicated Refactoring (Planned)
- When technical debt impedes progress
- Before major feature additions
- When onboarding reveals confusing code
- As part of addressing code review feedback

---

## When NOT to Refactor

**Don't refactor if:**
- Tests are not passing (fix tests first)
- You're changing behavior (that's not refactoring)
- You don't understand the code yet (learn first, refactor later)
- The code works and you're just making it "your style" (respect existing patterns)
- You're refactoring just to refactor (refactor with purpose)

---

## The Refactoring Mindset

### Core Principles

**Leave Code Better Than You Found It**
- Every time you touch code, improve it slightly
- Small improvements compound over time
- Don't require perfection, just progress

**Refactor with Confidence**
- Tests give you permission to refactor fearlessly
- Make small changes and run tests frequently
- If you break something, tests will catch it

**Balance Pragmatism with Idealism**
- Perfect code doesn't exist
- Good-enough refactoring is better than no refactoring
- Diminishing returns exist—know when to stop

**Communicate Through Code**
- Refactored code should communicate intent clearly
- Future developers (including you) will thank you
- Code is for humans first, computers second

---

## Common Refactoring Mistakes to Avoid

1. **Skipping the Refactor Phase** - Green is not done; blue is part of the cycle
2. **Refactoring Without Tests** - You need the safety net
3. **Changing Behavior During Refactoring** - Keep behavior changes separate
4. **Over-Refactoring** - Don't optimize prematurely or add unnecessary abstraction
5. **Refactoring in Large Batches** - Small, incremental changes are safer
6. **Not Running Tests After Each Change** - Test constantly during refactoring
7. **Neglecting Test Code** - Tests need refactoring too

---

## Refactoring Checklist

Before moving to the next RED phase, verify:

- [ ] All tests pass (100% pass rate)
- [ ] No code duplication exists
- [ ] All names clearly express intent
- [ ] Each component has a single responsibility
- [ ] Complexity is minimized
- [ ] Abstraction levels are appropriate
- [ ] Dead code is removed
- [ ] Code style is consistent with project standards
- [ ] Concerns are properly separated

---

## Integration with Open Source Workflow

### For Contributors

**Before Submitting Pull Requests:**
- Ensure all TDD phases are complete for new code
- Refactor until code meets all criteria
- Run full test suite locally
- Follow project-specific contribution guidelines
- Document any complex refactorings in commit messages

**During Code Review:**
- Expect feedback on refactoring quality
- Be prepared to explain refactoring decisions
- Iterate on refactoring based on maintainer feedback

### For Maintainers

**Setting Expectations:**
- Document TDD requirements in CONTRIBUTING.md
- Provide examples of good refactoring in your codebase
- Use linting and static analysis to enforce consistency
- Include refactoring criteria in pull request templates

**Code Review Focus:**
- Verify tests exist and pass
- Check for code smells and refactoring opportunities
- Ensure refactoring criteria are met
- Provide constructive feedback on code quality
- Model good refactoring in your own contributions

---

## Measuring Refactoring Quality

### Objective Metrics
- **Test Coverage** - Percentage of code covered by tests
- **Cyclomatic Complexity** - Number of decision points in code
- **Code Duplication** - Percentage of duplicated code blocks
- **Method Length** - Average lines of code per method
- **Class Size** - Number of methods and responsibilities per class

### Subjective Indicators
- **Code Readability** - Can new contributors understand it quickly?
- **Ease of Change** - How hard is it to add new features?
- **Bug Frequency** - Do certain areas have recurring issues?
- **Developer Confidence** - Do developers feel safe making changes?

---

## Conclusion

The Blue (Refactor) phase is not optional—it's where code quality is built into your project. Refactoring transforms quick-and-dirty code into maintainable, professional software. By consistently applying these refactoring criteria after every test passes, you create a codebase that is:

- **Maintainable** - Easy to modify and extend
- **Readable** - Clear and understandable
- **Testable** - Well-structured for comprehensive testing
- **Flexible** - Adaptable to changing requirements
- **Professional** - Production-ready and high-quality

Remember: Red-Green-Blue is a cycle, not a sequence you complete once. Each feature, each bug fix, each improvement goes through this cycle. The discipline of TDD, especially thorough refactoring, is what separates good code from great code.

**The TDD cycle is incomplete without refactoring. Don't skip blue.**
