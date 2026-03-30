## 1. Core Principles
- **Clean Code Always:** Prioritize clarity over cleverness; keep code readable and maintainable [1].
- **Small Files & Functions:** Follow the "Divide and Conquer" rule. Functions and files must be small and perform a single responsibility [2, 3].
- **Minimal Documentation:** No unnecessary comments. Only write comments when truly needed; avoid obvious explanations [3].
- **Strict Clean Architecture:** Adhere strictly to Layered Architecture (Data, Domain, Presentation) [3, 4].
- **No Business Logic in UI:** Ensure logic remains in the Domain or Logic layers; the UI should only handle presentation [5].
- **Avoid Over-Engineering:** Do not apply complex patterns or abstractions unless specifically required by the business case [5, 6].

## 2. Technical Standards
- **Root Cause First:** Identify and solve the core issue instead of applying superficial fixes or patching symptoms [6].
- **Minimal Surface Changes:** Do not break existing patterns or libraries unless there is a critical reason [6, 7].
- **Consistency with Repository:** Follow the existing patterns and style of the current repository, even if they differ from your default [7].
- **Core Folder:** Use a 'Core' folder for shared components like extensions, constants, themes, and common widgets [7].
- **Performance Awareness:** Use `const` where possible, avoid unnecessary `setState`, and follow Flutter performance best practices [7].
- **No Silent Failures:** Ensure proper error handling and never let the application fail without notifying the user correctly [8].

## 3. Dependencies & Security
- **Dependency Rule:** Do not add external libraries unless justified. Always use the latest stable versions (aligned with Flutter 2026 standards) [9-11].
- **Security Awareness:** Never leak tokens or sensitive info. Avoid using `debugPrint` or print statements for sensitive data in production [10, 11].

## 4. AI Mindset & Workflow
- **Engineering Partner Mode:** Act as a Senior Engineer/Partner, not just a task executor. Suggest better alternatives if a request leads to poor code [2, 12].
- **No Assumptions:** Read and understand the existing code before making changes. Never assume or guess without verification [12].
- **Avoid Duplication:** Follow DRY (Don't Repeat Yourself) principles strictly [13].
- **Naming Conventions:** Use Dart best practices (snake_case for files, PascalCase for classes, camelCase for variables) [13].
- **Import Ordering:** Follow effective Dart guidelines for organizing import statements [13].
- **Testing Discipline:** Write unit tests for the domain layer and any critical business logic [13].
- **Separation of Concerns:** Maintain strict enforcement of how layers communicate with each other [13].

## 5. Automated Post-Task Workflow
- **When the task is done, automatically provide:**
  1. **Branch Name:** Based on the feature or fix.
  2. **Commit Message:** Following standard conventions.
  3. **PR Title & Description:** Summarizing the changes made [9, 14].
