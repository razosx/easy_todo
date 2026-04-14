---
name: create-plan
description: Every time that the user wants to create a plan for a given goal. The skill will break down the goal into actionable steps and provide a structured approach to accomplish it. The plan will be saved in a markdown file for easy reference and sharing.
---

# Create Plan

## Description

This skill generates a plan to achieve a specified goal. It breaks down the goal into actionable steps and provides a structured approach to accomplish it.

## Instructions
1. Provide a clear and concise goal that you want to achieve.
2. You will ALWAYS use TDD to implement the steps of the plan. This means that for each step, you will first write a test that defines the expected behavior, then implement the code to make the test pass, and finally refactor the code if necessary. This approach ensures that your implementation is robust and meets the requirements of each step effectively.
3. The skill will analyze the goal:
  - If the goel is straightforward, it will generate a simple step-by-step plan.
  - If the goal is complex, it will break it down into smaller sub-goals and milestones to ensure a comprehensive approach.
4. The skill will ask follow-up questions if necessary to clarify the goal or gather additional information to create a more effective plan.
5. The skill will create a md file with the generated plan, which can be easily shared or referenced later. The name of the file will be based on the goal_datetime.md format.
6. Each phase will have 3 states: "To Do" represented by [ ], "In Progress" represented by [X], and "Done" represented by [✓].
7. Each step of the sub-tasks will also have the same 3 states to track progress effectively.


## Example Output
```md
# Plan to Achieve [Goal]

## Phase 1: [First Phase] 
### Description of the first phase, including any necessary details or sub-tasks. []
1. Create a new file for the push notification service.
2. Implement the service to handle scheduling and sending notifications.
3. Integrate the service with the existing task management system to trigger notifications based on task deadlines

## Phase 2: [Second Phase]
### Description of the second phase, including any necessary details or sub-tasks.
1. Create a new file for the user authentication service.
2. Implement the service to handle user registration and login.
3. Integrate the service with the existing database to store user information.

## Phase 3: [Third Phase]
### Description of the third phase, including any necessary details or sub-tasks.
1. Create a new file for the data visualization component.
2. Implement the component to display charts and graphs.
3. Integrate the component with the existing data API to fetch and display real-time data.

``` 