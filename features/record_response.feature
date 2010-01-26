Feature: Record response
  In order to have good, accurate test coverage
  As a TDD/BDD developer
  I want to record responses for requests that are not registered with fakeweb so I can use them with fakeweb in the future

  Scenario: Record a response using NetRecorder.with_sandbox
    Given our cache dir is set to an empty directory
     When I make an HTTP get request to "http://example.com" within the "with_sandbox_test" sandbox
     Then the "with_sandbox_test" cache file should have a response for "http://example.com" that matches /You have reached this web page by typing.*example\.com/

  @netrecorder_sandbox
  Scenario: Record a response using a tagged scenario
    Given our cache dir is set to an empty directory
      And this scenario is tagged with a netrecorder sandbox tag
     When I make an HTTP get request to "http://example.com"
     Then the current sandbox should have a recorded response for "http://example.com" that matches /You have reached this web page by typing.*example\.com/ so that it gets saved when the scenario completes

  @netrecorder_sandbox
  Scenario: Use both a tagged scenario sandbox and a nested sandbox within a single step definition
    Given our cache dir is set to an empty directory
      And this scenario is tagged with a netrecorder sandbox tag
     When I make an HTTP get request to "http://example.com/before_nested"
      And I make an HTTP get request to "http://example.com/nested" within the "nested" sandbox
      And I make an HTTP get request to "http://example.com/after_nested"
     Then the current sandbox should have a recorded response for "http://example.com/before_nested" that matches /The requested URL \/before_nested was not found/ so that it gets saved when the scenario completes
      And the "nested" cache file should have a response for "http://example.com/nested" that matches /The requested URL \/nested was not found/
      And the current sandbox should have a recorded response for "http://example.com/after_nested" that matches /The requested URL \/after_nested was not found/ so that it gets saved when the scenario completes