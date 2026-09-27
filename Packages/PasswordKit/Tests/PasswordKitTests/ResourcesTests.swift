import Foundation
import Testing

@Test func testVectorsAreBundled() throws {
    let url = try #require(Bundle.module.url(forResource: "test-vectors", withExtension: "json"))
    let json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
    #expect(json?["version"] as? Int == 2)
}
