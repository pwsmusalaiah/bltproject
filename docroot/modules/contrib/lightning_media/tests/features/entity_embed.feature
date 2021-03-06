@lightning @api @lightning_media @javascript
Feature: Embedding entities in a WYSIWYG editor

  Background:
    Given I am logged in as a user with the media_creator role

  @917d6aa6
  Scenario Outline: Embed code-based media types use the Embedded display plugin by default
    Given <bundle> media from embed code:
      """
      <embed_code>
      """
    When I visit "/node/add/page"
    And I open the media browser
    And I select item 1
    And I submit the entity browser
    Then I should see a "form.entity-embed-dialog" element
    And I should not see an "Image style" field
    And I should not see an "Alternate text" field
    # There are two "Title" fields on the page once we reach this assertion --
    # the node title, and the image's title attribute. We need to specify the
    # actual name of the field or Mink will get confused.
    And I should not see an "attributes[title]" field

    Examples:
      | bundle    | embed_code                                                   |
      | video     | https://www.youtube.com/watch?v=N2_HkWs7OM0                  |
      | video     | https://vimeo.com/25585320                                   |
      | tweet     | https://twitter.com/djphenaproxima/status/879739227617079296 |
      | instagram | https://www.instagram.com/p/lV3WqOoNDD                       |

  @cd742161
  Scenario: Embedding an image with embed-specific alt text and image style
    Given a random image
    When I visit "/node/add/page"
    And I enter "Foobar" for "Title"
    And I open the media browser
    And I select item 1
    And I submit the entity browser
    And I select "medium" from "Image style"
    And I enter "Behold my image of randomness" for "Alternate text"
    # There are two "Title" fields on the page at this point -- the node title,
    # and the image's title attribute. We need to specify the actual name of
    # the field or Mink will get confused.
    And I enter "Ye gods!" for "attributes[title]"
    # We can't simply use the "I press Embed" step, because Drupal's dialog box
    # implementation wraps the text of the buttons in <span> tags, which trips
    # that step up.
    And I click the "body > .ui-dialog .ui-dialog-buttonpane button.button--primary" element
    And I wait for AJAX to finish
    And I enter "Foobar" for "Title"
    And I press "Save"
    Then the response should contain "Behold my image of randomness"
    And the response should contain "Ye gods!"
