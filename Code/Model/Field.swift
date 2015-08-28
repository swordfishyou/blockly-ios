/*
* Copyright 2015 Google Inc. All Rights Reserved.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
Protocol for events that occur on a `Field`.
*/
@objc(BKYFieldDelegate)
public protocol FieldDelegate {
  /**
  Event that is called when one of the field's properties has changed.

  - Parameter field: The field that changed.
  */
  func fieldDidChange(field: Field)
}

/**
Input field.  Used for editable titles, variables, etc. This is an abstract class that defines the
UI on the block.  Actual instances would be `FieldLabel`, `FieldDropdown`, etc.
*/
@objc(BKYField)
public class Field: NSObject {
  // MARK: - Properties

  public let name: String
  public weak var delegate: FieldDelegate?

  // MARK: - Initializers

  internal init(name: String) {
    self.name = name
  }
}
