# Contributing to ENVied

Thank you for taking the time to contribute!

## Create a Pull Request

1. Fork the repository and create your branch from `main`.
1. Install melos:

    ```dart pub global activate melos```
1. Install all dependencies:

    ```melos bs```
1. Squash your commits and ensure you are using [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/). Using conventional commits helps auto generate the changelog.
1. If you’ve fixed a bug or added code that should be tested, add tests and make sure there is 100% test coverage. Pull Requests without 100% test coverage will not be approved.
1. Ensure the test suite passes:

    ```melos test```
1. If you've changed the public API, make sure to update/add documentation.
1. Format your code

    ```melos format```
1. Analyze your code

    ```melos validate```
1. Create the Pull Request.
1. Verify that all status checks are passing.