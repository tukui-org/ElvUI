---
name: Retail Bug Report
about: Report a bug in ElvUI for Retail WoW
title: "[Retail Bug Report] <Title here>"
labels: ":bug::question: Bug (Needs Investigation),:video_game: Retail"
assignees: ''

---

body:
  - type: textarea
    id: what-happened
    attributes:
      label: What is the issue you are having?
      description: Describe the issue and what was going on when it happened?
      placeholder: Give us an explaination of what was going on when the issue appeared.
    validations:
      required: true
  - type: textarea
    id: expected-behavior
    attributes:
      label: What is the expected behavior?
      description: What do you think the expected behavior should have happened?
      placeholder: Try to explain what you expected the outcome to be.
    validations:
      required: true
  - type: textarea
    id: actual-behavior
    attributes:
      label: What actually happened?
      description: Please try to be as descriptive as possible.
      placeholder: Try to explain what happened.
    validations:
      required: true
  - type: textarea
    id: suggested-solution
    attributes:
      label: Suggested Solution/Workaround
      description: If you have any idea how we could solve it let us know.
      placeholder: "Make sure type the command: /edebug on then test."
    validations:
      required: false
  - type: textarea
    id: errors
    attributes:
      label: Errors
      description: If you have any errors, please put them here.
      render: shell
  - type: checkboxes
    id: terms
    attributes:
      label: ElvUI Changelog
      description: Whenever ElvUI or WoW updates, sometimes there will be changes that need to be made to keep up, make sure to read ElvUI changelog for any changes that may change option behavior.
      options:
        - label: I have confirmed that I have the latest version of ElvUI and read the [Changelog](https://changelogurlhere.com).
          required: true
  - type: checkboxes
    id: terms
    attributes:
      label: Troubleshooting
      description: By submitting this issue, you agree you followed our [Troubelshooting Steps](https://urlfortroubleshootingstepshere.com)
      options:
        - label: I agree that I followed this project's Troubleshooting Steps
          required: true