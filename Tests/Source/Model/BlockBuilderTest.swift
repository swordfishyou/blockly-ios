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

@testable import Blockly
import XCTest

class BlockBuilderTest: XCTestCase {

  func testMakeBlock() {
    let workspace = Workspace()
    let block = buildFrankenBlock(workspace)
    validate(frankenblock: block)
  }

  func testMakeBlockFromBlock() {
    let workspace = Workspace()
    let block = buildFrankenBlock(workspace)
    let block2 = buildFrankenBlock(workspace)
    try! block.nextConnection?.connectTo(block2.previousConnection)
    let block3 = buildFrankenBlock(workspace)
    try! block.previousConnection?.connectTo(block3.nextConnection)

    let blockCopy = try! Block.Builder(block: block).makeBlock()
    try! workspace.addBlockTree(blockCopy)
    validate(frankenblock: blockCopy)

    // Validate that the block was deep copied
    XCTAssertTrue(block !== blockCopy)
    XCTAssertTrue(block.inputs[0] !== blockCopy.inputs[0])
    XCTAssertTrue(block.inputs[0].fields[0] !== blockCopy.inputs[0].fields[0])

    // Validate that the connections were not copied
    XCTAssertNil(blockCopy.nextConnection?.targetConnection)
    XCTAssertNil(blockCopy.previousConnection?.targetConnection)
    // TODO:(roboerik) validate output and input connections

  }

  internal func validate(frankenblock block: Block) {
    XCTAssertEqual("frankenblock", block.name)
    XCTAssertEqual(3, block.inputs.count)
    XCTAssertEqualWithAccuracy(
      CGFloat(20.0 / 360.0), block.color.bky_hsba().hue, accuracy: TestConstants.ACCURACY_CGF)
    XCTAssertEqual("http://www.example.com", block.helpURL)
    XCTAssertEqual("a tooltip", block.tooltip)

    XCTAssertNotNil(block.previousConnection)
    XCTAssertNil(block.previousConnection?.typeChecks)
    XCTAssertEqual(block, block.previousConnection?.sourceBlock)
    XCTAssertNotNil(block.nextConnection)
    XCTAssertEqual(["Boolean", "Number", "Array"], (block.nextConnection?.typeChecks)!)
    XCTAssertEqual(block, block.nextConnection?.sourceBlock)
    XCTAssertNil(block.outputConnection)

    var input = block.inputs[0]
    XCTAssertEqual(Input.InputType.value, input.type)
    XCTAssertEqual(2, input.fields.count)
    XCTAssertEqual(block, input.sourceBlock)
    XCTAssertEqual(block, input.connection?.sourceBlock)

    let fieldInput = input.fields[0] as? FieldInput
    XCTAssertNotNil(fieldInput)
    XCTAssertEqual("text_input", fieldInput?.name)
    XCTAssertEqual("something", fieldInput?.text)
    XCTAssertNotNil(input.fields[1] as? FieldCheckbox)

    input = block.inputs[1]
    XCTAssertEqual(Input.InputType.statement, input.type)
    XCTAssertEqual(block, input.sourceBlock)
    XCTAssertEqual(block, input.connection?.sourceBlock)
    XCTAssertEqual(2, input.fields.count)
    XCTAssertNotNil(input.fields[0] as? FieldDropdown)
    XCTAssertNotNil(input.fields[1] as? FieldVariable)

    input = block.inputs[2]
    XCTAssertEqual(Input.InputType.dummy, input.type)
    XCTAssertEqual(block, input.sourceBlock)
    XCTAssertNil(input.connection) // Dummy inputs have nil connections
    XCTAssertNotNil(input.fields[0] as? FieldAngle)
    XCTAssertNotNil(input.fields[1] as? FieldColor)
    XCTAssertNotNil(input.fields[2] as? FieldImage)
  }

  internal func buildFrankenBlock(_ workspace: Workspace) -> Block {
    let bob = Block.Builder(name: "frankenblock")

    var inputBuilder = Input.Builder(type: Input.InputType.value, name: "value_input")
    var fields = [
      FieldInput(name: "text_input", text: "something"),
      FieldCheckbox(name: "checkbox", checked: true)
    ]
    inputBuilder.appendFields(fields)
    bob.inputBuilders.append(inputBuilder)
    fields = []

    inputBuilder = Input.Builder(type: Input.InputType.statement, name:"statement_input")
    do {
      fields.append(try FieldDropdown(name: "dropdown",
        displayNames: ["option1", "option2", "option3"],
        values: ["OPTION1", "OPTION2", "OPTION3"],
        selectedIndex: 0))
    } catch let error as NSError {
      XCTFail("Error: \(error)")
    }
    fields.append(FieldVariable(name: "variable", variable: "item"))
    inputBuilder.appendFields(fields)
    bob.inputBuilders.append(inputBuilder)
    fields = []

    inputBuilder = Input.Builder(type: Input.InputType.dummy, name: "dummy_input")
    fields = [
      FieldAngle(name: "angle", angle: 90),
      FieldColor(name: "color", color: UIColor.magenta),
      FieldImage(name: "no name",
        imageLocation: "https://www.gstatic.com/codesite/ph/images/star_on.gif",
        size: WorkspaceSize(width: 15, height: 20), altText: "*")
    ]
    inputBuilder.appendFields(fields)
    bob.inputBuilders.append(inputBuilder)
    fields = []

    do {
      try bob.setPreviousConnection(enabled: true)
      try bob.setNextConnection(enabled: true, typeChecks: ["Boolean", "Number", "Array"])
    } catch let error as NSError {
      XCTFail("Error: \(error)")
    }
    bob.color = ColorHelper.makeColor(hue: 20)
    bob.helpURL = "http://www.example.com"
    bob.tooltip = "a tooltip"

    let block = try! bob.makeBlock()
    try! workspace.addBlockTree(block)
    return block
  }
}
