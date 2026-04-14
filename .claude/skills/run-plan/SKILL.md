---
name: run-plan
description: Execute a previously created plan to achieve a specified goal.
---

# Run Plan 
## Description
This skill takes a previously created plan and executes it step by step. It allows you to track the progress of each step and update their status as you work through the plan.

## Instructions
1. Provide the name of the plan you want to execute (the md file created by the create-plan skill).
2. You will create a and switch to a new branch with the representative name of the plan to keep track of all changes related to the execution of the plan.
3. The skill will load the plan and display the phases in a structured format.
4. For each phase, the skill will update the status to "In Progress" represented by [X] when you start working on it and "Done" represented by [✓] when you complete it.
5. For each step within the phases, you will also update their status to track your progress effectively The status options for each step are "To Do" represented by [ ], "In Progress" represented by [X], and "Done" represented by [✓].
6. The skill will stage and commit all changes after completing each phase, ensuring that your progress is saved and can be referenced later.
7. Whenevr you complete a phase you will stop, update the status of the phase to "Done" represented by [✓] and request for feedback from the user before moving on to the next phase. This allows for any necessary adjustments to be made to the plan based on the user's feedback. THIS IS MANDAORY TO ENSURE THAT THE PLAN IS EXECUTED ACCORDING TO THE USER'S EXPECTATIONS AND TO ALLOW FOR FLEXIBILITY IN CASE ANY changes are needed.
8. Repeat the process for each phase until the entire plan is executed.
9. After completing all phases, the skill will merge master into the current branch to ensure that all changes are integrated into the main codebase.

## Example Output
```md
# Plan to Achieve [Goal]

## Phase 1: [First Phase] 
### Description of the first phase, including any necessary details or sub-tasks. [✓]
1. Create a new file for the push notification service. [✓]
2. Implement the service to handle scheduling and sending notifications. [✓]
3. Integrate the service with the existing task management system to trigger notifications based on task deadlines [✓]

## Phase 2: [Second Phase]
### Description of the second phase, including any necessary details or sub-tasks. [✓]
1. Create a new file for the user authentication service. [✓]
2. Implement the service to handle user registration and login. [✓]
3. Integrate the service with the existing database to store user information. [✓]

## Phase 3: [Third Phase]
### Description of the third phase, including any necessary details or sub-tasks. [✓]
1. Create a new file for the data visualization component. [✓]
2. Implement the component to display charts and graphs. [X]
3. Integrate the component with the existing data API to fetch and display real-time data. [ ]

``` 