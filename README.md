# APEX Enhanced Error Handling
##### A suite of best-practice features to augment your APEX error handling

This comes with an package "apex_error_handling" and (TODO) an application to track errors and allow developers to subscribe to errors on a per-app basis.

Installation
- First install logger
- Install the package
- Install the application
- In any of your APEX applications, set the "Error Handling Procedure" under "Application Attributes" to "apex_error_handling.handle_apex_error".

Supports
- Recording the error and related data
-- The error message
-- The APEX session information such as username, application, and page items
-- The exact button (or reuqest) that was sent
-- The component that broke, and what line in the code it broke on
-- The APEX collection
-- The user's browser
-- More... (read the code to learn)
- Ignoring common errors such as invalid session or checksum errors
- Emailing the error to anyone subscribed to the application's error message
- Returing a custom "Error Message" to the end-user based on whether the environment is in dev, staging, or production
- AOP Error Handling
- Handling errors from outside of APEX (such as from a scheduled job)
- More (read the code)


